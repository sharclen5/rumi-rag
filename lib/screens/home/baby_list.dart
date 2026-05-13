import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/baby.dart';

class BabyList extends StatefulWidget {
  const BabyList({super.key});

  @override
  State<BabyList> createState() => _BabyListState();
}

class _BabyListState extends State<BabyList> {
  @override
  Widget build(BuildContext context) {
    final babies = Provider.of<List<Baby?>>(context);
    babies.forEach((baby) {
      if (baby != null) {
        debugPrint(baby.name);
        debugPrint(baby.age.toString());
        debugPrint(baby.gender);
        debugPrint(baby.weight.toString());
        debugPrint(baby.height.toString());
      }
    });

    return const Placeholder();
  }
}
