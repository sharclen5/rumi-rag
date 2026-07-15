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
    final babies = Provider.of<List<Baby>>(context);
    final user = Provider.of<User?>(context);

    // CHANGED: Column + Expanded(ListView) + separate button → single ListView.builder,
    // with the Add button as the list's final item instead of a sibling pinned to Expanded's bottom
    return ListView.builder(
      itemCount: babies.length + 1, // +1 slot for the Add button
      itemBuilder: (context, index) {
        if (index == babies.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF363434),
                onPressed: widget.onAddBaby,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          );
        }

        return BabyTile(
          baby: babies[index],
          onDelete: () =>
              DatabaseService(uid: user!.uid).deleteBaby(babies[index].id),
        );
      },
    );
  }
}
