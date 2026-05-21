import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/screens/authenticate/authenticate.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/screens/home/home.dart';
import 'package:rumi/screens/home/profile/profile.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      _currentIndex = 0; // reset ke home kalo logout
      return Authenticate();
    }

    final pages = [
      Home(onTabTapped: (i) => setState(() => _currentIndex = i)),
      const Placeholder(), // Rekomendasi - belum dibuat
      const Placeholder(), // Riwayat - belum dibuat
      ProfilePage(onTabTapped: (i) => setState(() => _currentIndex = i)),
    ];

    return pages[_currentIndex];
  }
}
