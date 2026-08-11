import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';
import 'package:rumi/shared/nutrition_card.dart';
import 'package:rumi/shared/today_schedule_card.dart';
import 'package:rumi/shared/daily_tip.dart';
import 'package:rumi/shared/home_hero.dart';

// $env:CHROME_EXECUTABLE="C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
// flutter run -d chrome
// pake ini buat jalanin di brave

// powertoys buat bikin tab brave stay on top
// win + ctrl + t

class Home extends StatefulWidget {
  final Function(int) onTabTapped;
  const Home({super.key, required this.onTabTapped});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamProvider<List<Baby>>.value(
      value: DatabaseService(uid: user!.uid).babies,
      initialData: [],
      child: StreamBuilder<UserProfile?>(
        stream: DatabaseService(uid: user.uid).userProfile,
        builder: (context, snapshot) {
          final babies = context.watch<List<Baby>>();
          final activeBaby = babies.isEmpty
              ? null
              : babies.cast<Baby?>().firstWhere(
                  (b) => b!.isActive,
                  orElse: () => null,
                );

          // ADDED: baca inset navbar sistem, sama kayak pattern di bottomnavbar.dart & register/sign_in
          final systemNavInset = MediaQuery.of(context).padding.bottom;
          // ADDED: hitung total tinggi BottomNavBar beneran (bukan tebakan lagi)
          // 64 = tinggi Container bar itu sendiri (liat bottomnavbar.dart)
          // 24 + systemNavInset = padding bottom si bar (juga dari bottomnavbar.dart)
          // +16 = jarak nafas tambahan, biar konten ga terlalu mepet sama bar
          final bottomClearance = 64 + 24 + systemNavInset + 16;

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
                // CHANGED: 100 -> bottomClearance, biar dihitung dari tinggi bar yang sebenernya, bukan tebakan
                padding: EdgeInsets.fromLTRB(16, 20, 16, bottomClearance),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeHero(
                      profile: snapshot.data,
                      activeBaby: activeBaby,
                      babies: babies,
                      onBabyChanged: (selectedId) {
                        if (selectedId != null) {
                          DatabaseService(
                            uid: user.uid,
                          ).setActiveBaby(selectedId);
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Calendar Strip
                    if (activeBaby != null)
                      CalendarStrip(
                        selectedDate: DateTime.now(),
                        onDateSelected: (_) {},
                        uid: user.uid,
                        babyId: activeBaby.id,
                        showCard: true,
                        showArrows: true,
                      ),

                    // Meal Plan
                    const SizedBox(height: 24),
                    if (activeBaby != null)
                      TodayScheduleCard(
                        key: ValueKey(activeBaby.id),
                        uid: user.uid,
                        babyId: activeBaby.id,
                        onTabTapped: widget.onTabTapped,
                      ),

                    // Kelengkapan Gizi Hari Ini
                    const SizedBox(height: 12),
                    if (activeBaby != null)
                      NutritionCard(
                        uid: user.uid,
                        babyId: activeBaby.id,
                        babyName: activeBaby.firstName,
                      ),
                    const SizedBox(height: 24),

                    // Tips Card — sekarang di-generate Gemini per hari, per baby, di-cache lokal
                    if (activeBaby != null)
                      DailyTip(
                        key: ValueKey(
                          'dailyTip_${activeBaby.id}',
                        ), // beda prefix dari TodayScheduleCard punya, biar ga collide keynya
                        baby: activeBaby,
                        parentGender: snapshot.data!.gender,
                      ),
                  ],
                ),
              ),
            ),

            extendBody: true,
            bottomNavigationBar: BottomNavBar(
              currentIndex: 0,
              onTap: widget.onTabTapped,
              photoUrl: snapshot.data?.photoUrl,
            ),
          );
        },
      ),
    );
  }
}
