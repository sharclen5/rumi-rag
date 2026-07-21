import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';
import 'package:rumi/shared/nutrition_card.dart';
import 'package:rumi/shared/today_schedule_card.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:rumi/shared/tour_keys.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rumi/shared/rag_info.dart';

// Dedicated, self-contained coach mark tour page. Entirely fake data, no
// Firestore, no real navigation — fakes its own "current tab" switching via
// _currentSection instead of hooking into Wrapper/BottomNavBar's real state.
// Launched via Navigator.push, either right after onboarding's AddBabyForms
// submits, or via Profile's "Tutorial" replay button.

class TutorialMark extends StatefulWidget {
  final VoidCallback? onFinished;
  const TutorialMark({super.key, this.onFinished});

  @override
  State<TutorialMark> createState() => _TutorialMarkState();
}

class _TutorialMarkState extends State<TutorialMark> {
  // fake "current tab" — 0 Home, 1 Rekomendasi, 3 Riwayat, 4 Profile.
  // (index 2, "Buat Rencana", is a modal trigger in the real app, never a
  // real section — same as Wrapper's real _currentIndex never becoming 2)
  int _currentSection = 0;

  // ---- fake data ----
  static const String _fakeUid = 'demo_uid';
  static const String _fakeBabyId = 'demo_baby';
  static const String _fakeBabyName = 'Mulyono';
  static const String _fakeBabyLabel = 'Contoh Bayi · 8 bulan';

  static const Set<String> _fakeCoveredGroups = {
    'karbohidrat',
    'protein_hewani',
    'sayuran',
  };

  late final Recommendation _fakeRecommendation = Recommendation(
    babyId: _fakeBabyId,
    date: _todayStr(),
    createdAt: DateTime.now(),
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

  // matches HomeHero.getGreeting()
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam,';
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

  @override
  void initState() {
    // CHANGED: registration now lives in Wrapper, not here
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

  // maps _currentSection (0,1,3,4) to the IndexedStack's 0..3 children
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
  // CHANGED: AppBar collapsed to toolbarHeight 0 (matches real Home), the
  // old inline welcome/dropdown header is gone from the AppBar — it now
  // lives in a HomeHero-style card at the top of the body. Spacing between
  // sections (20 / 24 / 12 / 24) matches the real page too.
  Widget _buildHomeSection() {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(0xFFF2DAB1),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5EBD9), Color(0xFFFFFFFF)],
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

              // CHANGED: matches Home's new tips card copy/icon-less header
              Showcase(
                key: TourKeys.aiTipsCard,
                title: 'Tips dari Rumi AI',
                description:
                    'Dapatkan tips harian yang disesuaikan dengan usia si kecil',
                child: Card(
                  color: const Color(0xFFFDF8F2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: Color(0xFFE8D5B7),
                      width: 1.5,
                    ),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            SizedBox(width: 6),
                            Text(
                              '🤎 Pesan dari Rumi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF363434),
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
                            color: Color(0xFF363434),
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
                              color: Colors.grey.shade500,
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

  // ADDED: static stand-in for HomeHero. HomeHero itself takes a real
  // UserProfile?/Baby?/List<Baby>, which this fake-data-only page doesn't
  // construct — this mirrors its exact visual output instead (greeting,
  // name, subtitle, dropdown) so the coach mark still points at the right
  // spot. Swap this out for the real HomeHero if/when fake model instances
  // become easy to build here.
  Widget _buildFakeHomeHero() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8D5B7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6A655F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Bapak/Ibu',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF363434),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // ADDED: "With RAG" badge, matches real HomeHero — floats
              // below the logo via Stack/Positioned so it doesn't add to
              // the Row's height
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Image.asset('assets/images/logo_tp.png', height: 80),
                  Positioned(
                    bottom: -30,
                    child: GestureDetector(
                      onTap: () => showRagInfo(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF363434),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.network_intel_node,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'With RAG',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          // CHANGED: increased from 5 to 24 to make room for the badge
          // floating below the logo (matches real HomeHero)
          const SizedBox(height: 24),

          // wrapped dropdown in Showcase — static mimic of HomeHero's
          // DropdownButton, non-interactive here same as before
          Showcase(
            key: TourKeys.babyDropdown,
            title: 'Pilih Profil Bayi',
            description: 'Ganti profil bayi aktif di sini kapan saja',
            child: Row(
              children: [
                const Icon(Icons.circle, color: Colors.greenAccent, size: 10),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$_fakeBabyLabel',
                    style: const TextStyle(
                      color: Color(0xFF363434),
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF363434),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---- Rekomendasi ("Jadwal MPASI") mimic ----
  // CHANGED: AppBar collapsed to toolbarHeight 0; title + baby dropdown +
  // edit-schedule icon moved into the body as a header block, same pattern
  // as Home/Riwayat now use. Empty-state icon/copy/button unchanged.
  Widget _buildRekomendasiSection() {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(0xFFF2DAB1),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5EBD9), Color(0xFFFFFFFF)],
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
                              color: Color(0xFF363434),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.greenAccent,
                                size: 10,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Profil aktif: $_fakeBabyLabel',
                                style: const TextStyle(
                                  color: Color(0xFF363434),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF363434),
                                size: 18,
                              ),
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
                        color: const Color.fromARGB(255, 122, 105, 95),
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
                            color: Color(0xFF363434),
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
                  title: 'Belum Ada Rencana',
                  description:
                      'Rencana menu untuk tanggal ini akan muncul di sini setelah dibuat',
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.no_meals,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada rencana untuk hari ini',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              144,
                              121,
                              84,
                            ),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {}, // no-op in the demo
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

  Widget _buildRiwayatSection() {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        elevation: 0,
        backgroundColor: const Color(0xFFF2DAB1),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5EBD9), Color(0xFFFFFFFF)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // header: title + dropdown on the left, today-jump icon on the right
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
                              color: Color(0xFF363434),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.greenAccent,
                                size: 10,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Profil aktif: $_fakeBabyLabel',
                                style: const TextStyle(
                                  color: Color(0xFF363434),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF363434),
                                size: 18,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // ADDED: static "hari ini" jump icon, mirrors HistoryPage's
                    // dimmed-when-already-today container (always full opacity
                    // here since the demo's date never changes)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 48,
                        height: 48,
                        color: const Color.fromARGB(255, 122, 105, 95),
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
                  title: 'Riwayat MPASI',
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
                            // CHANGED: weekday-first label to match HistoryPage's
                            // "${_dayName(weekday)}, ${day} ${_monthName(month)}"
                            Builder(
                              builder: (context) {
                                final now = DateTime.now();
                                return Text(
                                  '${_dayName(now.weekday)}, ${now.day} ${_monthName(now.month)}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF363434),
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

  // ADDED: static mimic of _CompletionSummaryCard from the real Riwayat page
  Widget _fakeCompletionSummaryCard() {
    const brand = Color.fromARGB(255, 144, 121, 84);
    const ink = Color(0xFF363434);
    const cardBorder = Color(0xFFE8D5B7);

    final total = _fakeRecommendation.meals.length;
    final eaten = _fakeRecommendation.meals.where((m) => m.isEaten).length;
    final ratio = total == 0 ? 0.0 : eaten / total;
    final allDone = total > 0 && eaten == total;

    return Card(
      color: const Color(0xFFFDF8F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: cardBorder, width: 1.5),
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
                    color: ink,
                  ),
                ),
                Text(
                  '$eaten / $total menu',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: brand,
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
                backgroundColor: cardBorder.withOpacity(0.5),
                valueColor: const AlwaysStoppedAnimation<Color>(brand),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CHANGED: replaces the old _fakeHistoryMealRow — now mirrors
  // _HistoryMealCard's icon-chip + type-badge + check-icon card style
  // instead of a plain checklist row
  Widget _fakeHistoryMealCard(Meal meal) {
    const brand = Color.fromARGB(255, 144, 121, 84);
    const brandDark = Color.fromARGB(255, 122, 105, 95);
    const ink = Color(0xFF363434);
    const cardBorder = Color(0xFFE8D5B7);

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
        color: const Color(0xFFFDF8F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: cardBorder, width: 1.5),
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
                  color: brandDark,
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
                            color: brand,
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
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ink,
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
                color: meal.isEaten ? brand : Colors.grey.shade400,
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
      backgroundColor: const Color.fromARGB(255, 113, 222, 255),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 242, 218, 177),
        title: const Text(
          'My Account',
          style: TextStyle(color: Color(0xFF363434)),
        ),
      ),
      body: Container(
        constraints: const BoxConstraints(minHeight: double.infinity),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5EBD9), Color(0xFFFFFFFF)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // fake avatar, mirrors ProfilePic's empty-state look
              const CircleAvatar(
                radius: 57.5,
                backgroundColor: Color(0xFFE8C99A),
                child: Icon(Icons.person, color: Color(0xFF8B6F47), size: 40),
              ),
              const SizedBox(height: 20),
              // wrapped in Showcase — the actual last tour step
              Showcase(
                key: TourKeys.profilePage,
                title: 'Profil',
                description:
                    'Kelola detail akun, data bayi, dan pengaturan lainnya di sini',
                onTargetClick: () {
                  _finishTutorial();
                },
                onToolTipClick: () {
                  _finishTutorial();
                },
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

  // static, no-op mimic of ProfileMenu
  Widget _fakeProfileMenu(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8D5B7), width: 1.5),
          color: const Color(0xFFFDF8F2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF363434)),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Color(0xFF757575)),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF757575)),
          ],
        ),
      ),
    );
  }
}
