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
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddBabyForms()),
      );
    }

    return StreamProvider<List<Baby>>.value(
      value: DatabaseService(uid: user!.uid).babies,
      initialData: [],
      child: StreamBuilder<UserProfile?>(
        stream: DatabaseService(uid: user.uid).userProfile,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              centerTitle: false,
              elevation: 0,
              backgroundColor: Color.fromARGB(255, 242, 218, 177),
              title: const Text(
                "Data Bayi",
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
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 8),
                  Expanded(child: BabyList(onAddBaby: _showAddBabyPanel)),
                ],
              ),
            ),
            extendBody: true,
            bottomNavigationBar: BottomNavBar(
              currentIndex: 4,
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
