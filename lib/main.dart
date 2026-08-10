import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ADDED: buat akses SystemChrome & SystemUiOverlayStyle
import 'package:provider/provider.dart';
import 'package:rumi/screens/wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rumi/services/auth.dart';
import 'firebase_options.dart';
import 'package:rumi/models/user.dart';

// $env:CHROME_EXECUTABLE="C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
// flutter run -d chrome
// pake ini buat jalanin di brave

// powertoys buat bikin tab brave stay on top
// win + ctrl + t

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //  init Firebase dulu
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ADDED: declare edge-to-edge secara eksplisit, jangan dibiarin ke default OS
  // yang ternyata beda-beda tiap device (ini yang bikin systemNavInset kebaca 0
  // di beberapa HP 3-button nav, soalnya insetnya ga dilaporin dengan benar)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // ADDED: jaga kontras icon status bar & nav bar biar ga keubah pas edge-to-edge
  // nyala, soalnya tanpa ini kadang icon-nya jadi susah kebaca (gelap di atas gelap, dst)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness
          .dark, // ganti ke .light kalau background atas app-nya gelap
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          Brightness.dark, // sama, sesuaikan kalau perlu
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // widget ini root dari appnya.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(home: Wrapper()),
    );
  }
}
