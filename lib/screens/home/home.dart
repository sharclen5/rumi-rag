import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/screens/home/settings_forms.dart';
import 'package:rumi/services/auth.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumi/screens/home/baby_list.dart';

// $env:CHROME_EXECUTABLE="C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
// flutter run -d chrome
// pake ini buat jalanin di brave

// powertoys buat bikin tab brave stay on top
// win + ctrl + t

class Home extends StatelessWidget {
  Home({super.key});

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    void _showSettingsPanel() {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
            child: SettingsForm(),
          );
        },
      );
    }

    return StreamProvider<List<Baby>>.value(
      value: DatabaseService(uid: '').babies,
      initialData: [],
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 113, 222, 255),
        appBar: AppBar(
          title: Text('Rumi', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.deepOrange,
          elevation: 0.0,
          actions: <Widget>[
            TextButton.icon(
              icon: Icon(Icons.person, color: Colors.white),
              label: Text('Logout', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
            TextButton.icon(
              icon: Icon(Icons.settings, color: Colors.white),
              label: Text('Settings', style: TextStyle(color: Colors.white)),
              onPressed: () => _showSettingsPanel(),
            ),
          ],
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          child: BabyList(),
        ),
      ),
    );
  }
}
