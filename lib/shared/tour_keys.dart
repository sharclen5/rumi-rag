import 'package:flutter/material.dart';

// coach mark tour GlobalKeys, shared across Wrapper, Home,
// BottomNavBar, and other tab pages. Declared here instead of on
// _WrapperState so nothing needs to be passed through constructors —
// any widget that needs a key just imports this file.
class TourKeys {
  // Home section
  static final homeNavIcon = GlobalKey(); // step 1
  static final babyDropdown = GlobalKey(); // step 2
  static final calendarStrip = GlobalKey(); // step 3
  static final todayScheduleCard = GlobalKey(); // step 4
  static final nutritionCard = GlobalKey(); // step 5
  static final aiTipsCard = GlobalKey(); // step 6

  // Rekomendasi tab
  static final rekomendasiNavIcon = GlobalKey(); // step 7
  static final rekomendasiEmptyState = GlobalKey(); // step 8
  static final addButton = GlobalKey(); // step 9

  // Riwayat tab
  static final riwayatNavIcon = GlobalKey(); // step 10
  static final riwayatPage = GlobalKey(); // step 11

  // Profile tab
  static final profileNavIcon = GlobalKey(); // step 12
  static final profilePage = GlobalKey(); // step 13

  static final demoHomeNavIcon = GlobalKey();
  static final demoRekomendasiNavIcon = GlobalKey();
  static final demoAddButton = GlobalKey();
  static final demoRiwayatNavIcon = GlobalKey();
  static final demoProfileNavIcon = GlobalKey();
}
