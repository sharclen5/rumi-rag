import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

// intro slides yang muncul sekali doang buat user baru (belum ada baby profile)
// habis "Done" ditekan, onDone callback dipanggil (biar Wrapper yang urus logic selanjutnya)
class IntroSlides extends StatelessWidget {
  final VoidCallback onDone;

  const IntroSlides({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        // slide 1: welcome
        PageViewModel(
          title: "Selamat Datang di Rumi",
          body:
              "Teman pintar untuk membantu perjalanan MPASI si kecil, dari rekomendasi menu sampai pemantauan gizi harian.",
          image: Center(
            // ADDED: placeholder icon, ganti jadi Image.asset(...) kalo illustrationnya udah ada
            child: Icon(
              Icons.child_care,
              size: 120,
              color: const Color.fromARGB(255, 144, 121, 84),
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),

        // slide 2: brief explanation of what the app does
        PageViewModel(
          title: "Rekomendasi Menu, Lebih Terarah",
          body:
              "Rumi bantu susun menu MPASI harian yang seimbang berdasarkan 5 kelompok makanan (karbohidrat, protein, sayur, buah, dan lemak tambahan), disesuaikan dengan kondisi si kecil.",
          image: Center(
            // ADDED: placeholder icon, ganti jadi Image.asset(...) kalo illustrationnya udah ada
            child: Icon(
              Icons.restaurant_menu,
              size: 120,
              color: const Color.fromARGB(255, 144, 121, 84),
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            bodyTextStyle: TextStyle(fontSize: 16),
            imagePadding: EdgeInsets.only(top: 40),
          ),
        ),
      ],
      showSkipButton: true,
      showBackButton: true,
      back: const Icon(Icons.arrow_back),
      skip: const Text("Lewati"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("Mulai", style: TextStyle(fontWeight: FontWeight.bold)),
      onDone: onDone,
      onSkip: onDone, // ADDED: skip juga langsung anggap intro selesai
      dotsDecorator: DotsDecorator(
        activeColor: const Color.fromARGB(255, 144, 121, 84),
        size: const Size(10.0, 10.0),
        activeSize: const Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
