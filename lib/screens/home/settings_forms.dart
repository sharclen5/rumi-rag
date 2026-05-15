import 'package:flutter/material.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/constants.dart';
import 'package:provider/provider.dart';
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
  String? _currentGender;
  double? _currentWeight;
  double? _currentHeight;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user!.uid).userData,
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          UserData userData = asyncSnapshot.data!;
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
                  initialValue: userData.name,
                  decoration: textInputDecoration.copyWith(hintText: 'Name'),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter a name' : null,
                  onChanged: (val) => setState(() => _currentName = val),
                ),
                SizedBox(height: 20.0),

                // dropdown gender
                DropdownButtonFormField(
                  value:
                      _currentGender ??
                      (genders.contains(userData.gender)
                          ? userData.gender
                          : genders.first),
                  items: genders.map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text('$gender'),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _currentGender = val),
                ),

                SizedBox(height: 20.0),
                // age
                TextFormField(
                  initialValue: userData.age != 0
                      ? userData.age.toString()
                      : '0',
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Age (months)',
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter an age' : null,
                  onChanged: (val) =>
                      setState(() => _currentAge = int.parse(val)),
                ),

                SizedBox(height: 20.0),

                // weight
                TextFormField(
                  initialValue: userData.weight != 0
                      ? userData.weight.toString()
                      : '0',
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Weight (kg)',
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter a weight' : null,
                  onChanged: (val) =>
                      setState(() => _currentWeight = double.parse(val)),
                ),

                SizedBox(height: 20.0),
                // height
                TextFormField(
                  initialValue: userData.height != 0
                      ? userData.height.toString()
                      : '0',
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Height (cm)',
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Please enter a height' : null,
                  onChanged: (val) =>
                      setState(() => _currentHeight = double.parse(val)),
                ),

                // update button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Update', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await DatabaseService(uid: user.uid).updateUserData(
                        _currentName ?? userData.name,
                        _currentGender ?? userData.gender,
                        _currentAge ?? userData.age,
                        (_currentWeight ?? userData.weight).toDouble(),
                        (_currentHeight ?? userData.height).toDouble(),
                      );
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}
