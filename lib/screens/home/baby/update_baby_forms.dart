import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/loading.dart';

class UpdateBabyForms extends StatefulWidget {
  final Baby baby;
  const UpdateBabyForms({super.key, required this.baby});

  @override
  State<UpdateBabyForms> createState() => _UpdateBabyFormsState();
}

class _UpdateBabyFormsState extends State<UpdateBabyForms> {
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
  void initState() {
    super.initState();
    _currentName = widget.baby.name;
    _currentGender = widget.baby.gender;
    _currentAge = widget.baby.age;
    _currentWeight = widget.baby.weight;
    _currentHeight = widget.baby.height;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return _isLoading
        ? Loading()
        : SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text('Update Baby', style: TextStyle(fontSize: 18.0)),
                  SizedBox(height: 20.0),
                  // name
                  TextFormField(
                    initialValue: _currentName,
                    decoration: textInputDecoration.copyWith(hintText: 'Name'),
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a name' : null,
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
                    initialValue: _currentAge?.toString(),
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
                    initialValue: _currentWeight?.toString(),
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
                    initialValue: _currentHeight?.toString(),
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Height (cm)',
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a height' : null,
                    onChanged: (val) =>
                        setState(() => _currentHeight = double.parse(val)),
                  ),

                  SizedBox(height: 20.0),
                  // add button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Update Data',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        await DatabaseService(uid: user!.uid).updateBaby(
                          widget.baby.id,
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
            ),
          );
  }
}
