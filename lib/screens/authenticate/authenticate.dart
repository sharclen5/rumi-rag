import 'package:flutter/material.dart';
import 'package:rumi/screens/authenticate/register.dart';
import 'package:rumi/screens/authenticate/sign_in.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  bool _showSuccessPopup = false;

  void toggleView({bool fromRegister = false}) {
    debugPrint('toggleView called — fromRegister: $fromRegister'); // DEBUG
    // CHANGED: terima flag opsional
    setState(() {
      showSignIn = !showSignIn;
      _showSuccessPopup =
          fromRegister; // ADDED: set flag kalau pindah dari register
    });
    debugPrint('_showSuccessPopup set to: $_showSuccessPopup'); // DEBUG
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return SignIn(
        toggleView: toggleView,
        showSuccessPopup: _showSuccessPopup,
      );
    } else {
      return Register(toggleView: toggleView);
    }
  }
}
