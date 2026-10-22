// --- Tabel ambang batas status gizi (WHO 2006 + Permenkes No. 2/2020) ---
// HARUS identik sama nutrition_status.py di backend, biar hasil klasifikasi
// ga beda antara tag Flutter (live) sama weekly_summary (backend)
// Format: panjang_cm -> [-3SD, -2SD, -1SD, median, +1SD, +2SD, +3SD]
const Map<int, List<double>> _thresholdsBoys = {
  45: [1.9, 2.0, 2.2, 2.4, 2.7, 3.0, 3.3],
  50: [2.6, 2.8, 3.0, 3.3, 3.6, 4.0, 4.4],
  55: [3.6, 3.8, 4.2, 4.5, 5.0, 5.4, 6.0],
  60: [4.7, 5.1, 5.5, 6.0, 6.5, 7.1, 7.8],
  65: [5.7, 6.2, 6.7, 7.3, 7.9, 8.6, 9.4],
  70: [6.6, 7.2, 7.8, 8.4, 9.2, 10.0, 10.9],
  75: [7.5, 8.1, 8.8, 9.5, 10.3, 11.3, 12.3],
  80: [8.2, 8.9, 9.6, 10.4, 11.4, 12.4, 13.6],
  85: [9.1, 9.8, 10.6, 11.5, 12.5, 13.6, 14.9],
  90: [10.1, 10.9, 11.8, 12.7, 13.8, 15.0, 16.4],
  95: [11.0, 11.9, 12.8, 13.9, 15.1, 16.4, 17.9],
  100: [12.0, 12.9, 14.0, 15.2, 16.5, 18.0, 19.6],
  105: [13.0, 14.1, 15.3, 16.6, 18.1, 19.8, 21.7],
  110: [14.2, 15.4, 16.8, 18.3, 20.0, 21.9, 24.1],
};

const Map<int, List<double>> _thresholdsGirls = {
  45: [1.9, 2.1, 2.3, 2.5, 2.7, 3.0, 3.3],
  50: [2.6, 2.8, 3.1, 3.4, 3.7, 4.0, 4.5],
  55: [3.5, 3.8, 4.2, 4.5, 5.0, 5.5, 6.1],
  60: [4.5, 4.9, 5.4, 5.9, 6.4, 7.1, 7.8],
  65: [5.5, 5.9, 6.5, 7.1, 7.8, 8.6, 9.5],
  70: [6.3, 6.9, 7.5, 8.2, 9.0, 9.9, 10.9],
  75: [7.1, 7.7, 8.4, 9.1, 10.0, 11.0, 12.2],
  80: [7.8, 8.5, 9.2, 10.1, 11.1, 12.1, 13.4],
  85: [8.7, 9.4, 10.3, 11.2, 12.3, 13.5, 14.9],
  90: [9.7, 10.5, 11.4, 12.5, 13.7, 15.0, 16.5],
  95: [10.6, 11.5, 12.6, 13.7, 15.0, 16.5, 18.2],
  100: [11.6, 12.6, 13.7, 15.0, 16.5, 18.1, 20.0],
  105: [12.7, 13.8, 15.1, 16.5, 18.2, 20.0, 22.2],
  110: [14.0, 15.3, 16.7, 18.3, 20.2, 22.3, 24.7],
};

const double _minLengthCm = 45;
const double _maxLengthCm = 110;

// cari 7 nilai ambang batas (SD -3 s/d +3) buat panjang badan yang
// sebenernya (ga harus pas kelipatan 5cm) — interpolasi linear antara
// 2 row terdekat di tabel
List<double> _interpolateThresholds(
  double height,
  Map<int, List<double>> table,
) {
  // clamp dulu biar ga keluar rentang tabel yang kita punya
  final h = height.clamp(_minLengthCm, _maxLengthCm);

  final lowerCm =
      (h ~/ 5) * 5; // pembagian bulat ke kelipatan 5 terdekat ke bawah
  final upperCm = lowerCm + 5;

  final lowerKey = table.containsKey(lowerCm) ? lowerCm : _minLengthCm.toInt();
  final upperKey = table.containsKey(upperCm) ? upperCm : _maxLengthCm.toInt();

  if (lowerKey == upperKey) return table[lowerKey]!;

  // posisi height di antara dua row (0.0 = pas di lower, 1.0 = pas di upper)
  final fraction = (h - lowerKey) / (upperKey - lowerKey);

  final lowerVals = table[lowerKey]!;
  final upperVals = table[upperKey]!;

  return List.generate(
    7,
    (i) => lowerVals[i] + (upperVals[i] - lowerVals[i]) * fraction,
  );
}

// bandingin berat badan ke 7 ambang batas, balikin label sesuai
// Permenkes No. 2/2020 — pake aturan inklusif-bawah, sama persis kayak
// backend (ini yang kemaren benerin bug boundary di matrix excel)
String _classifyWeight(double weight, List<double> thresholds) {
  final m3 = thresholds[0];
  final m2 = thresholds[1];
  final p1 = thresholds[4];
  final p2 = thresholds[5];
  final p3 = thresholds[6];

  if (weight < m3) return 'Gizi Buruk';
  if (weight < m2) return 'Gizi Kurang';
  if (weight <= p1) return 'Gizi Baik';
  if (weight <= p2) return 'Risiko Gizi Lebih';
  if (weight <= p3) return 'Gizi Lebih';
  return 'Obesitas';
}

class Baby {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String gender;
  final double weight;
  final double height;
  final DateTime dateOfBirth;
  final bool isActive;
  final List<String> allergyIds;
  // apakah bayi lahir prematur (sebelum 37 minggu)
  final bool isPremature;
  // usia gestasi dalam minggu saat lahir, hanya relevan jika isPremature == true
  // rumus usia koreksi: usia kronologis - (40 - gestationalAgeWeeks) minggu
  final int? gestationalAgeWeeks;
  // apakah bayi masih aktif menyusu ASI bersamaan dengan MPASI
  // mempengaruhi slot rekomendasi (slot ASI tetap aktif)
  final bool isActivelyBreastfed;
  // perkiraan jumlah gigi saat ini
  final int? toothCount;
  final String? medicalHistory;

  Baby({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.gender,
    required this.weight,
    required this.height,
    required this.dateOfBirth,
    this.isActive = false,
    this.allergyIds = const [],
    this.isPremature = false,
    this.gestationalAgeWeeks,
    this.isActivelyBreastfed = true,
    this.toothCount,
    this.medicalHistory,
  });

  // ngitung usia bayi dalam format bulan, dari tanggal lahir
  int get ageInMonths {
    final now = DateTime.now();
    int months =
        (now.year - dateOfBirth.year) * 12 + (now.month - dateOfBirth.month);
    if (now.day < dateOfBirth.day) months--;
    return months.clamp(0, 999);
  }

  // usia koreksi dalam bulan khusus buat bayi prematur
  // kalo ga prematur, langsung kembalikan ageInMonths
  int get correctedAgeInMonths {
    if (!isPremature || gestationalAgeWeeks == null) return ageInMonths;
    final weeksEarly = 40 - gestationalAgeWeeks!;
    final correctedMonths = ageInMonths - (weeksEarly / 4.3).round();
    return correctedMonths.clamp(0, 999);
  }

  String get nutritionStatus {
    final table = gender.trim().toLowerCase() == 'male'
        ? _thresholdsBoys
        : _thresholdsGirls; // kamu bilang gender udah pre-selected, jadi ga perlu throw kayak Python
    final thresholds = _interpolateThresholds(height, table);
    return _classifyWeight(weight, thresholds);
  }

  // ngebantu ambil nama lengkap bayi
  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((part) => part != null && part.isNotEmpty).join(' ');
}
