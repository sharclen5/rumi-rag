import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';
import 'package:rumi/shared/nutrition_card.dart';
import 'package:rumi/shared/today_schedule_card.dart';
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
                padding: EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // data bayi (temporary)
                    // if (activeBaby != null)
                    //   BabyTile(
                    //     baby: activeBaby,
                    //     onDelete: () => DatabaseService(
                    //       uid: user.uid,
                    //     ).deleteBaby(activeBaby.id),
                    //   ),
                    // SizedBox(height: 16),
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

                    // Tips Card
                    Card(
                      color: Color(0xFFFDF8F2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Color(0xFFE8D5B7), width: 1.5),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
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
                            SizedBox(height: 10),
                            Text(
                              'Hari ini ${activeBaby?.firstName} sudah bisa mulai belajar tekstur yang lebih kasar. Pastikan protein hewani tetap ada di setiap menu.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF363434),
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                            ),
                            SizedBox(height: 8),
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
