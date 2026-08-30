import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';
import 'package:rumi/shared/nutrition_card.dart';
import 'package:rumi/shared/today_schedule_card.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:rumi/shared/tour_keys.dart';
import 'package:rumi/shared/rag_badge.dart';

class TutorialMark extends StatefulWidget {
  final VoidCallback? onFinished;
  const TutorialMark({super.key, this.onFinished});

  @override
  State<TutorialMark> createState() => _TutorialMarkState();
}

class _TutorialMarkState extends State<TutorialMark> {
  int _currentSection = 0;

  static const String _fakeUid = 'demo_uid';
  static const String _fakeBabyId = 'demo_baby';
  static const String _fakeBabyName = 'Mulyono';
  static const String _fakeBabyLabel = 'Contoh Bayi · 8 bulan';

  // CHANGED: warna palette dark — dipakai konsisten di semua section mimic
  static const _ink = Color(0xFFF2DAB1);
  static const _cardBg = Color(0xFF2A2828);
  static const _cardBorder = Color(0xFF4A4646);
  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const _brandDark = Color.fromARGB(255, 122, 105, 95);

  static const Set<String> _fakeCoveredGroups = {
    'karbohidrat',
    'protein_hewani',
    'sayuran',
  };

  late final Recommendation _fakeRecommendation = Recommendation(
    babyId: _fakeBabyId,
    date: _todayStr(),
    createdAt: DateTime.now(),
    source: 'baseline',
    meals: [
      Meal(time: '06.00', type: 'ASI', isEaten: true),
      Meal(
        time: '08.00',
        type: 'Sarapan',
        name: 'Bubur Ayam Wortel',
        isEaten: true,
      ),
      Meal(time: '10.00', type: 'Snack', name: 'Pisang Kukus', isEaten: false),
      Meal(
        time: '12.00',
        type: 'Makan Siang',
        name: 'Nasi Tim Ikan',
        isEaten: false,
      ),
    ],
  );

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  String _dayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam,';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowcaseView.get().startShowCase([
        TourKeys.demoHomeNavIcon,
        TourKeys.babyDropdown,
        TourKeys.calendarStrip,
        TourKeys.todayScheduleCard,
        TourKeys.nutritionCard,
        TourKeys.aiTipsCard,
        TourKeys.demoRekomendasiNavIcon,
      ]);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentSection(),
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentSection,
        onTap: (i) => setState(() => _currentSection = i),
        onAddRecommendationTap: () {},
        photoUrl: null,
        homeKey: TourKeys.demoHomeNavIcon,
        rekomendasiKey: TourKeys.demoRekomendasiNavIcon,
        addButtonKey: TourKeys.demoAddButton,
        riwayatKey: TourKeys.demoRiwayatNavIcon,
        profileKey: TourKeys.demoProfileNavIcon,
      ),
    );
  }

  Widget _buildCurrentSection() {
    switch (_currentSection) {
      case 1:
        return _buildRekomendasiSection();
      case 3:
        return _buildRiwayatSection();
      case 4:
        return _buildProfileSection();
      default:
        return _buildHomeSection();
    }
  }

  // ---- Home mimic ----
  Widget _buildHomeSection() {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(
          0xFF363434,
        ), // CHANGED: was Color(0xFFF2DAB1)
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF363434),
              Color(0xFF1A1A1A),
            ], // CHANGED: was cream to white
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFakeHomeHero(),
              const SizedBox(height: 20),

              Showcase(
                key: TourKeys.calendarStrip,
                title: 'Kalender',
                description:
                    'Lihat dan pilih tanggal untuk melacak menu harian si kecil',
                child: CalendarStrip(
                  selectedDate: DateTime.now(),
                  onDateSelected: (_) {},
                  uid: _fakeUid,
                  babyId: _fakeBabyId,
                  showCard: true,
                  showArrows: true,
                ),
              ),
              const SizedBox(height: 24),

              Showcase(
                key: TourKeys.todayScheduleCard,
                title: 'Jadwal Menu Hari Ini',
                description:
                    'Lihat menu terjadwal dan tandai kalau sudah dimakan',
                child: TodayScheduleCard(
                  uid: _fakeUid,
                  babyId: _fakeBabyId,
                  onTabTapped: (i) => setState(() => _currentSection = i),
                  previewRecommendation: _fakeRecommendation,
                ),
              ),
              const SizedBox(height: 12),

              Showcase(
                key: TourKeys.nutritionCard,
                title: 'Kelengkapan Gizi',
                description:
                    'Pantau kelengkapan 5 kelompok makanan si kecil hari ini',
                child: NutritionCard(
                  uid: _fakeUid,
                  babyId: _fakeBabyId,
                  babyName: _fakeBabyName,
                  previewCoveredGroups: _fakeCoveredGroups,
                ),
              ),
              const SizedBox(height: 24),

              Showcase(
                key: TourKeys.aiTipsCard,
                title: 'Tips dari Rumi AI',
                description:
                    'Dapatkan tips harian yang disesuaikan dengan usia si kecil',
                child: Card(
                  color: _cardBg, // CHANGED: was Color(0xFFFDF8F2)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: _cardBorder,
                      width: 1.5,
                    ), // CHANGED: was Color(0xFFE8D5B7)
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            SizedBox(width: 6),
                            Text(
                              '🤎 Pesan dari Rumi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _ink, // CHANGED: was Color(0xFF363434)
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hari ini $_fakeBabyName sudah bisa mulai belajar tekstur '
                          'yang lebih kasar. Pastikan protein hewani tetap ada di '
                          'setiap menu.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: _ink, // CHANGED: was Color(0xFF363434)
                            fontStyle: FontStyle.italic,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '— Rumi AI',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors
                                  .grey
                                  .shade400, // CHANGED: was grey.shade500
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFakeHomeHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardBg, // CHANGED: was Color(0xFFFDF8F2)
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _cardBorder,
        ), // CHANGED: was Color(0xFFE8D5B7)
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getGreeting(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors
                                  .grey
                                  .shade400, // CHANGED: was Color(0xFF6A655F)
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Bapak/Ibu',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: _ink, // CHANGED: was Color(0xFF363434)
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset('assets/images/logo_tp.png', height: 80),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  'Semoga hari ini menyenangkan bersama si kecil.',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                  ), // CHANGED: was grey.shade600
                ),

                const SizedBox(height: 5),

                Showcase(
                  key: TourKeys.babyDropdown,
                  title: 'Pilih Profil Bayi',
                  description: 'Ganti profil bayi aktif di sini kapan saja',
                  child: Row(
                    children: const [
                      Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _fakeBabyLabel,
                          style: TextStyle(
                            color: _ink,
                            fontSize: 14,
                          ), // CHANGED: was Color(0xFF363434)
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: _ink,
                        size: 20,
                      ), // CHANGED: was Color(0xFF363434)
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: -2,
            left: -2,
            child: RagBadge(size: RagBadgeSize.small),
          ),
        ],
      ),
    );
  }

  // ---- Rekomendasi mimic ----
  Widget _buildRekomendasiSection() {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(
          0xFF363434,
        ), // CHANGED: was Color(0xFFF2DAB1)
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF363434),
              Color(0xFF1A1A1A),
            ], // CHANGED: was cream to white
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jadwal MPASI',
                            style: TextStyle(
                              color: _ink, // CHANGED: was Color(0xFF363434)
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(
                                Icons.circle,
                                color: Colors.greenAccent,
                                size: 10,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Profil aktif: $_fakeBabyLabel',
                                style: TextStyle(
                                  color: _ink,
                                  fontSize: 13,
                                ), // CHANGED
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                color: _ink,
                                size: 18,
                              ), // CHANGED
                            ],
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: _brandDark,
                        child: const Icon(
                          Icons.edit_document,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CalendarStrip(
                      selectedDate: DateTime.now(),
                      onDateSelected: (_) {},
                      uid: _fakeUid,
                      babyId: _fakeBabyId,
                      showCard: true,
                      showArrows: true,
                    ),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final now = DateTime.now();
                        return Text(
                          '${now.day} ${_monthName(now.month)}, ${_dayName(now.weekday)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: _ink, // CHANGED
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              Expanded(
                child: Showcase(
                  key: TourKeys.rekomendasiEmptyState,
                  description:
                      'Rencana menu untuk tanggal ini akan muncul di sini setelah dibuat',
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_meals,
                          size: 48,
                          color: Colors.grey.shade600,
                        ), // CHANGED: was grey.shade400
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada rencana untuk hari ini',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ), // CHANGED: was grey.shade600
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _brand,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {},
                          child: const Text('Buat Rekomendasi'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Riwayat mimic ----
  Widget _buildRiwayatSection() {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(
          0xFF363434,
        ), // CHANGED: was Color(0xFFF2DAB1)
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF363434),
              Color(0xFF1A1A1A),
            ], // CHANGED: was cream to white
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Riwayat MPASI',
                            style: TextStyle(
                              color: _ink, // CHANGED
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(
                                Icons.circle,
                                color: Colors.greenAccent,
                                size: 10,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Profil aktif: $_fakeBabyLabel',
                                style: TextStyle(
                                  color: _ink,
                                  fontSize: 13,
                                ), // CHANGED
                              ),
                              SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                color: _ink,
                                size: 18,
                              ), // CHANGED
                            ],
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: _brandDark,
                        child: const Icon(
                          Icons.today,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Showcase(
                  key: TourKeys.riwayatPage,
                  description:
                      'Lihat kembali menu-menu yang sudah pernah diberikan ke si kecil',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CalendarStrip(
                              selectedDate: DateTime.now(),
                              onDateSelected: (_) {},
                              uid: _fakeUid,
                              babyId: _fakeBabyId,
                              showCard: true,
                              showArrows: true,
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (context) {
                                final now = DateTime.now();
                                return Text(
                                  '${_dayName(now.weekday)}, ${now.day} ${_monthName(now.month)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _ink, // CHANGED
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          children: [
                            _fakeCompletionSummaryCard(),
                            const SizedBox(height: 12),
                            ..._fakeRecommendation.meals.map(
                              (meal) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _fakeHistoryMealCard(meal),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fakeCompletionSummaryCard() {
    final total = _fakeRecommendation.meals.length;
    final eaten = _fakeRecommendation.meals.where((m) => m.isEaten).length;
    final ratio = total == 0 ? 0.0 : eaten / total;
    final allDone = total > 0 && eaten == total;

    return Card(
      color: _cardBg, // CHANGED: was Color(0xFFFDF8F2)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _cardBorder, width: 1.5), // CHANGED
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  allDone ? '🎉 Semua menu selesai' : 'Ringkasan hari ini',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _ink, // CHANGED
                  ),
                ),
                Text(
                  '$eaten / $total menu',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: _cardBorder.withOpacity(0.5), // CHANGED
                valueColor: const AlwaysStoppedAnimation<Color>(_brand),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fakeHistoryMealCard(Meal meal) {
    final isAsi = meal.type == 'ASI';
    final label = isAsi ? 'Air Susu Ibu' : (meal.name ?? '');
    final IconData mealIcon = isAsi
        ? Icons.water_drop
        : meal.type.toLowerCase() == 'snack'
        ? Icons.cookie
        : Icons.restaurant;

    return Opacity(
      opacity: meal.isEaten ? 1.0 : 0.55,
      child: Card(
        color: _cardBg, // CHANGED: was Color(0xFFFDF8F2)
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _cardBorder, width: 1.5), // CHANGED
        ),
        elevation: 2,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 44,
                  color: _brandDark,
                  child: Icon(mealIcon, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _brand,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            meal.type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          meal.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ), // CHANGED: was grey.shade500
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _ink, // CHANGED
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                meal.isEaten
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: meal.isEaten ? _brand : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---- Profile mimic ----
  Widget _buildProfileSection() {
    return Scaffold(
      backgroundColor: const Color(
        0xFF1A1A1A,
      ), // CHANGED: was Color.fromARGB(255, 113, 222, 255)
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(
          0xFF363434,
        ), // CHANGED: was Color.fromARGB(255, 242, 218, 177)
        title: const Text(
          'My Account',
          style: TextStyle(color: _ink), // CHANGED: was Color(0xFF363434)
        ),
      ),
      body: Container(
        constraints: const BoxConstraints(minHeight: double.infinity),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF363434),
              Color(0xFF1A1A1A),
            ], // CHANGED: was cream to white
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 57.5,
                backgroundColor: Color(
                  0xFF363434,
                ), // CHANGED: was Color(0xFFE8C99A)
                child: Icon(
                  Icons.person,
                  color: _ink,
                  size: 40,
                ), // CHANGED: was Color(0xFF8B6F47)
              ),
              const SizedBox(height: 20),
              Showcase(
                key: TourKeys.profilePage,
                description:
                    'Kelola detail akun, data bayi, dan pengaturan lainnya di sini',
                onTargetClick: () => _finishTutorial(),
                onToolTipClick: () => _finishTutorial(),
                disposeOnTap: true,
                disableBarrierInteraction: true,
                child: Column(
                  children: [
                    _fakeProfileMenu('Profile Detail', Icons.person),
                    _fakeProfileMenu('Data Bayi', Icons.child_care),
                    _fakeProfileMenu('Settings', Icons.settings),
                    _fakeProfileMenu('Tutorial', Icons.help),
                    _fakeProfileMenu('Log Out', Icons.logout),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishTutorial() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  Widget _fakeProfileMenu(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _cardBorder,
            width: 1.5,
          ), // CHANGED: was Color(0xFFE8D5B7)
          color: _cardBg, // CHANGED: was Color(0xFFFDF8F2)
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: _ink), // CHANGED: was Color(0xFF363434)
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: _ink,
                ), // CHANGED: was Color(0xFF757575)
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: _ink,
            ), // CHANGED: was Color(0xFF757575)
          ],
        ),
      ),
    );
  }
}
