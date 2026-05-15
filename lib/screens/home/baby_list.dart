import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/screens/home/baby_tile.dart';

class BabyList extends StatefulWidget {
  const BabyList({super.key});

  @override
  State<BabyList> createState() => _BabyListState();
}

class _BabyListState extends State<BabyList> {
  @override
  Widget build(BuildContext context) {
    final babies = Provider.of<List<Baby>>(context) ?? [];

    return ListView.builder(
      itemCount: babies.length,
      itemBuilder: (context, index) {
        return BabyTile(baby: babies[index]);
      },
    );
  }
}
