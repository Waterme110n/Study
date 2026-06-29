import difflib
import unicodedata
import math


# Helper functions
def text_to_bin(text):
    """Convert text message to binary string."""
    return ''.join(format(ord(c), '08b') for c in text)


def bin_to_text(binary):
    """Convert binary string back to text."""
    if len(binary) % 8 != 0:
        print("Предупреждение: Длина бинарной строки не кратна 8, может быть усечена.")
    return ''.join(chr(int(binary[i:i + 8], 2)) for i in range(0, len(binary), 8))


# Space Steganography
def embed_space(original_text, message):
    """Embed message into text using space steganography."""
    binary = text_to_bin(message)
    words = original_text.split()
    num_intervals_needed = len(binary)
    num_intervals_available = len(words) - 1

    if num_intervals_available < num_intervals_needed:
        # Calculate repeats needed
        repeats = math.ceil((num_intervals_needed + 1) / len(words))
        words = words * repeats

    # Trim to exact needed words: num_intervals_needed + 1
    words = words[:num_intervals_needed + 1]

    stego = words[0]
    for i, bit in enumerate(binary):
        if bit == '0':
            stego += ' ' + words[i + 1]
        else:
            stego += '  ' + words[i + 1]
    return stego


def extract_space(stego_text):
    """Extract message from space stego text."""
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
                if space_count == 1:
                    binary += '0'
                elif space_count >= 2:
                    binary += '1'
                in_space = False
                space_count = 0
        i += 1
    # If trailing spaces, ignore
    return bin_to_text(binary)


# Zero-Width Steganography
ZW_SPACE = '\u200B'  # Zero Width Space for '0'
ZW_NON_JOINER = '\u200C'  # Zero Width Non-Joiner for '1'


def embed_zero(original_text, message):
    """Embed message into text using zero-width characters."""
    binary = text_to_bin(message)
    # Insert at the end for simplicity; visually unchanged
    hidden = ''.join(ZW_SPACE if b == '0' else ZW_NON_JOINER for b in binary)
    return original_text + hidden


def extract_zero(stego_text):
    """Extract message from zero-width stego text."""
    binary = ''
    for c in stego_text:
        if c == ZW_SPACE:
            binary += '0'
        elif c == ZW_NON_JOINER:
            binary += '1'
    return bin_to_text(binary)


# Detection functions
def detect_space(stego_text):
    """Detect if space steganography is likely used (checks for double spaces)."""
    return '  ' in stego_text


def detect_zero(stego_text):
    """Detect if zero-width steganography is used."""
    for c in stego_text:
        if c in (ZW_SPACE, ZW_NON_JOINER):
            return True
    return False


# Change calculation
def count_changes(original, stego):
    """Count changes using difflib.ndiff."""
    diff = list(difflib.ndiff(original, stego))
    changes = len([d for d in diff if d.startswith('+') or d.startswith('-')])
    return changes


# Example usage
if __name__ == "__main__":
    # Texts
    english_text = "This is a sample text that has many words so we can embed a message using spaces between them without issues."
    russian_text = "Это образец текста который имеет много слов чтобы мы могли внедрить сообщение используя пробелы между ними без проблем."

    # Messages
    short_msg = "hi"  # 16 bits
    medium_msg = "secret message"  # 112 bits
    long_msg = "This is a longer secret message to hide in the text using steganography methods."  # 632 bits

    # List for experiments
    experiments = [
        ("Английский", "Короткое", english_text, short_msg),
        ("Английский", "Среднее", english_text, medium_msg),
        ("Английский", "Длинное", english_text, long_msg),
        ("Русский", "Короткое", russian_text, short_msg),
        ("Русский", "Среднее", russian_text, medium_msg),
        ("Русский", "Длинное", russian_text, long_msg),
    ]

    for lang, length, text, msg in experiments:
        print(f"\n--- {lang} - {length} Сообщение ---")
        print("Исходный текст:", text)
        print("Сообщение:", msg)

        # Space Steganography
        space_stego = embed_space(text, msg)
        space_extracted = extract_space(space_stego)
        space_changes = count_changes(text, space_stego)
        space_detected = detect_space(space_stego)

        print("\nСтеготекст с пробелами (визуально могут быть видны дополнительные пробелы):", space_stego)
        print("Извлечённое из пробелов:", space_extracted)
        print("Изменения (пробелы):", space_changes)
        print("Обнаружено (пробелы):", space_detected)

        # Zero-Width Steganography
        zero_stego = embed_zero(text, msg)
        zero_extracted = extract_zero(zero_stego)
        zero_changes = count_changes(text, zero_stego)
        zero_detected = detect_zero(zero_stego)

        print("\nСтеготекст с нулевой шириной (визуально идентичен):", zero_stego)  # ZW chars invisible
        print("Извлечённое из нулевой ширины:", zero_extracted)
        print("Изменения (нулевая ширина):", zero_changes)
        print("Обнаружено (нулевая ширина):", zero_detected)