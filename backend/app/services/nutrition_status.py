"""
nutrition_status.py — Klasifikasi status gizi bayi (weight-for-length)
berdasarkan WHO Child Growth Standards 2006 + Permenkes No. 2 Tahun 2020.

Sumber angka: Klasifikasi_Status_Gizi_Bayi_0-2Tahun.xlsx (udah di-verify
manual — threshold table-nya konsisten/monoton, nilai median cocok sama
tabel WHO resmi). Ambang batas BB (kg) per PB (cm), tiap 5cm dari 45-110cm.

PENTING: file ini HARUS identik di rumi-rag dan rumi (baseline) backend,
sama kayak prompts.py — biar hasil status gizi ga beda antara dua versi
dan ga ngerusak validitas perbandingan RAGAS.
"""

# format tiap row: panjang_cm: (-3SD, -2SD, -1SD, median, +1SD, +2SD, +3SD)
# urutan kolom HARUS tetep gini, dipakai langsung sebagai tuple index di bawah

THRESHOLDS_BOYS = {
    45:  (1.9, 2.0, 2.2, 2.4, 2.7, 3.0, 3.3),
    50:  (2.6, 2.8, 3.0, 3.3, 3.6, 4.0, 4.4),
    55:  (3.6, 3.8, 4.2, 4.5, 5.0, 5.4, 6.0),
    60:  (4.7, 5.1, 5.5, 6.0, 6.5, 7.1, 7.8),
    65:  (5.7, 6.2, 6.7, 7.3, 7.9, 8.6, 9.4),
    70:  (6.6, 7.2, 7.8, 8.4, 9.2, 10.0, 10.9),
    75:  (7.5, 8.1, 8.8, 9.5, 10.3, 11.3, 12.3),
    80:  (8.2, 8.9, 9.6, 10.4, 11.4, 12.4, 13.6),
    85:  (9.1, 9.8, 10.6, 11.5, 12.5, 13.6, 14.9),
    90:  (10.1, 10.9, 11.8, 12.7, 13.8, 15.0, 16.4),
    95:  (11.0, 11.9, 12.8, 13.9, 15.1, 16.4, 17.9),
    100: (12.0, 12.9, 14.0, 15.2, 16.5, 18.0, 19.6),
    105: (13.0, 14.1, 15.3, 16.6, 18.1, 19.8, 21.7),
    110: (14.2, 15.4, 16.8, 18.3, 20.0, 21.9, 24.1),
}

THRESHOLDS_GIRLS = {
    45:  (1.9, 2.1, 2.3, 2.5, 2.7, 3.0, 3.3),
    50:  (2.6, 2.8, 3.1, 3.4, 3.7, 4.0, 4.5),
    55:  (3.5, 3.8, 4.2, 4.5, 5.0, 5.5, 6.1),
    60:  (4.5, 4.9, 5.4, 5.9, 6.4, 7.1, 7.8),
    65:  (5.5, 5.9, 6.5, 7.1, 7.8, 8.6, 9.5),
    70:  (6.3, 6.9, 7.5, 8.2, 9.0, 9.9, 10.9),
    75:  (7.1, 7.7, 8.4, 9.1, 10.0, 11.0, 12.2),
    80:  (7.8, 8.5, 9.2, 10.1, 11.1, 12.1, 13.4),
    85:  (8.7, 9.4, 10.3, 11.2, 12.3, 13.5, 14.9),
    90:  (9.7, 10.5, 11.4, 12.5, 13.7, 15.0, 16.5),
    95:  (10.6, 11.5, 12.6, 13.7, 15.0, 16.5, 18.2),
    100: (11.6, 12.6, 13.7, 15.0, 16.5, 18.1, 20.0),
    105: (12.7, 13.8, 15.1, 16.5, 18.2, 20.0, 22.2),
    110: (14.0, 15.3, 16.7, 18.3, 20.2, 22.3, 24.7),
}

MIN_LENGTH_CM = 45
MAX_LENGTH_CM = 110


def _interpolate_thresholds(height: float, table: dict) -> tuple:
    """
    Cari 7 nilai ambang batas (SD -3 s/d +3) buat panjang badan yang
    sebenernya (ga harus pas kelipatan 5cm). Linear interpolation antara
    2 row terdekat di tabel.

    kalo height di luar 45-110cm, di-clamp ke batas terdekat — jarang
    kejadian buat bayi 0-2 tahun, tapi dari pada crash/nilai ngaco.
    """
    # clamp dulu, biar ga keluar rentang tabel yang kita punya
    h = max(MIN_LENGTH_CM, min(MAX_LENGTH_CM, height))

    lower_cm = (int(h) // 5) * 5
    upper_cm = lower_cm + 5

    if lower_cm not in table:
        lower_cm = MIN_LENGTH_CM
    if upper_cm not in table:
        upper_cm = MAX_LENGTH_CM

    if lower_cm == upper_cm:
        return table[lower_cm]

    # posisi height di antara dua row (0.0 = pas di lower, 1.0 = pas di upper)
    fraction = (h - lower_cm) / (upper_cm - lower_cm)

    lower_vals = table[lower_cm]
    upper_vals = table[upper_cm]

    return tuple(
        lo + (hi - lo) * fraction
        for lo, hi in zip(lower_vals, upper_vals)
    )


def _classify_weight(weight: float, thresholds: tuple) -> str:
    """
    Bandingin berat badan ke 7 ambang batas, balikin label sesuai
    Permenkes No. 2/2020. Batas pake aturan inklusif-bawah
    (persis kayak definisi kategorinya, misal "-2 SD s.d. +1 SD" =
    [-2, +1] ketutup di kedua ujung) — ini yang kemaren bikin matrix
    excel-nya salah di beberapa cell pas weight-nya pas di garis batas.
    """
    m3, m2, m1, median, p1, p2, p3 = thresholds

    if weight < m3:
        return "Gizi Buruk"
    if weight < m2:
        return "Gizi Kurang"
    if weight <= p1:
        return "Gizi Baik"
    if weight <= p2:
        return "Risiko Gizi Lebih"
    if weight <= p3:
        return "Gizi Lebih"
    return "Obesitas"


def get_nutrition_status(weight: float, height: float, gender: str) -> str:
    """
    Entry point utama. Dipanggil dari gemini_service.py sebelum bangun
    prompt — hasilnya di-inject ke prompt sebagai fakta, BUKAN disuruh
    Gemini nebak sendiri dari angka mentah.

    gender: "Male" / "Female" (case-insensitive, sesuai Firestore schema)
    """
    gender_normalized = gender.strip().lower()

    if gender_normalized == "male":
        table = THRESHOLDS_BOYS
    elif gender_normalized == "female":
        table = THRESHOLDS_GIRLS
    else:
        # jangan diem-diem nebak gender kalo datanya ga sesuai ekspektasi —
        # mending keliatan error-nya dari pada hasil klasifikasi salah
        raise ValueError(f"Unknown gender value: {gender!r} (expected 'Male' or 'Female')")

    thresholds = _interpolate_thresholds(height, table)
    return _classify_weight(weight, thresholds)
