
import os
import time
import json
import random
import string
from datetime import datetime

import numpy as np
import matplotlib.pyplot as plt
from fpdf import FPDF
from PyPDF2 import PdfReader

# ======== Стеганография: методы ========

class SpaceSteganography:
    """Метод замены пробелов (0 = ' ', 1 = '\t'). Добавлен нулевой байт как терминатор."""
    def encode(self, text: str, message: str) -> str:
        bits = ''.join(format(ord(c), '08b') for c in message) + '00000000'
        space_positions = [i for i, ch in enumerate(text) if ch == ' ']
        # если носителя не хватает — обрежем (реалистичная ситуация)
        if len(space_positions) < len(bits):
            bits = bits[:len(space_positions)]
        chars = list(text)
        for bit, pos in zip(bits, space_positions):
            chars[pos] = '\t' if bit == '1' else ' '
        return ''.join(chars)

    def decode(self, text: str) -> str:
        bits = ''.join('1' if ch == '\t' else '0' if ch == ' ' else '' for ch in text)
        out = []
        for i in range(0, len(bits), 8):
            b = bits[i:i+8]
            if len(b) < 8: break
            n = int(b, 2)
            if n == 0: break
            out.append(chr(n))
        return ''.join(out)


class ZeroWidthSteganography:
    """Метод невидимых символов: '0' = U+200B, '1' = U+200C, sep = U+200D."""
    def __init__(self):
        self.z0 = '\u200b'
        self.z1 = '\u200c'
        self.sep = '\u200d'

    def encode(self, text: str, message: str) -> str:
        bits = ''.join(format(ord(c), '08b') for c in message)
        res = []
        # вставляем по 1 биту после каждого символа, пока не кончатся биты
        i = 0
        for ch in text:
            res.append(ch)
            if i < len(bits):
                res.append(self.z1 if bits[i] == '1' else self.z0)
                i += 1
        if i > 0:
            res.append(self.sep)
        return ''.join(res)

    def decode(self, text: str) -> str:
        bits = []
        for ch in text:
            if ch == self.sep:
                break
            elif ch == self.z0:
                bits.append('0')
            elif ch == self.z1:
                bits.append('1')
        out = []
        for i in range(0, len(bits), 8):
            b = ''.join(bits[i:i+8])
            if len(b) < 8: break
            out.append(chr(int(b, 2)))
        return ''.join(out)


# ======== Помощники форматов (TXT/HTML/PDF) ========

def save_as_html(filename: str, text: str):
    html = (
        "<!DOCTYPE html><html><head><meta charset='utf-8'><title>Carrier</title></head>"
        f"<body><pre style='white-space: pre-wrap;'>{text}</pre></body></html>"
    )
    with open(filename, "w", encoding="utf-8") as f:
        f.write(html)

def read_html(filename: str) -> str:
    c = open(filename, encoding="utf-8").read()
    s = c.find("<pre")
    s = c.find(">", s) + 1
    e = c.find("</pre>", s)
    return c[s:e]

def _pdf_font_path() -> str | None:
    # попробуем несколько распространённых Unicode-шрифтов
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",                
        "/usr/share/fonts/truetype/noto/NotoSans-Regular.ttf",            
        "/usr/share/fonts/truetype/freefont/FreeSans.ttf",                
        "C:\\Windows\\Fonts\\arialuni.ttf",                               
        "C:\\Windows\\Fonts\\segoeui.ttf",                                
        "/Library/Fonts/Arial Unicode.ttf",                               
    ]
    for p in candidates:
        if os.path.exists(p):
            return p
    return None

def save_as_pdf(filename: str, text: str):
    pdf = FPDF()
    pdf.add_page()
    fp = _pdf_font_path()
    if fp:
        pdf.add_font("Unicode", "", fp, uni=True)
        pdf.set_font("Unicode", size=12)
        pdf.multi_cell(0, 8, text)
    else:
        pdf.set_font("Helvetica", size=12)
        # если шрифта нет, вырежем не-ASCII, чтобы не падать
        pdf.multi_cell(0, 8, text.encode("ascii", "ignore").decode("ascii"))
    pdf.output(filename)
    # подождём появление файла на диске (Windows)
    for _ in range(20):
        if os.path.exists(filename) and os.path.getsize(filename) > 0:
            break
        time.sleep(0.1)

def read_pdf(filename: str) -> str:
    # убедимся, что файл реально есть
    for _ in range(20):
        if os.path.exists(filename) and os.path.getsize(filename) > 0:
            break
        time.sleep(0.1)
    reader = PdfReader(filename)
    return "".join((page.extract_text() or "") for page in reader.pages)



class SteganographyAnalyzer:
    def __init__(self):
        self.space = SpaceSteganography()
        self.zw = ZeroWidthSteganography()
        self.results: list[dict] = []

    # --- генерация данных ---
    def generate_test_text(self, language='russian', length=800) -> str:
        if language == 'russian':
            alphabet = 'абвгдеёжзийклмнопрстуфхцчшщъыьэюя '
        else:
            alphabet = string.ascii_lowercase + ' '
        words = [''.join(random.choice(alphabet.replace(' ', '')) for _ in range(random.randint(3, 8)))
                 for _ in range(length // 10)]
        return ' '.join(words)

    def generate_test_message(self, length_type='short') -> str:
        sizes = {'short': (5, 10), 'medium': (15, 25), 'long': (30, 40)}
        n = random.randint(*sizes[length_type])
        return ''.join(random.choice(string.ascii_letters + string.digits) for _ in range(n))

    # --- измеритель ---
    def measure(self, method: str, data_in: str, message: str = '', op='encode'):
        t0 = time.time()
        try:
            if method == 'space':
                out = self.space.encode(data_in, message) if op == 'encode' else self.space.decode(data_in)
            else:
                out = self.zw.encode(data_in, message) if op == 'encode' else self.zw.decode(data_in)
            return out, time.time() - t0, True
        except Exception:
            return None, time.time() - t0, False

    # --- метрики ---
    def analyze_visibility(self, original: str, stego: str, method: str) -> float:
        if not stego:
            return 1.0
        if method == 'space':
            # доля изменённых символов (приблизительная заметность)
            diff = sum(1 for o, s in zip(original, stego) if o != s)
            return diff / max(len(original), 1)
        # Zero-Width визуально не виден
        return 0.0

    def analyze_security(self, stego: str, method: str) -> float:
        if not stego:
            return 0.0
        if method == 'space':
            spaces = stego.count(' ')
            tabs = stego.count('\t')
            total = spaces + tabs
            return 1 - abs(spaces - tabs) / total if total else 0.0
        hidden = stego.count('\u200b') + stego.count('\u200c') + stego.count('\u200d')
        return 1 - (hidden / len(stego)) if len(stego) else 0.0

    # --- один эксперимент (формат + язык + длина + метод) ---
    def run_experiment(self, language: str, msg_len: str, format_type='txt'):
        # исходные данные
        plain_text = self.generate_test_text(language, 900)  # подлиннее, чтобы SPACE имел шанс
        secret = self.generate_test_message(msg_len)

        # подготовим файл-носитель по формату
        carrier_file = f"carrier_{language}.{format_type}"
        if format_type == 'txt':
            with open(carrier_file, "w", encoding="utf-8") as f:
                f.write(plain_text)
            read_carrier = lambda: open(carrier_file, encoding="utf-8").read()
            save_encoded = lambda fn, s: open(fn, "w", encoding="utf-8").write(s)
        elif format_type == 'html':
            save_as_html(carrier_file, plain_text)
            read_carrier = lambda: read_html(carrier_file)
            save_encoded = lambda fn, s: save_as_html(fn, s)
        elif format_type == 'pdf':
            save_as_pdf(carrier_file, plain_text)
            read_carrier = lambda: read_pdf(carrier_file)
            save_encoded = lambda fn, s: save_as_pdf(fn, s)
        else:
            raise ValueError("Unknown format")

        carrier_text = read_carrier()

        row = {
            'language': language,
            'message_len': msg_len,
            'format': format_type,
            'carrier_len': len(carrier_text),
            'secret_len': len(secret),
            'secret': secret
        }

        for method in ['space', 'zero_width']:
            # Особое правило: ZW + PDF → не поддерживаем (FPDF/Latin-1/вычищение)
            if format_type == 'pdf' and method == 'zero_width':
                row.update({
                    f'{method}_encode_time': 0.0,
                    f'{method}_decode_time': 0.0,
                    f'{method}_visibility': 0.0,
                    f'{method}_security': 0.0,
                    f'{method}_success_rate': 0.0,
                    f'{method}_success': False,
                    f'{method}_decoded': "",
                })
                continue

            # encode
            stego, t_enc, ok_enc = self.measure(method, carrier_text, secret, 'encode')

            if ok_enc and stego:
                # сохраняем в файл формата, потом читаем обратно (реалистичная деградация)
                enc_file = f"encoded_{method}_{format_type}.{format_type}"
                save_encoded(enc_file, stego)
                # вернёмся к тексту из файла (важно для HTML/PDF)
                reloaded = read_carrier() if enc_file.startswith("carrier") else (
                    open(enc_file, encoding="utf-8").read() if format_type == 'txt'
                    else read_html(enc_file) if format_type == 'html'
                    else read_pdf(enc_file)
                )
                # decode
                decoded, t_dec, ok_dec = self.measure(method, reloaded, '', 'decode')

                vis = self.analyze_visibility(carrier_text, stego, method)
                sec = self.analyze_security(stego, method)
                success = (decoded == secret) if ok_dec else False

                row.update({
                    f'{method}_encode_time': t_enc,
                    f'{method}_decode_time': t_dec,
                    f'{method}_visibility': vis,
                    f'{method}_security': sec,
                    f'{method}_success_rate': 1.0 if success else 0.0,
                    f'{method}_success': success,
                    f'{method}_decoded': decoded or ""
                })
            else:
                # не получилось закодировать (например, мало пробелов)
                row.update({
                    f'{method}_encode_time': t_enc,
                    f'{method}_decode_time': 0.0,
                    f'{method}_visibility': 1.0,
                    f'{method}_security': 0.0,
                    f'{method}_success_rate': 0.0,
                    f'{method}_success': False,
                    f'{method}_decoded': ""
                })

        self.results.append(row)
        return row

    # --- серия экспериментов (≥20), перебираем язык × длину × формат ---
    def run_comprehensive_experiments(self, num_experiments=24):
        languages = ['russian', 'english']
        msg_lengths = ['short', 'medium', 'long']
        formats = ['txt', 'html', 'pdf']
        print("Запуск комплексных экспериментов...")
        i = 0
        while i < num_experiments:
            for lang in languages:
                for ml in msg_lengths:
                    for fmt in formats:
                        if i >= num_experiments:
                            break
                        self.run_experiment(lang, ml, fmt)
                        i += 1
                        print(f"Эксперимент {i}/{num_experiments}: lang={lang}, len={ml}, fmt={fmt}")
                    if i >= num_experiments: break
                if i >= num_experiments: break
        print(f"Все эксперименты завершены! Всего: {len(self.results)}")

    # --- графики ---
    def _arr(self, key): 
        return [r.get(key, 0) for r in self.results]

    def create_histograms(self):
        if not self.results:
            print("Нет данных для графиков")
            return

        plt.figure(figsize=(14, 10))
        plt.suptitle('Сравнительный анализ: Space vs Zero-Width', fontsize=16, fontweight='bold')

        plt.subplot(2, 2, 1)
        plt.hist([self._arr('space_encode_time'), self._arr('zero_width_encode_time')],
                 bins=10, alpha=0.7, label=['Space', 'Zero-Width'])
        plt.title('Время кодирования'); plt.xlabel('сек'); plt.ylabel('эксперименты'); plt.legend(); plt.grid(alpha=0.3)

        plt.subplot(2, 2, 2)
        plt.hist([self._arr('space_decode_time'), self._arr('zero_width_decode_time')],
                 bins=10, alpha=0.7, label=['Space', 'Zero-Width'])
        plt.title('Время декодирования'); plt.xlabel('сек'); plt.ylabel('эксперименты'); plt.legend(); plt.grid(alpha=0.3)

        plt.subplot(2, 2, 3)
        plt.hist([self._arr('space_visibility'), self._arr('zero_width_visibility')],
                 bins=10, alpha=0.7, label=['Space', 'Zero-Width'])
        plt.title('Заметность (меньше = лучше)'); plt.xlabel('уровень'); plt.ylabel('эксперименты'); plt.legend(); plt.grid(alpha=0.3)

        plt.subplot(2, 2, 4)
        plt.hist([self._arr('space_security'), self._arr('zero_width_security')],
                 bins=10, alpha=0.7, label=['Space', 'Zero-Width'])
        plt.title('Безопасность (больше = лучше)'); plt.xlabel('уровень'); plt.ylabel('эксперименты'); plt.legend(); plt.grid(alpha=0.3)

        plt.tight_layout(rect=[0, 0, 1, 0.96])
        plt.savefig('steganography_histograms.png', dpi=300)
        plt.close()

        # комбинированная сравнительная диаграмма (успешность)
        space_success = sum(1 for r in self.results if r.get('space_success')) / len(self.results)
        zw_success = sum(1 for r in self.results if r.get('zero_width_success')) / len(self.results)

        plt.figure(figsize=(6, 5))
        bars = plt.bar(['Space', 'Zero-Width'], [space_success, zw_success], alpha=0.8)
        for b, v in zip(bars, [space_success, zw_success]):
            plt.text(b.get_x() + b.get_width()/2, v + 0.01, f'{v:.0%}', ha='center', va='bottom')
        plt.ylim(0, 1)
        plt.title('Доля успешных извлечений'); plt.ylabel('доля')
        plt.grid(axis='y', alpha=0.3)
        plt.tight_layout()
        plt.savefig('steganography_success.png', dpi=300)
        plt.close()

    # --- отчёт ---
    def generate_report(self):
        if not self.results:
            print("Нет данных для отчёта")
            return

        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        with open(f'steganography_results_{ts}.json', 'w', encoding='utf-8') as f:
            json.dump(self.results, f, ensure_ascii=False, indent=2)

        space_ok = sum(1 for r in self.results if r.get('space_success'))
        zw_ok = sum(1 for r in self.results if r.get('zero_width_success'))
        total = len(self.results)

        print("\n" + "="*72)
        print("ОТЧЁТ ПО СРАВНИТЕЛЬНОМУ АНАЛИЗУ")
        print("="*72)
        print(f"Всего экспериментов: {total}")
        print(f"Успешность Space:       {space_ok/total:.1%} ({space_ok}/{total})")
        print(f"Успешность Zero-Width:  {zw_ok/total:.1%} ({zw_ok}/{total})")

        # основные выводы:
        print("\nВЫВОДЫ:")
        print("- Space-метод чувствителен к форматированию (особенно HTML/PDF → нормализация пробелов).")
        print("- Zero-Width устойчив в TXT/HTML; для PDF не поддерживается стандартным FPDF (Latin-1/очистка).")
        print("- Для реальной переписки/HTML-страниц Zero-Width даёт лучшую скрытность и надёжность.")
        print("- Для Space-метода критично обеспечить достаточное кол-во пробелов и отсутствие пост-обработки.")

        print("\nФайлы сохранены:")
        print(f"- steganography_results_{ts}.json")
        print("- steganography_histograms.png")
        print("- steganography_success.png")

    # --- запуск всего процесса ---
    def run_all(self, n_experiments=24):
        self.run_comprehensive_experiments(n_experiments)
        self.create_histograms()
        self.generate_report()



# ======== Точка входа ========

def plot_avg_bars(results):
    space_enc = np.mean([r.get('space_encode_time', 0) for r in results])
    zw_enc    = np.mean([r.get('zero_width_encode_time', 0) for r in results])
    space_dec = np.mean([r.get('space_decode_time', 0) for r in results])
    zw_dec    = np.mean([r.get('zero_width_decode_time', 0) for r in results])

    # --- График 1: среднее время встраивания ---
    plt.figure(figsize=(6, 4))
    plt.bar(['Space Stego', 'Zero-Width Stego'],
            [space_enc, zw_enc],
            color=['#FFA500', '#6A5ACD'])
    plt.title("Практическое задание №4 — сравнительный анализ методов стеганографии\n"
              "Среднее время встраивания (encode)")
    plt.ylabel("Время (сек)")
    plt.grid(True, axis='y', linestyle='--', alpha=0.4)
    for i, v in enumerate([space_enc, zw_enc]):
        plt.text(i, v + v*0.05, f"{v:.6f}", ha='center', va='bottom', fontsize=9, fontweight='bold')
    plt.tight_layout()
    plt.savefig("avg_encode_time.png", dpi=300)
    plt.close()

    # --- График 2: среднее время извлечения ---
    plt.figure(figsize=(6, 4))
    plt.bar(['Space Stego', 'Zero-Width Stego'],
            [space_dec, zw_dec],
            color=['#2E8B57', '#20B2AA'])
    plt.title("Практическое задание №4 — сравнительный анализ методов стеганографии\n"
              "Среднее время извлечения (decode)")
    plt.ylabel("Время (сек)")
    plt.grid(True, axis='y', linestyle='--', alpha=0.4)
    for i, v in enumerate([space_dec, zw_dec]):
        plt.text(i, v + v*0.05, f"{v:.6f}", ha='center', va='bottom', fontsize=9, fontweight='bold')
    plt.tight_layout()
    plt.savefig("avg_decode_time.png", dpi=300)
    plt.close()

    print("✅ Графики сохранены: avg_encode_time.png, avg_decode_time.png")


if __name__ == "__main__":
    analyzer = SteganographyAnalyzer()
    # по требованиям ≥20 экспериментов; здесь 24
    analyzer.run_all(n_experiments=24)
    # строим бар-графики в новом стиле
    plot_avg_bars(analyzer.results)
    print("\nГотово ✅  (графики и JSON рядом со скриптом)")
