import 'package:flutter/material.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/loading.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> genders = ['Male', 'Female', 'Attack Helicopter'];

  // form values
  String? _currentName;
  int? _currentAge;
  String _currentGender = 'Male';
  double? _currentWeight;
  double? _currentHeight;

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return _isLoading ? Loading() : Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            'Add a new baby',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          // name
          TextFormField(
            decoration: textInputDecoration.copyWith(hintText: 'Name'),
            validator: (val) => val!.isEmpty ? 'Please enter a name' : null,
            onChanged: (val) => setState(() => _currentName = val),
          ),
          SizedBox(height: 20.0),

          // dropdown gender
          DropdownButtonFormField(
            value: _currentGender,
            items: genders.map((gender) {
              return DropdownMenuItem(
                value: gender,
                child: Text('$gender'),
              );
            }).toList(),
            onChanged: (val) => setState(() => _currentGender = val!),
          ),

          SizedBox(height: 20.0),
          // age
          TextFormField(
            decoration: textInputDecoration.copyWith(hintText: 'Age (months)'),
            validator: (val) => val!.isEmpty ? 'Please enter an age' : null,
            onChanged: (val) => setState(() => _currentAge = int.parse(val)),
          ),

          SizedBox(height: 20.0),
          // weight
          TextFormField(
            decoration: textInputDecoration.copyWith(hintText: 'Weight (kg)'),
            validator: (val) => val!.isEmpty ? 'Please enter a weight' : null,
            onChanged: (val) => setState(() => _currentWeight = double.parse(val)),
          ),

          SizedBox(height: 20.0),
          // height
          TextFormField(
            decoration: textInputDecoration.copyWith(hintText: 'Height (cm)'),
            validator: (val) => val!.isEmpty ? 'Please enter a height' : null,
            onChanged: (val) => setState(() => _currentHeight = double.parse(val)),
          ),

          SizedBox(height: 20.0),
          // add button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: Text('Add Baby', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                setState(() => _isLoading = true);
                await DatabaseService(uid: user!.uid).addBaby(
                  _currentName!,
                  _currentGender,
                  _currentAge!,
                  _currentWeight!,
                  _currentHeight!,
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}