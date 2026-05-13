import 'package:flutter/material.dart';
import 'package:rumi/shared/constants.dart';

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
  String? _currentGender;
  int? _currentWeight;
  int? _currentHeight;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Text(
            'Update your baby\'s information',
            style: TextStyle(fontSize: 18.0),
          ),
          SizedBox(height: 20.0),
          // name
          TextFormField(
            initialValue: _currentName,
            decoration: textInputDecoration.copyWith(hintText: 'Name'),
            validator: (val) => val!.isEmpty ? 'Please enter a name' : null,
            onChanged: (val) => setState(() => _currentName = val),
          ),
          SizedBox(height: 20.0),

          // dropdown gender
          DropdownButtonFormField(
            value: _currentGender ?? 'Attack Helicopter',
            items: genders.map((gender) {
              return DropdownMenuItem(value: gender, child: Text('$gender'));
            }).toList(),
            onChanged: (val) => setState(() => _currentGender = val),
          ),

          SizedBox(height: 20.0),
          // age
          TextFormField(
            initialValue: _currentAge != null ? _currentAge.toString() : '',
            decoration: textInputDecoration.copyWith(hintText: 'Age (months)'),
            validator: (val) => val!.isEmpty ? 'Please enter an age' : null,
            onChanged: (val) => setState(() => _currentAge = int.parse(val)),
          ),

          SizedBox(height: 20.0),

          // weight
          TextFormField(
            initialValue: _currentWeight != null
                ? _currentWeight.toString()
                : '',
            decoration: textInputDecoration.copyWith(hintText: 'Weight (kg)'),
            validator: (val) => val!.isEmpty ? 'Please enter a weight' : null,
            onChanged: (val) => setState(() => _currentWeight = int.parse(val)),
          ),

          SizedBox(height: 20.0),
          // height
          TextFormField(
            initialValue: _currentHeight != null
                ? _currentHeight.toString()
                : '',
            decoration: textInputDecoration.copyWith(hintText: 'Height (cm)'),
            validator: (val) => val!.isEmpty ? 'Please enter a height' : null,
            onChanged: (val) => setState(() => _currentHeight = int.parse(val)),
          ),

          // update button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: Text('Update', style: TextStyle(color: Colors.white)),
            onPressed: () async {
              debugPrint(_currentName);
              debugPrint(_currentAge.toString());
              debugPrint(_currentGender);
              debugPrint(_currentWeight.toString());
              debugPrint(_currentHeight.toString());
            },
          ),
        ],
      ),
    );
  }
}
