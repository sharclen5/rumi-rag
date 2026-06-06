import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/screens/home/baby/add_baby_forms.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:rumi/screens/home/baby/baby_list.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/bottomnavbar.dart';

class BabyPage extends StatelessWidget {
  final Function(int) onTabTapped;
  BabyPage({super.key, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    void _showAddBabyPanel() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true, // bikin form jadi lebih tinggi
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                context,
              ).viewInsets.bottom, // biar form naik pas keyboard muncul
            ),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: AddBabyForms(),
            ),
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
          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 113, 222, 255),
            appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 0, 138, 218),
              foregroundColor: Colors.white,
              title: const Text("Data Bayi"),
            ),

            body: Container(
              constraints: const BoxConstraints(minHeight: double.infinity),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 113, 222, 255), // ✏️ top color
                    Color.fromARGB(255, 220, 235, 240),
                  ],
                  stops: [0.0, 1.0],
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
            extendBody: true,
            bottomNavigationBar: BottomNavBar(
              currentIndex: 3,
              onTap: (index) {
                Navigator.pop(context);
                onTabTapped(index);
              },
              photoUrl: snapshot.data?.photoUrl,
            ),
          );
        },
      ),
    );
  }
}
