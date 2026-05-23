import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/screens/home/baby/add_baby_forms.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rumi/screens/home/baby/baby_list.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/bottomnavbar.dart';

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

    void _showAddBabyPanel() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
            child: AddBabyForms(),
          );
        },
      );
    }

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
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 113, 222, 255),
            appBar: AppBar(
              toolbarHeight: 100,
              backgroundColor: Colors.deepOrange,
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
                    ],
                  ),
                ),
              ),
            ),
            body: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Data Bayi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: BabyList(onAddBaby: _showAddBabyPanel)),
                ],
              ),
            ),
            // floatingActionButton: FloatingActionButton(
            //   backgroundColor: Colors.deepOrange,
            //   onPressed: () => _showAddBabyPanel(),
            //   child: Icon(Icons.add, color: Colors.white),
            // ),
            bottomNavigationBar: BottomNavBar(
              currentIndex: 0,
              onTap: onTabTapped,
            ),
          );
        },
      ),
    );
  }
}
