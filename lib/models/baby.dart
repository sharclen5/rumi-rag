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

  // ngebantu ambil nama lengkap bayi
  String get fullName => [
    firstName,
    middleName,
    lastName,
  ].where((part) => part != null && part.isNotEmpty).join(' ');
}