import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/screens/home/baby/baby_tile.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/services/database.dart';

class BabyList extends StatefulWidget {
  final VoidCallback onAddBaby;
  const BabyList({super.key, required this.onAddBaby});

  @override
  State<BabyList> createState() => _BabyListState();
}

class _BabyListState extends State<BabyList> {
  @override
  Widget build(BuildContext context) {
    final babies = Provider.of<List<Baby>>(context) ?? [];
    final user = Provider.of<User?>(context);

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: babies.length,
          itemBuilder: (context, index) {
            return BabyTile(
              baby: babies[index],
              onDelete: () =>
                  DatabaseService(uid: user!.uid).deleteBaby(babies[index].id),
            );
          },
        ),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.center,
          child: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            onPressed: widget.onAddBaby,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
