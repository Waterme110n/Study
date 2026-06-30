import requests
from bs4 import BeautifulSoup
import re
import firebase_admin
from firebase_admin import credentials, firestore
import time
from typing import Dict, Optional
from urllib.parse import urlparse


class TabletkaParser:
    def __init__(self, firebase_creds_path: str = None):
        """
        Инициализация парсера

        Args:
            firebase_creds_path: путь к JSON файлу с учетными данными Firebase
        """
        self.base_url = "https://tabletka.by"
        self.session = requests.Session()
        self.session.headers.update({
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
            'Accept-Encoding': 'gzip, deflate, br',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        })

        # Инициализация Firebase
        if firebase_creds_path:
            try:
                cred = credentials.Certificate(firebase_creds_path)
                firebase_admin.initialize_app(cred)
                self.db = firestore.client()
                print("✅ Firebase успешно инициализирован")
            except Exception as e:
                print(f"❌ Ошибка инициализации Firebase: {e}")
                self.db = None
        else:
            self.db = None

    def parse_from_url(self, url: str, collection_name: str = "drugs") -> Optional[Dict]:
        """
        Парсинг лекарства по прямому URL и сохранение в Firebase

        Args:
            url: прямая ссылка на страницу лекарства на tabletka.by
            collection_name: название коллекции в Firebase (по умолчанию "drugs")

        Returns:
            Словарь с данными лекарства
        """
        print(f"\n📄 Парсинг страницы: {url}")

        try:
            # Загружаем страницу
            response = self.session.get(url)
            response.raise_for_status()
            soup = BeautifulSoup(response.content, 'html.parser')

            # Ищем нужный блок с данными
            modal_container = soup.find('div', class_='modal-container-inner')
            if not modal_container:
                print("❌ Не найден блок с данными лекарства")
                return None

            # Извлекаем данные
            drug_data = self._extract_drug_data(modal_container, url)

            if not drug_data:
                print("❌ Не удалось извлечь данные")
                return None

            print(f"✅ Данные извлечены успешно")
            print(f"   Название: {drug_data['name']}")
            print(f"   МНН: {drug_data['genericName']}")
            print(f"   Форма: {drug_data['dosageForm']}")
            print(f"   Дозировка: {drug_data['dosage']}")
            print(f"   Производитель: {drug_data['manufacturer']}")
            print(f"   Страна: {drug_data['country']}")

            # Сохранение в Firebase
            if self.db:
                try:
                    # Добавляем timestamp
                    drug_data['created_at'] = firestore.SERVER_TIMESTAMP
                    drug_data['source_url'] = url

                    # Сохраняем в коллекцию
                    doc_ref = self.db.collection(collection_name).document()
                    doc_ref.set(drug_data)

                    print(f"💾 Данные сохранены в Firebase с ID: {doc_ref.id}")
                    drug_data['firebase_id'] = doc_ref.id

                except Exception as e:
                    print(f"❌ Ошибка при сохранении в Firebase: {e}")
            else:
                print("⚠️ Firebase не инициализирован, сохранение пропущено")

            return drug_data

        except Exception as e:
            print(f"❌ Ошибка при парсинге {url}: {e}")
            return None

    def _extract_drug_data(self, modal_container, url: str) -> Dict:
        """
        Извлечение данных из блока modal-container-inner

        Args:
            modal_container: BeautifulSoup элемент с классом modal-container-inner
            url: URL страницы для извлечения дозировки

        Returns:
            Словарь с данными лекарства
        """
        drug_data = {
            "name": "",
            "genericName": "",
            "dosageForm": "",
            "dosage": "",
            "manufacturer": "",
            "country": ""
        }

        # Ищем все таблицы с данными
        tables = modal_container.find_all('div', class_='modal-info-table')

        for table in tables:
            rows = table.find_all('div', class_='modal-info-table-tr')
            for row in rows:
                cells = row.find_all('div', class_='modal-info-table-td')
                if len(cells) >= 2:
                    label = cells[0].get_text(strip=True)
                    value = cells[1].get_text(strip=True)

                    print(f"   Найдено поле: '{label}' = '{value[:50]}'")  # Отладка

                    # Наименование - то что нам нужно для name
                    if label == 'Наименование':
                        drug_data['name'] = value
                        print(f"   ✅ Название найдено: {value}")

                    # МНН
                    elif label == 'МНН':
                        drug_data['genericName'] = value

                    # Форма выпуска
                    elif label == 'Форма выпуска':
                        drug_data['dosageForm'] = value
                        # Извлекаем дозировку из формы выпуска
                        dosage = self._extract_dosage_from_string(value)
                        if dosage and not drug_data['dosage']:
                            drug_data['dosage'] = dosage

                    # Лекарственная форма (альтернативный источник)
                    elif label == 'Лекарственная форма' and not drug_data['dosageForm']:
                        drug_data['dosageForm'] = value

                    # Производитель по справочнику
                    elif label == 'Производитель по справочнику':
                        drug_data['manufacturer'] = value
                        # Извлекаем страну
                        country = self._extract_country_from_string(value)
                        if country:
                            drug_data['country'] = country

                    # Производитель по регистрации (если нет основного)
                    elif label == 'Производитель по регистрации' and not drug_data['manufacturer']:
                        drug_data['manufacturer'] = value
                        country = self._extract_country_from_string(value)
                        if country:
                            drug_data['country'] = country

        # 2. Если дозировка не найдена, пытаемся извлечь из названия или URL
        if not drug_data['dosage']:
            # Извлекаем из названия
            dosage = self._extract_dosage_from_string(drug_data['name'])
            if not dosage:
                # Извлекаем из URL
                dosage = self._extract_dosage_from_url(url)
            drug_data['dosage'] = dosage

        # 3. Если форма выпуска пустая, пытаемся извлечь из названия
        if not drug_data['dosageForm'] and drug_data['name']:
            # Ищем форму в названии
            form_match = re.search(r'(таблетки|капсулы|раствор|мазь|сироп|суспензия)', drug_data['name'], re.IGNORECASE)
            if form_match:
                drug_data['dosageForm'] = form_match.group(1)

        # 4. Если МНН не найдено, пробуем найти в других полях
        if not drug_data['genericName']:
            # Ищем в modal-info-description
            desc_element = modal_container.find('div', class_='modal-info-description')
            if desc_element:
                desc_text = desc_element.get_text(strip=True)
                # После слеша часто идет МНН
                if '/' in desc_text:
                    parts = desc_text.split('/')
                    if len(parts) > 1:
                        drug_data['genericName'] = parts[-1].strip()

        # 5. Очищаем данные
        drug_data = self._clean_drug_data(drug_data)

        return drug_data

    def _clean_name(self, name: str) -> str:
        """Очищает название лекарства"""
        # Убираем лишние пробелы и приводим к нормальному виду
        name = re.sub(r'\s+', ' ', name)
        # Убираем информацию о форме и дозировке из названия, если есть
        name = re.sub(r'\s+(таблетки|капсулы|раствор|мазь|сироп|суспензия).*$', '', name, flags=re.IGNORECASE)
        name = re.sub(r'\s+\d+мг.*$', '', name, flags=re.IGNORECASE)
        return name.strip()

    def _extract_dosage_from_string(self, text: str) -> str:
        """Извлекает дозировку из строки"""
        patterns = [
            r'(\d+\s*мг)',
            r'(\d+\s*мл)',
            r'(\d+\s*г)',
            r'(\d+\s*мкг)',
            r'(\d+\s*%?)'
        ]

        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                dosage = match.group(1)
                # Приводим к стандартному формату
                dosage = re.sub(r'\s+', '', dosage)
                return dosage.lower()

        return ""

    def _extract_dosage_from_url(self, url: str) -> str:
        """Извлекает дозировку из URL"""
        patterns = [
            r'(\d+)\s*мг',
            r'(\d+)\s*ml',
            r'(\d+)-мг'
        ]

        for pattern in patterns:
            match = re.search(pattern, url, re.IGNORECASE)
            if match:
                return f"{match.group(1)} мг"

        return ""

    def _extract_country_from_string(self, text: str) -> str:
        """Извлекает страну из строки производителя"""
        countries = [
            "Беларусь", "Россия", "Украина", "Германия", "Франция",
            "Италия", "США", "Швейцария", "Индия", "Словения",
            "Польша", "Венгрия", "Литва", "Латвия", "Эстония",
            "Великобритания", "Нидерланды", "Бельгия", "Чехия", "Словакия",
            "Австрия", "Финляндия", "Швеция", "Норвегия", "Дания"
        ]

        for country in countries:
            if country in text:
                return country

        return ""

    def _clean_drug_data(self, data: Dict) -> Dict:
        """Очищает и форматирует данные"""
        # Убираем лишние пробелы
        for key in data:
            if isinstance(data[key], str):
                data[key] = re.sub(r'\s+', ' ', data[key]).strip()

        # Если форма выпуска содержит дозировку, убираем её из формы
        if data['dosage'] and data['dosage'] in data['dosageForm']:
            data['dosageForm'] = data['dosageForm'].replace(data['dosage'], '').strip()
            data['dosageForm'] = re.sub(r'\s+', ' ', data['dosageForm']).strip()

        return data

    def parse_multiple_urls(self, urls: list, delay: float = 1.0, collection_name: str = "drugs") -> list:
        """
        Парсинг нескольких URL

        Args:
            urls: список URL страниц лекарств
            delay: задержка между запросами (секунды)
            collection_name: название коллекции в Firebase

        Returns:
            Список результатов парсинга
        """
        results = []

        for i, url in enumerate(urls, 1):
            print(f"\n{'=' * 60}")
            print(f"[{i}/{len(urls)}] Обработка URL: {url}")
            print(f"{'=' * 60}")

            result = self.parse_from_url(url, collection_name)
            if result:
                results.append(result)

            # Задержка между запросами
            if i < len(urls):
                print(f"⏳ Пауза {delay} секунд...")
                time.sleep(delay)

        return results


# Пример использования
def main():
    # Путь к файлу с учетными данными Firebase
    FIREBASE_CREDS_PATH = "firebase-creds.json"

    # Инициализация парсера
    parser = TabletkaParser(firebase_creds_path=FIREBASE_CREDS_PATH)

    # Пример URL для парсинга (вы можете вставить свои)
    urls_to_parse = [
        "https://tabletka.by/lekarstva/aspirin-cardio-100mg-28/",
        # Добавьте сюда другие URL
    ]

    # Вариант 1: Парсинг одного URL
    if urls_to_parse:
        result = parser.parse_from_url(urls_to_parse[0], collection_name="drugs")

        if result:
            print("\n📊 Результат парсинга:")
            for key, value in result.items():
                if key not in ['created_at', 'source_url']:
                    print(f"  {key}: {value}")

    # Вариант 2: Парсинг нескольких URL
    # results = parser.parse_multiple_urls(urls_to_parse, delay=2.0, collection_name="drugs")
    # print(f"\n✅ Успешно обработано: {len(results)} из {len(urls_to_parse)} URL")


# Простой скрипт для добавления лекарств вручную
def add_medicines_manually():
    """
    Функция для ручного добавления лекарств в Firebase
    Вы можете вызывать её для каждого лекарства
    """
    FIREBASE_CREDS_PATH = "firebase-creds.json"
    parser = TabletkaParser(firebase_creds_path=FIREBASE_CREDS_PATH)

    while True:
        print("\n" + "=" * 60)
        url = input("Введите URL страницы лекарства (или 'exit' для выхода): ").strip()

        if url.lower() == 'exit':
            break

        if not url.startswith('http'):
            print("❌ Введите корректный URL (начинающийся с http:// или https://)")
            continue

        result = parser.parse_from_url(url, collection_name="drugs")

        if result:
            print("\n✅ Лекарство успешно добавлено в Firebase!")
            print(f"   ID документа: {result.get('firebase_id')}")
        else:
            print("\n❌ Не удалось добавить лекарство. Проверьте URL и попробуйте снова.")


if __name__ == "__main__":
    # Режим работы: выберите нужный
    print("Выберите режим работы:")
    print("1. Парсинг по списку URL (из кода)")
    print("2. Ручной ввод URL (интерактивный режим)")

    choice = input("Ваш выбор (1/2): ").strip()

    if choice == "2":
        add_medicines_manually()
    else:
        main()