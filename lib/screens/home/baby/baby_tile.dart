import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/screens/home/baby/update_baby_forms.dart';

class BabyTile extends StatelessWidget {
  final Baby baby;
  final VoidCallback onDelete;
  BabyTile({required this.baby, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(5.0, 6.0, 5.0, 0.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25.0,
                backgroundColor: baby.gender.toLowerCase() == 'male'
                    ? Colors.blue
                    : Colors.pinkAccent,
                child: Text(
                  baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baby.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Age: ${baby.age} months'),
                    Text('Weight: ${baby.weight} kg'),
                    Text('Height: ${baby.height} cm'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_document, color: Colors.blue),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.0,
                        horizontal: 60.0,
                      ),
                      child: UpdateBabyForms(baby: baby),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Data Bayi'),
                      content: Text('Hapus ${baby.name}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) onDelete();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
