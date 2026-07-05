import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';
import 'package:rumi/shared/nutrition_card_stars.dart';
import 'package:rumi/shared/today_schedule_card.dart';

// $env:CHROME_EXECUTABLE="C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
// flutter run -d chrome
// pake ini buat jalanin di brave

// powertoys buat bikin tab brave stay on top
// win + ctrl + t

class Home extends StatelessWidget {
  final Function(int) onTabTapped;
  Home({super.key, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamProvider<List<Baby>>.value(
      value: DatabaseService(uid: user!.uid).babies,
      initialData: [],
      child: StreamBuilder<UserProfile?>(
        stream: DatabaseService(uid: user.uid).userProfile,
        builder: (context, snapshot) {
          final firstName = snapshot.data?.firstName ?? '';
          final isMale = snapshot.data?.gender.toLowerCase() == 'male';
          final greetingTitle = isMale ? 'Bapak $firstName' : 'Ibu $firstName';

          final babies = context.watch<List<Baby>>();
          final activeBaby = babies.isEmpty
              ? null
              : babies.cast<Baby?>().firstWhere(
                  (b) => b!.isActive,
                  orElse: () => null,
                );

          return Scaffold(
            appBar: AppBar(
              toolbarHeight: 130,
              backgroundColor: Color.fromARGB(255, 242, 218, 177),
              elevation: 0.0,
              flexibleSpace: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selamat datang,',
                        style: TextStyle(
                          color: Color(0xFF363434),
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        greetingTitle,
                        style: TextStyle(
                          color: Color(0xFF363434),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      babies.isEmpty
                          ? Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: Colors.white38,
                                  size: 10,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Belum ada profil bayi yang aktif',
                                  style: TextStyle(
                                    color: Color(0xFF363434),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                value: activeBaby?.id,
                                dropdownColor: Color(0xFFF5EBD9),
                                iconEnabledColor: Color(0xFF363434),
                                style: TextStyle(
                                  color: Color(0xFF363434),
                                  fontSize: 13,
                                ),
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Color(0xFF363434),
                                      size: 10,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Belum ada profil bayi yang aktif',
                                      style: TextStyle(
                                        color: Color(0xFF363434),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                selectedItemBuilder: (context) {
                                  return babies.map((baby) {
                                    return Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors.greenAccent,
                                          size: 10,
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          'Profil aktif: ${baby.fullName} · ${baby.ageInMonths} bulan',
                                          style: TextStyle(
                                            color: Color(0xFF363434),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                                items: babies.map((baby) {
                                  return DropdownMenuItem<String>(
                                    value: baby.id,
                                    child: Text(
                                      '${baby.fullName} · ${baby.ageInMonths} bulan',
                                      style: TextStyle(
                                        color: Color(0xFF363434),
                                        fontSize: 13,
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (selectedId) {
                                  if (selectedId != null) {
                                    DatabaseService(
                                      uid: user.uid,
                                    ).setActiveBaby(selectedId);
                                  }
                                },
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

                    // Calendar Strip
                    CalendarStrip(
                      selectedDate: DateTime.now(),
                      onDateSelected: (_) {},
                      showCard: true,
                      showArrows: true,
                    ),
                    SizedBox(height: 16),

                    // Kelengkapan Gizi Hari Ini
                    if (activeBaby != null)
                      NutritionCardStars(uid: user.uid, babyId: activeBaby.id),
                    SizedBox(height: 16),

                    // Meal Plan
                    if (activeBaby != null)
                      TodayScheduleCard(
                        uid: user.uid,
                        babyId: activeBaby.id,
                        onTabTapped: onTabTapped,
                      ),

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
                                Icon(
                                  Icons.lightbulb_outline,
                                  color: Color.fromARGB(255, 144, 121, 84),
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Tips untuk ${activeBaby?.firstName ?? 'si Kecil'} hari ini',
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
                              'Di usia 10 bulan, si kecil sudah bisa mulai dikenalkan tekstur yang lebih kasar seperti nasi tim. Pastikan porsi protein hewani terpenuhi setiap hari.',
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
              onTap: onTabTapped,
              photoUrl: snapshot.data?.photoUrl,
            ),
          );
        },
      ),
    );
  }
}
