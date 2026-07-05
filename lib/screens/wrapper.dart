import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/screens/authenticate/authenticate.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/screens/home/history/history_page.dart';
import 'package:rumi/screens/home/home.dart';
import 'package:rumi/screens/home/profile/profile.dart';
import 'package:rumi/screens/home/recommendation/recommendation_page.dart';
import 'package:rumi/shared/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/screens/onboarding/intro_slides.dart'; // ADDED

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int _currentIndex = 0;

  // cek flag one-time intro dari shared_preferences
  Future<bool> _hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasSeenIntro') ?? false;
  }

  // ADDED: dipanggil pas IntroSlides selesai (baik lewat Done atau Skip)
  Future<void> _markIntroAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);
    // ADDED: trigger rebuild biar FutureBuilder re-check _hasSeenIntro()
    // dan jatuh ke branch Add Baby form
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    if (user == null) {
      _currentIndex = 0; // reset ke home kalo logout
      return Authenticate();
    }

    // cek apakah user udah punya baby profile atau belum
    return StreamBuilder<List<Baby>>(
      stream: DatabaseService(uid: user.uid).babies,
      builder: (context, babySnapshot) {
        // masih nunggu data babies dari Firestore
        if (babySnapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        final babies = babySnapshot.data ?? [];

        // sudah ada baby -> tampilan normal, ga ada yang berubah
        if (babies.isNotEmpty) {
          final pages = [
            Home(onTabTapped: (i) => setState(() => _currentIndex = i)),
            RecommendationPage(
              onTabTapped: (i) => setState(() => _currentIndex = i),
            ),
            const Placeholder(), // Buat Rencana slot — never actually rendered,
            HistoryPage(onTabTapped: (i) => setState(() => _currentIndex = i)),
            ProfilePage(onTabTapped: (i) => setState(() => _currentIndex = i)),
          ];
          return pages[_currentIndex];
        }

        // ADDED: belum ada baby -> cek udah pernah liat intro apa belum
        return FutureBuilder<bool>(
          future: _hasSeenIntro(),
          builder: (context, introSnapshot) {
            if (introSnapshot.connectionState == ConnectionState.waiting) {
              return Loading(); // CHANGED: konsisten pake Loading widget
            }

            final seenIntro = introSnapshot.data ?? false;

            // CHANGED: pake IntroSlides beneran, bukan placeholder lagi
            if (!seenIntro) {
              return IntroSlides(onDone: _markIntroAsSeen);
            }

            // ADDED: placeholder dulu, nanti diganti Add Baby form beneran
            return const Scaffold(
              body: Center(child: Text('PLACEHOLDER: Add Baby form screen')),
            );
          },
        );
      },
    );
  }
}
