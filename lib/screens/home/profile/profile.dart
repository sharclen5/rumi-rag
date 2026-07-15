import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/screens/home/baby/baby_page.dart';
import 'package:rumi/services/auth.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/screens/home/profile/profile_detail.dart';
import 'package:rumi/screens/onboarding/tutorial_mark.dart';
import 'package:rumi/screens/onboarding/intro_slides.dart';

class ProfilePage extends StatelessWidget {
  final Function(int) onTabTapped;
  ProfilePage({super.key, required this.onTabTapped});
  final AuthService _auth = AuthService();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamBuilder<UserProfile?>(
      stream: user != null ? DatabaseService(uid: user.uid).userProfile : null,
      builder: (context, snapshot) {
        final userProfile = snapshot.data;

        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 113, 222, 255),
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Color.fromARGB(255, 242, 218, 177),
            foregroundColor: Colors.white,
            title: const Text(
              "My Account",
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

            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  ProfilePic(photoUrl: userProfile?.photoUrl),
                  const SizedBox(height: 20),
                  ProfileMenu(
                    text: "Profile Detail",
                    icon: Icon(Icons.person, size: 22),
                    press: userProfile == null
                        ? null // disable button while loading
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetail(
                                user: userProfile,
                                onTabTapped: onTabTapped,
                              ),
                            ),
                          ),
                  ),
                  ProfileMenu(
                    text: "Data Bayi",
                    icon: Icon(Icons.child_care, size: 22),
                    press: userProfile == null
                        ? null // disable button while loading
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BabyPage(onTabTapped: onTabTapped),
                            ),
                          ),
                  ),
                  ProfileMenu(
                    text: "Settings",
                    icon: Icon(Icons.settings, size: 22),
                    press: () {},
                  ),
                  ProfileMenu(
                    text: "Preview Intro Slides",
                    icon: Icon(Icons.slideshow, size: 22),
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        // just pop back on "Done" — no Firestore write, this is a preview only
                        builder: (_) =>
                            IntroSlides(onDone: () => Navigator.pop(context)),
                      ),
                    ),
                  ),
                  ProfileMenu(
                    text: "Tutorial",
                    icon: Icon(Icons.help, size: 22),
                    press: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TutorialMark()),
                    ),
                  ),
                  ProfileMenu(
                    text: "Log Out",
                    icon: Icon(Icons.logout, size: 22),
                    press: () async {
                      await _auth.signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
          extendBody: true,
          bottomNavigationBar: BottomNavBar(
            currentIndex: 4,
            onTap: onTabTapped,
            photoUrl: snapshot.data?.photoUrl,
          ),
        );
      },
    );
  }
}

class ProfilePic extends StatelessWidget {
  final String? photoUrl;
  const ProfilePic({Key? key, this.photoUrl}) : super(key: key);

  ImageProvider _resolveImage() {
    if (photoUrl!.startsWith('data:image')) {
      return MemoryImage(base64Decode(photoUrl!.split(',').last));
    }
    return NetworkImage(photoUrl!);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          photoUrl != null
              ? CircleAvatar(backgroundImage: _resolveImage())
              : CircleAvatar(
                  backgroundColor: Color(0xFFE8C99A),
                  child: Icon(Icons.person, color: Color(0xFF8B6F47), size: 40),
                ),
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
  }) : super(key: key);

  final String text;
  final dynamic icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF363434),
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(0xFFE8D5B7), width: 1.5),
          ),
          backgroundColor: Color(0xFFFDF8F2),
        ),
        onPressed: press,
        child: Row(
          children: [
            if (icon is String)
              SvgPicture.asset(
                icon,
                colorFilter: const ColorFilter.mode(
                  Color(0xFF363434),
                  BlendMode.srcIn,
                ),
                width: 22,
              )
            else
              icon,
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Color(0xFF757575)),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFF757575)),
          ],
        ),
      ),
    );
  }
}
