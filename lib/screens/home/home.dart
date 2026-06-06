import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rumi/screens/home/baby/baby_tile.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';

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
          // get first name only, fallback to empty string while loading
          final firstName = snapshot.data?.firstName ?? '';
          final isMale = snapshot.data?.gender.toLowerCase() == 'male';
          final greetingTitle = isMale ? 'Bapak $firstName' : 'Ibu $firstName';

          // buat dropdown di appBar
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
              backgroundColor: Color.fromARGB(255, 0, 138, 218),
              // Color.fromARGB(255, 0, 138, 218)
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
                      // greeting
                      Text(
                        'Selamat datang,',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        greetingTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),

                      // dropdown buat milih bayi yang aktif
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
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isDense: true,
                                value: activeBaby?.id,
                                dropdownColor: Color.fromARGB(255, 0, 118, 185),
                                iconEnabledColor: Colors.white,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                hint: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: Colors.white54,
                                      size: 10,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Belum ada profil bayi yang aktif',
                                      style: TextStyle(
                                        color: Colors.white70,
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
                                            color: Colors.white,
                                            fontSize: 13,
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
                                      '${baby.fullName} . ${baby.ageInMonths} bulan',
                                      style: TextStyle(
                                        color: Colors.white,
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
                  colors: [
                    Color.fromARGB(255, 113, 222, 255),
                    Color.fromARGB(255, 220, 235, 240),
                  ],
                  stops: [0.0, 1.0],
                ),
              ),

              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar Strip
                    CalendarStrip(
                      selectedDate: DateTime.now(),
                      onDateSelected:
                          (_) {}, // home doesn't need to react to date changes
                      showCard: true,
                      showArrows: true,
                    ),
                    SizedBox(height: 16),

                    // data bayi
                    if (activeBaby != null)
                      BabyTile(
                        baby: activeBaby,
                        onDelete: () => DatabaseService(
                          uid: user.uid,
                        ).deleteBaby(activeBaby.id),
                      ),
                    SizedBox(height: 16),

                    // Progres Bar
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // circular progress jadi indikator nutrition ring
                            // Stack lets us put the percentage text on top of the ring
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 64,
                                  height: 64,
                                  child: CircularProgressIndicator(
                                    value: 0.36, // static (buat sekarang)
                                    strokeWidth: 7,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Color.fromARGB(255, 0, 138, 218),
                                    ),
                                  ),
                                ),
                                Text(
                                  '36%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(width: 16),

                            // Informasi kalori di sebelah kanan
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kebutuhan Kalori Hari Ini',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Row(
                                  children: [
                                    Text(
                                      '550',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'kkal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    //meal reccomendation
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //small badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Color.fromARGB(255, 0, 138, 218),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Rekomendasi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      'Bubur Ayam Wortel',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '(200 kkal)',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),

                                // placeholder gambar makanan
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.restaurant,
                                      color: Colors.grey.shade400,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Divider(),
                            SizedBox(height: 8),

                            // ingredient list
                            _ingredientRow('Beras 30g', 80),
                            _ingredientRow('Ayam Cincang 20g', 60),
                            _ingredientRow('Wortel 15g', 30),
                            SizedBox(height: 12),

                            // macronutrient chips
                            Wrap(
                              spacing: 8,
                              children: [
                                _macroChip('Protein 30%'),
                                _macroChip('Karbo 50%'),
                                _macroChip('Lemak 20%'),
                              ],
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

  //helper widget
  // a single ingredient row with a colored dot and calorie count
  Widget _ingredientRow(String name, int cal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Color.fromARGB(255, 0, 138, 218)),
          SizedBox(width: 6),
          Text(name, style: TextStyle(fontSize: 13)),
          Spacer(),
          Text(
            '$cal kkal',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // a small chip for macronutrient display
  Widget _macroChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // light blue tint to match the app's color scheme
        color: Color.fromARGB(255, 0, 138, 218).withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 0, 138, 218)),
      ),
    );
  }
}
