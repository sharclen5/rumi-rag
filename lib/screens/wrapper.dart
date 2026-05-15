import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/screens/authenticate/authenticate.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/screens/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    debugPrint(user.toString());

    //return either home or authenticate widget
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}
