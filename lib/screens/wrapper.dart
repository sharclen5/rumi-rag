import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/screens/authenticate/authenticate.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/screens/home/history/history_page.dart';
import 'package:rumi/screens/home/home.dart';
import 'package:rumi/screens/home/profile/profile.dart';
import 'package:rumi/screens/home/recommendation/recommendation_page.dart';
import 'package:rumi/shared/loading.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/screens/onboarding/intro_slides.dart';
import 'package:rumi/screens/home/baby/add_baby_forms.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:rumi/shared/tour_keys.dart';
import 'package:rumi/screens/onboarding/coach_mark_demo_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  int _currentIndex = 0;
  bool _cameFromOnboarding = false;
  bool _tourLaunchedThisSession = false;

  @override
  void initState() {
    super.initState();
    // ADDED: single global registration for the whole app session.
    // BottomNavBar's Showcase wraps are always in the tree once a user is
    // logged in, so ShowcaseView must be registered before that, not tied
    // to CoachMarkDemoPage's lifecycle.
    ShowcaseView.register(
      enableAutoScroll: true,
      scrollDuration: const Duration(milliseconds: 300),
      onComplete: (index, key) {
        if (key == TourKeys.profilePage) {
          final user = Provider.of<User?>(context, listen: false);
          if (user != null) {
            DatabaseService(uid: user.uid).markHomeTourAsSeen();
          }
        }
      },
    );
  }

  @override
  void dispose() {
    // ADDED
    ShowcaseView.get().unregister();
    super.dispose();
  }

  // cek flag one-time intro
  Future<bool> _hasSeenIntro(String uid) async {
    return DatabaseService(uid: uid).hasSeenIntro();
  }

  // dipanggil pas IntroSlides selesai (baik lewat Done atau Skip)
  Future<void> _markIntroAsSeen(String uid) async {
    await DatabaseService(uid: uid).markIntroAsSeen();
    // trigger rebuild biar FutureBuilder re-check _hasSeenIntro()
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
          if (_cameFromOnboarding && !_tourLaunchedThisSession) {
            _tourLaunchedThisSession = true;
            _cameFromOnboarding = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CoachMarkDemoPage()),
                );
              }
            });
          }
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

        // belum ada baby -> cek udah pernah liat intro apa belum
        return FutureBuilder<bool>(
          future: _hasSeenIntro(user.uid),
          builder: (context, introSnapshot) {
            if (introSnapshot.connectionState == ConnectionState.waiting) {
              return Loading(); // CHANGED: konsisten pake Loading widget
            }

            final seenIntro = introSnapshot.data ?? false;

            // pake IntroSlides beneran, bukan placeholder lagi
            if (!seenIntro) {
              return IntroSlides(onDone: () => _markIntroAsSeen(user.uid));
            }

            // Add Baby form
            _cameFromOnboarding = true;
            return const AddBabyForms();
          },
        );
      },
    );
  }
}
