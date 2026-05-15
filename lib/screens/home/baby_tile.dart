import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';

class BabyTile extends StatelessWidget {
  final Baby baby;
  BabyTile({required this.baby});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.deepOrange,
            child: Text(
              baby.name.isNotEmpty ? baby.name[0].toUpperCase() : '?',
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ),
          title: Text(baby.name),
          subtitle: Text('Age: ${baby.age} months'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Weight: ${baby.weight} kg'),
              Text('Height: ${baby.height} cm'),
            ],
          ),
        ),
      ),
    );
  }
}
