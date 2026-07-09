import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';
import 'package:rumi/shared/nutrition_card_stars.dart';
import 'package:rumi/shared/today_schedule_card.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:rumi/shared/tour_keys.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';

// Dedicated, self-contained coach mark tour page. Entirely fake data, no
// Firestore, no real navigation — fakes its own "current tab" switching via
// _currentSection instead of hooking into Wrapper/BottomNavBar's real state.
// Launched via Navigator.push, either right after onboarding's AddBabyForms
// submits, or via Profile's "Tutorial" replay button.
class CoachMarkDemoPage extends StatefulWidget {
  const CoachMarkDemoPage({super.key});

  @override
  State<CoachMarkDemoPage> createState() => _CoachMarkDemoPageState();
}

class _CoachMarkDemoPageState extends State<CoachMarkDemoPage> {
  // fake "current tab" — 0 Home, 1 Rekomendasi, 3 Riwayat, 4 Profile.
  // (index 2, "Buat Rencana", is a modal trigger in the real app, never a
  // real section — same as Wrapper's real _currentIndex never becoming 2)
  int _currentSection = 0;

  // ---- fake data ----
  static const String _fakeUid = 'demo_uid';
  static const String _fakeBabyId = 'demo_baby';
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
        TourKeys.nutritionCard,
        TourKeys.todayScheduleCard,
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
  Widget _buildHomeSection() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 130,
        backgroundColor: const Color.fromARGB(255, 242, 218, 177),
        elevation: 0.0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Selamat datang,',
                  style: TextStyle(color: Color(0xFF363434), fontSize: 16),
                ),
                const Text(
                  'Bapak/Ibu',
                  style: TextStyle(
                    color: Color(0xFF363434),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // static mimic of the dropdown — not interactive in the demo

                // wrapped dropdown in Showcase
                Showcase(
                  key: TourKeys.babyDropdown,
                  title: 'Pilih Profil Bayi',
                  description: 'Ganti profil bayi aktif di sini kapan saja',
                  child: Row(
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
                ),
              ],
            ),
          ),
        ),
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
              Showcase(
                // CHANGED: wraps CalendarStrip
                key: TourKeys.calendarStrip,
                title: 'Kalender',
                description:
                    'Lihat dan pilih tanggal untuk melacak menu harian si kecil',
                child: CalendarStrip(
                  selectedDate: DateTime.now(),
                  onDateSelected: (_) {},
                  showCard: true,
                  showArrows: true,
                ),
              ),
              const SizedBox(height: 16),

              Showcase(
                // CHANGED: wraps NutritionCardStars
                key: TourKeys.nutritionCard,
                title: 'Kelengkapan Gizi',
                description:
                    'Pantau kelengkapan 5 kelompok makanan si kecil hari ini',
                child: NutritionCardStars(
                  uid: _fakeUid,
                  babyId: _fakeBabyId,
                  previewCoveredGroups: _fakeCoveredGroups,
                ),
              ),
              const SizedBox(height: 16),

              Showcase(
                // CHANGED: wraps TodayScheduleCard
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
              const SizedBox(height: 16),

              Showcase(
                //wraps the tips Card
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
                            Icon(
                              Icons.lightbulb_outline,
                              color: Color.fromARGB(255, 144, 121, 84),
                              size: 18,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Tips untuk si Kecil hari ini',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF363434),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Contoh tips harian akan muncul di sini, disesuaikan dengan usia si kecil.',
                          style: TextStyle(
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

  // ---- Rekomendasi mimic (empty-state only, for the tour) ----
  Widget _buildRekomendasiSection() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100,
        backgroundColor: const Color.fromARGB(255, 242, 218, 177),
        elevation: 0.0,
        title: const Text(
          'Jadwal MPASI',
          style: TextStyle(
            color: Color(0xFF363434),
            fontWeight: FontWeight.bold,
          ),
        ),
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

        child: Showcase(
          // CHANGED
          key: TourKeys.rekomendasiEmptyState,
          title: 'Belum Ada Rencana',
          description:
              'Rencana menu untuk tanggal ini akan muncul di sini setelah dibuat',
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.no_meals, size: 48, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Belum ada rencana untuk hari ini',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 144, 121, 84),
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
    );
  }

  // ---- Riwayat mimic ----
  Widget _buildRiwayatSection() {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 130,
        backgroundColor: const Color.fromARGB(255, 242, 218, 177),
        elevation: 0.0,
        title: const Text(
          'Riwayat MPASI',
          style: TextStyle(
            color: Color(0xFF363434),
            fontWeight: FontWeight.bold,
          ),
        ),
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
        child: Showcase(
          // CHANGED
          key: TourKeys.riwayatPage,
          title: 'Riwayat MPASI',
          description:
              'Lihat kembali menu-menu yang sudah pernah diberikan ke si kecil',
          child: Center(
            child: Text(
              'Riwayat menu yang sudah pernah diberikan akan muncul di sini',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // ---- Profile mimic ----
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
                onTargetClick: () => Navigator.of(context).pop(),
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
