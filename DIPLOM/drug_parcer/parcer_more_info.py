import re
import time
import os
import requests
from bs4 import BeautifulSoup
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore import SERVER_TIMESTAMP

# ---------- НАСТРОЙКИ FIREBASE ----------
CREDENTIALS_FILE = "firebase-creds.json"

if not os.path.exists(CREDENTIALS_FILE):
    print(f"❌ Файл {CREDENTIALS_FILE} не найден!")
    exit(1)

cred = credentials.Certificate(CREDENTIALS_FILE)
firebase_admin.initialize_app(cred)
db = firestore.client()
print("✅ Firebase подключён успешно!")


def read_urls_from_file(filename="urls.txt"):
    """Читает файл с форматом 'название|ссылка'"""
    medicines = []
    if not os.path.exists(filename):
        print(f"⚠️ Файл {filename} не найден")
        return medicines

    with open(filename, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            if '|' in line:
                parts = line.split('|', 1)
                name = parts[0].strip()
                url = parts[1].strip()
                medicines.append({'name': name, 'url': url})
            else:
                medicines.append({'name': '', 'url': line})
    return medicines


def get_page_html(url):
    """Загружает страницу через requests (без Selenium)"""
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3',
    }

    print(f"🌐 Загрузка: {url}")
    response = requests.get(url, headers=headers, timeout=30)
    response.raise_for_status()
    response.encoding = 'utf-8'
    return response.text


def detect_site(url):
    """Определяет сайт по URL"""
    if 'rlsnet.ru' in url:
        return 'rlsnet'
    elif 'apteka.103.by' in url:
        return 'apteka103'
    else:
        return 'unknown'


def parse_rlsnet(html, url):
    """Парсит страницу РЛС (rlsnet.ru)"""
    soup = BeautifulSoup(html, 'html.parser')

    more_info = {
        'source_url': url,
        'parsed_at': SERVER_TIMESTAMP,
        'source_site': 'rlsnet.ru'
    }

    # Основной блок с контентом
    content_area = soup.find('div', class_='tn__content')
    if not content_area:
        content_area = soup

    # Заголовки, которые нужно игнорировать
    IGNORE_HEADERS = [
        'выбор описания', 'заказ в аптеках', 'аналоги', 'источники информации',
        'особые отметки', 'все формы выпуска', 'владелец ру', 'условия хранения',
        'срок годности', 'описание проверено', 'дата обновления',
        'обобщенные научные материалы', 'содержание'
    ]

    headers = content_area.find_all(['h2', 'h3', 'h4'])

    for header in headers:
        header_text = header.get_text(strip=True)
        if not header_text or len(header_text) < 3:
            continue

        if any(ignore in header_text.lower() for ignore in IGNORE_HEADERS):
            continue

        next_elem = header.find_next()
        text_parts = []

        while next_elem and next_elem.name not in ['h2', 'h3', 'h4']:
            if next_elem.get('class') and (
                    'banner-group' in next_elem.get('class') or
                    'modal' in next_elem.get('class')
            ):
                next_elem = next_elem.find_next()
                continue

            if next_elem.name in ['p', 'div']:
                text = next_elem.get_text(strip=True)
                if text and len(text) > 10 and not text.startswith('Реклама'):
                    text_parts.append(text)

            next_elem = next_elem.find_next()

        if text_parts:
            full_text = ' '.join(text_parts)
            if len(full_text) > 8000:
                full_text = full_text[:8000] + "..."

            if full_text.strip():
                more_info[header_text] = full_text.strip()
                print(f"  ✓ {header_text}: {full_text[:80]}...")

    return more_info


def parse_apteka103(html, url):
    soup = BeautifulSoup(html, 'html.parser')

    more_info = {
        'source_url': url,
        'parsed_at': SERVER_TIMESTAMP,
        'source_site': 'apteka.103.by'
    }

    # --- 1. Основная информация о препарате ---

    # Форма выпуска (data-select="instruction-forms")
    form_elem = soup.find('div', {'data-select': 'instruction-forms'})
    if form_elem:
        form_text = form_elem.get_text(strip=True)
        if form_text:
            more_info['Форма выпуска'] = form_text
            print(f"  ✓ Форма выпуска: {form_text[:80]}...")

    # МНН
    mnn_elem = soup.find('p', string=re.compile(r'МНН:'))
    if mnn_elem:
        mnn_text = mnn_elem.get_text(strip=True).replace('МНН:', '').strip()
        if mnn_text:
            more_info['МНН'] = mnn_text
            print(f"  ✓ МНН: {mnn_text}")

    # ФТГ
    ftg_elem = soup.find('p', string=re.compile(r'ФТГ:'))
    if ftg_elem:
        ftg_text = ftg_elem.get_text(strip=True).replace('ФТГ:', '').strip()
        if ftg_text:
            more_info['ФТГ'] = ftg_text
            print(f"  ✓ ФТГ: {ftg_text}")

    # --- 2. Поиск всех разделов инструкции ---

    # Ищем все блоки с id (каждый раздел имеет уникальный id)
    # Например: id="Что из себя представляет препарат, и для чего его применяют"
    section_divs = soup.find_all('div', id=True)

    for div in section_divs:
        section_id = div.get('id', '')
        if not section_id or len(section_id) < 5:
            continue

        # Ищем заголовок внутри div
        header = div.find('h3', class_=re.compile(r'sc-1414f709'))
        if not header:
            continue

        title = header.get_text(strip=True)
        if not title or len(title) < 3:
            continue

        # Ищем блок с текстом
        content_div = div.find('div', class_=re.compile(r'sc-8aa55079-1'))
        if content_div:
            # Получаем весь текст, очищаем от лишних пробелов
            text = content_div.get_text(strip=True)

            # Убираем дублирующиеся строки
            lines = []
            for line in text.split('\n'):
                line = line.strip()
                if line and line not in lines:
                    lines.append(line)
            full_text = '\n'.join(lines)

            if len(full_text) > 8000:
                full_text = full_text[:8000] + "..."

            if full_text:
                more_info[title] = full_text
                print(f"  ✓ {title}: {full_text[:80]}...")

    # --- 3. Если не нашли по id, ищем по заголовкам h3 ---
    if len(more_info) <= 3:  # только базовые поля
        print("📌 Альтернативный поиск по заголовкам h3...")

        headers = soup.find_all('h3', class_=re.compile(r'sc-1414f709'))

        for header in headers:
            title = header.get_text(strip=True)
            if not title or len(title) < 3:
                continue

            # Ищем родительский div с контентом
            parent_div = header.find_parent('div', class_=re.compile(r'sc-8aa55079-0'))
            if parent_div:
                content_div = parent_div.find('div', class_=re.compile(r'sc-8aa55079-1'))
                if content_div:
                    text = content_div.get_text(strip=True)
                    if text:
                        if len(text) > 8000:
                            text = text[:8000] + "..."
                        more_info[title] = text
                        print(f"  ✓ {title}: {text[:80]}...")

    return more_info


def find_document_by_name(name):
    """Ищет документ в коллекции drugs по названию"""
    if not name:
        return None, None

    drugs_ref = db.collection('drugs')

    # Точное совпадение
    query = drugs_ref.where('name', '==', name).limit(5)
    docs = list(query.stream())

    # Частичное совпадение
    if not docs:
        all_docs = drugs_ref.limit(100).stream()
        for doc in all_docs:
            data = doc.to_dict()
            doc_name = data.get('name', '')
            if name.lower() in doc_name.lower() or doc_name.lower() in name.lower():
                docs.append(doc)
                break

    if docs:
        return docs[0].reference, docs[0].to_dict()

    return None, None


def update_more_info(doc_ref, more_info):
    """Обновляет поле more_info в документе"""
    update_data = {
        'more_info': more_info,
        'more_info_url': more_info.get('source_url'),
        'last_updated': SERVER_TIMESTAMP
    }

    doc_ref.update(update_data)
    print(f"✅ Обновлено поле more_info: добавлено {len(more_info)} разделов")
    return True


def process_medicine(medicine):
    """Обрабатывает одно лекарство"""
    name = medicine['name']
    url = medicine['url']

    print(f"\n{'=' * 60}")
    print(f"💊 Лекарство: {name}")
    print(f"🔗 Ссылка: {url}")
    print('=' * 60)

    if not url:
        print("❌ Нет ссылки, пропускаем")
        return

    if not name:
        print("❌ Нет названия, пропускаем")
        return

    # Определяем сайт
    site = detect_site(url)
    print(f"📌 Определён сайт: {site}")

    try:
        html = get_page_html(url)

        if site == 'rlsnet':
            more_info = parse_rlsnet(html, url)
        elif site == 'apteka103':
            more_info = parse_apteka103(html, url)
        else:
            print(f"❌ Неизвестный сайт: {url}")
            return

        if not more_info or len(more_info) <= 3:  # только source_url, parsed_at, source_site
            print("⚠️ Не удалось извлечь данные")
            return

    except Exception as e:
        print(f"❌ Ошибка парсинга: {e}")
        return

    print(f"🔎 Ищем в БД: {name}")
    doc_ref, existing_data = find_document_by_name(name)

    if not doc_ref:
        print(f"🆕 Документ не найден, создаём новый...")
        new_data = {
            'name': name,
            'more_info_url': url,
            'more_info': more_info,
            'created_at': SERVER_TIMESTAMP,
            'source': site
        }
        doc_ref = db.collection('drugs').document()
        doc_ref.set(new_data)
        print(f"✅ Создан новый документ с ID: {doc_ref.id}")
    else:
        print(f"📄 Найден существующий документ: {doc_ref.id}")
        update_more_info(doc_ref, more_info)


def main():
    print("🚀 Запуск универсального парсера")
    print("📁 Поддерживаются сайты: rlsnet.ru, apteka.103.by")
    print("📁 Формат urls.txt: название|ссылка")

    medicines = read_urls_from_file("urls.txt")

    if not medicines:
        print("❌ Нет ссылок для обработки")
        return

    print(f"📖 Загружено {len(medicines)} записей")

    for i, medicine in enumerate(medicines, 1):
        print(f"\n📌 Обработка {i}/{len(medicines)}")
        process_medicine(medicine)
        if i < len(medicines):
            print("⏳ Пауза 3 секунды...")
            time.sleep(3)

    print("\n" + "=" * 60)
    print("✅ Парсинг завершён!")


if __name__ == "__main__":
    main()