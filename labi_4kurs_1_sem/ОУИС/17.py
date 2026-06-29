import difflib
import math
import pandas as pd
import time

print(" СТЕГАНОГРАФИЯ: СРАВНЕНИЕ ПРОБЕЛОВ vs НУЛЕВАЯ ШИРИНА")
print("=" * 70)


# 🌟 ОСНОВНЫЕ ФУНКЦИИ СТЕГАНОГРАФИИ
def text_to_bin(text):
    return ''.join(format(ord(c), '08b') for c in text)


def bin_to_text(binary):
    if len(binary) % 8 != 0:
        binary = binary[:-(len(binary) % 8)]
    return ''.join(chr(int(binary[i:i + 8], 2)) for i in range(0, len(binary), 8))


# 📝 МЕТОД 1: ПРОБЕЛЫ
def embed_space(original_text, message):
    binary = text_to_bin(message)
    words = original_text.split()
    num_needed = len(binary)

    if len(words) - 1 < num_needed:
        repeats = math.ceil((num_needed + 1) / len(words))
        words = words * repeats
    words = words[:num_needed + 1]

    stego = words[0]
    for i, bit in enumerate(binary):
        stego += ' ' + words[i + 1] if bit == '0' else '  ' + words[i + 1]
    return stego


def extract_space(stego_text):
    binary = ''
    i = 0
    in_space = False
    space_count = 0
    while i < len(stego_text):
        if stego_text[i].isspace():
            if not in_space:
                in_space = True
                space_count = 1
            else:
                space_count += 1
        else:
            if in_space:
                binary += '0' if space_count == 1 else '1'
                in_space = False
                space_count = 0
        i += 1
    return bin_to_text(binary)


ZW_SPACE = '\u200B'
ZW_NON_JOINER = '\u200C'


def embed_zero(original_text, message):
    binary = text_to_bin(message)
    hidden = ''.join(ZW_SPACE if b == '0' else ZW_NON_JOINER for b in binary)
    return original_text + hidden


def extract_zero(stego_text):
    binary = ''
    for c in stego_text:
        if c == ZW_SPACE:
            binary += '0'
        elif c == ZW_NON_JOINER:
            binary += '1'
    return bin_to_text(binary)


def measure_time(func, *args, n_runs=30):
    total_time = 0.0
    for _ in range(n_runs):
        start = time.perf_counter()
        func(*args)
        total_time += (time.perf_counter() - start)
    return total_time / n_runs * 1000  # миллисекунды


EXPERIMENTS = [
    # АНГЛИЙСКИЙ (9 тестов)
    ("🇺🇸 Короткий", "This is short.", "hi"),
    ("🇺🇸 Короткий", "This is short.", "secret"),
    ("🇺🇸 Короткий", "This is short.", "long msg"),
    ("🇺🇸 Средний", "This is a medium text with more words.", "hi"),
    ("🇺🇸 Средний", "This is a medium text with more words.", "secret"),
    ("🇺🇸 Средний", "This is a medium text with more words.", "long msg"),
    ("🇺🇸 Длинный", "This is a long English text with many words to embed messages.", "hi"),
    ("🇺🇸 Длинный", "This is a long English text with many words to embed messages.", "secret"),
    ("🇺🇸 Длинный", "This is a long English text with many words to embed messages.", "long msg"),

    # РУССКИЙ (9 тестов)
    ("🇷🇺 Короткий", "Это коротко.", "hi"),
    ("🇷🇺 Короткий", "Это коротко.", "секрет"),
    ("🇷🇺 Короткий", "Это коротко.", "длинное"),
    ("🇷🇺 Средний", "Это средний текст с большим количеством слов.", "hi"),
    ("🇷🇺 Средний", "Это средний текст с большим количеством слов.", "секрет"),
    ("🇷🇺 Средний", "Это средний текст с большим количеством слов.", "длинное"),
    ("🇷🇺 Длинный", "Это длинный русский текст с многими словами.", "hi"),
    ("🇷🇺 Длинный", "Это длинный русский текст с многими словами.", "секрет"),
    ("🇷🇺 Длинный", "Это длинный русский текст с многими словами.", "длинное"),

    # ЭКСТРЕМАЛЬНЫЕ (2 теста)
    ("🇺🇸 1 символ", "This is a medium text with more words.", "a"),
    ("🇷🇺 Длинное", "Это коротко.", "Очень длинное сообщение для теста!")
]

print("\n ЗАПУСК 20 ЭКСПЕРИМЕНТОВ...")
print("─" * 90)

results = []
space_success_count = 0
zero_success_count = 0
space_embed_times = []
space_extract_times = []
zero_embed_times = []
zero_extract_times = []

for idx, (test_name, text, msg) in enumerate(EXPERIMENTS, 1):
    msg_len = len(msg)
    print(f"[{idx:2d}/20] {test_name:<20} | Сообщение: {msg_len} символов")

    space_success = False
    space_embed_time = 0.0
    space_extract_time = 0.0
    try:
        space_stego = embed_space(text, msg)
        space_extracted = extract_space(space_stego)
        space_success = space_extracted == msg
        if space_success:
            space_embed_time = measure_time(embed_space, text, msg)
            space_extract_time = measure_time(extract_space, space_stego)
            space_embed_times.append(space_embed_time)
            space_extract_times.append(space_extract_time)
    except:
        pass

    if space_success:
        space_success_count += 1

    # 🟢 НУЛЕВАЯ ШИРИНА
    zero_success = False
    zero_embed_time = 0.0
    zero_extract_time = 0.0
    try:
        zero_stego = embed_zero(text, msg)
        zero_extracted = extract_zero(zero_stego)
        zero_success = zero_extracted == msg
        if zero_success:
            zero_embed_time = measure_time(embed_zero, text, msg)
            zero_extract_time = measure_time(extract_zero, zero_stego)
            zero_embed_times.append(zero_embed_time)
            zero_extract_times.append(zero_extract_time)
    except:
        pass

    if zero_success:
        zero_success_count += 1

    results.append({
        '№': idx,
        'Тест': test_name,
        'Сообщение': msg_len,
        'Пробелы': '✅' if space_success else '❌',
        'Нулевая_ширина': '✅' if zero_success else '❌'
    })

df = pd.DataFrame(results)
print("\n РЕЗУЛЬТАТЫ 20 ЭКСПЕРИМЕНТОВ")
print("=" * 110)
print(df.to_string(index=False))

space_embed_avg = sum(space_embed_times) / len(space_embed_times) if space_embed_times else 0.0
space_extract_avg = sum(space_extract_times) / len(space_extract_times) if space_extract_times else 0.0
zero_embed_avg = sum(zero_embed_times) / len(zero_embed_times) if zero_embed_times else 0.0
zero_extract_avg = sum(zero_extract_times) / len(zero_extract_times) if zero_extract_times else 0.0

print(f"\n ГЛАВНЫЕ РЕЗУЛЬТАТЫ (20 экспериментов):")
print(f"    Метод пробелов:       {space_success_count}/20 = {space_success_count / 20 * 100:.0f}% успеха")
print(f"    Метод нулевой ширины: {zero_success_count}/20 = {zero_success_count / 20 * 100:.0f}% успеха")

if space_embed_times:
    print(f"   ⚡ Встраивание:")
    print(f"      Пробелы:           {space_embed_avg:6.2f} мс")
    print(f"      Нулевая ширина:    {zero_embed_avg:6.2f} мс")
    if zero_embed_avg > 0:
        speedup = space_embed_avg / zero_embed_avg
        print(f"       Нулевая быстрее в {speedup:.1f} раза!")

if space_extract_times:
    print(f"   ⚡ Извлечение:")
    print(f"      Пробелы:           {space_extract_avg:6.2f} мс")
    print(f"      Нулевая ширина:    {zero_extract_avg:6.2f} мс")
    if zero_extract_avg > 0:
        speedup = space_extract_avg / zero_extract_avg
        print(f"       Нулевая быстрее в {speedup:.1f} раза!")