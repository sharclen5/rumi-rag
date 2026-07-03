import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(255, 242, 218, 177),
      child: Center(
        child: SpinKitSquareCircle(color: Color(0xFF363434), size: 50.0),
      ),
    );
  }
}
