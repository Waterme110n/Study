# -*- coding: utf-8 -*-
import re, time, math
import pandas as pd
import matplotlib.pyplot as plt

# ==============================
# 1) ТЕКСТЫ ДЛЯ ЭКСПЕРИМЕНТОВ
# ==============================

EN_TEXT = (
    "The quick brown fox jumps over the lazy dog. "
    "In cryptography, steganography hides information in plain sight without "
    "attracting attention. Practical tasks often require measuring detectability, "
    "robustness, and performance across formats like TXT, HTML, and PDF."
)

RU_TEXT = (
    "Съешь ещё этих мягких французских булок да выпей чаю. "
    "В криптографии стеганография скрывает сообщение прямо на виду, "
    "не привлекая лишнего внимания. На практике важно оценивать "
    "обнаруживаемость, устойчивость и производительность в форматах TXT, HTML и PDF."
)

BASE_TEXTS = {"en": EN_TEXT, "ru": RU_TEXT}

def ensure_capacity_text(text: str, needed_slots: int, slots_per_copy: int, sep: str = " ") -> str:
    if slots_per_copy <= 0:
        return text
    copies = max(1, math.ceil(needed_slots / slots_per_copy))
    return " ".join([text] * copies)

# ==============================
# 2) «ПРЕОБРАЗОВАНИЯ ФОРМАТОВ»
# ==============================

ZW_PATTERN = r"[\\u200b\\u200c\\u200d\\u2060\\ufeff]"

def fmt_txt_identity(s: str) -> str:
    return s

def fmt_html_like(s: str) -> str:
    import re
    s = re.sub(r"[ \\t]+", " ", s)
    s = re.sub(r" ?\\n ?", " ", s)
    s = re.sub(r" {2,}", " ", s)
    s = "\\n".join([line.rstrip(" ") for line in s.splitlines()])
    return s

def fmt_pdf_like(s: str) -> str:
    import re
    s = re.sub(ZW_PATTERN, "", s)
    s = "\\n".join([line.rstrip(" ") for line in s.splitlines()])
    return s

FORMATS = {"txt": fmt_txt_identity, "html": fmt_html_like, "pdf": fmt_pdf_like}

# ==============================
# 3) КОДИРОВАНИЕ СООБЩЕНИЙ
# ==============================

def bytes_to_bits(b: bytes):
    return [(byte >> i) & 1 for byte in b for i in range(7, -1, -1)]

def bits_to_bytes(bits):
    if len(bits) % 8 != 0:
        bits = bits + [0] * (8 - len(bits) % 8)
    out = bytearray()
    for i in range(0, len(bits), 8):
        byte = 0
        for j in range(8):
            byte = (byte << 1) | bits[i + j]
        out.append(byte)
    return bytes(out)

def pack_message(msg: str):
    data = msg.encode("utf-8")
    length = len(data)
    header = length.to_bytes(2, "big")
    return bytes_to_bits(header + data)

def unpack_message(bits):
    raw = bits_to_bytes(bits)
    if len(raw) < 2:
        return ""
    length = int.from_bytes(raw[:2], "big")
    payload = raw[2:2+length]
    try:
        return payload.decode("utf-8", errors="ignore")
    except:
        return ""

# ==============================
# 4) SPACE STEGANOGRAPHY
# ==============================

def space_embed(text: str, msg: str):
    bits = pack_message(msg)
    parts = re.split(r"(\\s+)", text)
    idxs = [i for i, tok in enumerate(parts) if re.fullmatch(r"[ ]", tok)]
    changed = 0
    for bit_i, pos in enumerate(idxs):
        if bit_i >= len(bits):
            break
        if bits[bit_i] == 1 and parts[pos] == " ":
            parts[pos] = "  "
            changed += 1
        elif bits[bit_i] == 0 and parts[pos] != " ":
            parts[pos] = " "
            changed += 1
    return "".join(parts), changed

def space_extract(stego: str):
    parts = re.split(r"(\\s+)", stego)
    idxs = [i for i, tok in enumerate(parts) if re.fullmatch(r"[ ]{1,2}", tok)]
    bits = []
    for pos in idxs:
        tok = parts[pos]
        if tok == " ":
            bits.append(0)
        elif tok == "  ":
            bits.append(1)
    return unpack_message(bits)

def space_detectability_score(s: str) -> float:
    groups = re.findall(r"[ ]{1,}", s)
    if not groups:
        return 0.0
    doubles = sum(1 for g in groups if len(g) >= 2)
    return doubles / len(groups)

# ==============================
# 5) ZERO-WIDTH STEGANOGRAPHY
# ==============================

ZW0 = "\\u200b"
ZW1 = "\\u200c"
START = "\\u2060\\u2060"
END = "\\u2060\\u2060\\u2060"

def zw_embed(text: str, msg: str):
    bits = pack_message(msg)
    capacity = max(0, len(text)-1)
    out = []
    changed = 0
    bi = 0
    for i, ch in enumerate(text):
        out.append(ch)
        if bi < len(bits) and i < len(text) - 1:
            out.append(ZW1 if bits[bi] else ZW0)
            changed += 1
            bi += 1
    payload = START + "".join(out) + END
    return payload, changed

def zw_extract(s: str):
    m = re.search(re.escape(START) + r"(.*?)" + re.escape(END), s, flags=re.S)
    if not m:
        return ""
    core = m.group(1)
    bits = []
    # читаем каждый второй символ как будто между ними был zero-width
    for i in range(len(core)-1):
        ch = core[i+1]
        if ch == ZW0:
            bits.append(0)
        elif ch == ZW1:
            bits.append(1)
    return unpack_message(bits)

def zw_detectability_score(s: str) -> float:
    total = max(1, len(s))
    cnt = len(re.findall(ZW_PATTERN, s))
    return cnt / total

# ==============================
# 6) ЭКСПЕРИМЕНТАЛЬНЫЙ СТЕНД
# ==============================

def measure(func, *args, **kw):
    t0 = time.perf_counter()
    result = func(*args, **kw)
    t1 = time.perf_counter()
    return result, (t1 - t0)

def run_single_experiment(method: str, lang: str, target_format: str, message_len: int):
    base = BASE_TEXTS[lang]
    if method == "space":
        slots = len(re.findall(r" ", base))
        prepared = ensure_capacity_text(base, message_len*8 + 16*8, max(1, slots))
        embed_fn, extract_fn = space_embed, space_extract
        detect_fn = space_detectability_score
    else:
        slots = max(0, len(base)-1)
        prepared = ensure_capacity_text(base, message_len*8 + 16*8, max(1, slots))
        embed_fn, extract_fn = zw_embed, zw_extract
        detect_fn = zw_detectability_score

    message = ("А"*message_len) if lang == "ru" else ("A"*message_len)

    (stego, changed), t_embed = measure(embed_fn, prepared, message)
    transformed = FORMATS[target_format](stego)
    (extracted), t_extract = measure(extract_fn, transformed)

    success = (extracted == message)
    added_chars = len(stego) - len(prepared)
    change_ratio = added_chars / max(1, len(prepared))
    detect_score_before = detect_fn(stego)
    detect_score_after = detect_fn(transformed)

    return {
        "method": method,
        "lang": lang,
        "format": target_format,
        "message_len": message_len,
        "success": success,
        "t_embed_ms": t_embed * 1000.0,
        "t_extract_ms": t_extract * 1000.0,
        "added_chars": added_chars,
        "change_ratio": change_ratio,
        "detect_score_before": detect_score_before,
        "detect_score_after": detect_score_after,
    }

def run_full_suite():
    methods = ["space", "zw"]
    langs = ["en", "ru"]
    formats = ["txt", "html", "pdf"]
    msg_sizes = [16, 128, 512]
    rows = []
    for m in methods:
        for L in langs:
            for f in formats:
                for s in msg_sizes:
                    rows.append(run_single_experiment(m, L, f, s))
    return pd.DataFrame(rows)

def main():
    df = run_full_suite()
    df.to_csv("stego_experiments.csv", index=False)

    summary = df.groupby("method").agg(
        success_rate=("success", "mean"),
        avg_t_embed_ms=("t_embed_ms", "mean"),
        avg_t_extract_ms=("t_extract_ms", "mean"),
        avg_change_ratio=("change_ratio", "mean"),
        avg_detect_after=("detect_score_after", "mean"),
    ).reset_index()
    summary.to_csv("stego_summary.csv", index=False)

    # Визуализации
    plt.figure()
    for method in df["method"].unique():
        vals = df[df["method"] == method]["t_embed_ms"]
        plt.hist(vals, alpha=0.5, bins=10, label=method)
    plt.xlabel("Время встраивания, мс")
    plt.ylabel("Частота")
    plt.title("Гистограмма времени встраивания по методам")
    plt.legend()
    plt.tight_layout()
    plt.savefig("hist_embed_time.png", dpi=160)

    plt.figure()
    for method in df["method"].unique():
        vals = df[df["method"] == method]["t_extract_ms"]
        plt.hist(vals, alpha=0.5, bins=10, label=method)
    plt.xlabel("Время извлечения, мс")
    plt.ylabel("Частота")
    plt.title("Гистограмма времени извлечения по методам")
    plt.legend()
    plt.tight_layout()
    plt.savefig("hist_extract_time.png", dpi=160)

    plt.figure()
    for method in df["method"].unique():
        vals = df[df["method"] == method]["change_ratio"]
        plt.hist(vals, alpha=0.5, bins=10, label=method)
    plt.xlabel("Относительное изменение длины текста")
    plt.ylabel("Частота")
    plt.title("Искажение текста после встраивания (change_ratio)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("hist_change_ratio.png", dpi=160)

    plt.figure()
    for method in df["method"].unique():
        vals = df[df["method"] == method]["detect_score_after"]
        plt.hist(vals, alpha=0.5, bins=10, label=method)
    plt.xlabel("Эвристическая заметность после формата")
    plt.ylabel("Частота")
    plt.title("Заметность стегосообщения после формат-преобразования")
    plt.legend()
    plt.tight_layout()
    plt.savefig("hist_detect_after.png", dpi=160)

    # Консольные итоги
    print("Сохранено: stego_experiments.csv, stego_summary.csv и 4 PNG-гистограммы.")

if __name__ == "__main__":
    main()
