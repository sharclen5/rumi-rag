import 'package:flutter/material.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/loading.dart';
import 'package:rumi/shared/allergy_selector.dart';

class AddBabyForms extends StatefulWidget {
  const AddBabyForms({super.key});

  @override
  State<AddBabyForms> createState() => _AddBabyFormsState();
}

class _AddBabyFormsState extends State<AddBabyForms> {
  final _formKey = GlobalKey<FormState>();
  final List<String> genders = ['Male', 'Female'];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  String _currentGender = 'Male';
  double? _currentWeight;
  double? _currentHeight;
  DateTime? _currentDOB;
  bool _isPremature = false;
  int? _gestationalAgeWeeks;
  bool _isActivelyBreastfed = true;
  int? _toothCount;
  String? _medicalHistory;
  List<String> _selectedAllergyIds = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Stack(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text('Add a new baby', style: TextStyle(fontSize: 18.0)),
                  SizedBox(height: 20.0),

                  // first name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'First Name',
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a first name' : null,
                  ),
                  SizedBox(height: 20.0),

                  // middle name
                  TextFormField(
                    controller: _middleNameController,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Middle Name (Optional)',
                    ),
                  ),
                  SizedBox(height: 20.0),

                  // last name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Last Name',
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a last name' : null,
                  ),
                  SizedBox(height: 20.0),

                  // gender
                  DropdownButtonFormField(
                    value: _currentGender,
                    items: genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _currentGender = val!),
                  ),
                  SizedBox(height: 20.0),

                  // date of birth
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _currentDOB ?? DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 5),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _currentDOB = picked);
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: textInputDecoration.copyWith(
                          hintText: _currentDOB == null
                              ? 'Date of Birth'
                              : '${_currentDOB!.day}/${_currentDOB!.month}/${_currentDOB!.year}',
                        ),
                        validator: (_) => _currentDOB == null
                            ? 'Please select a date of birth'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),

                  // weight
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Weight (kg)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a weight' : null,
                    onChanged: (val) =>
                        setState(() => _currentWeight = double.tryParse(val)),
                  ),
                  SizedBox(height: 20.0),

                  // height
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Height (cm)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a height' : null,
                    onChanged: (val) =>
                        setState(() => _currentHeight = double.tryParse(val)),
                  ),
                  SizedBox(height: 20.0),

                  AllergySelector(
                    onChanged: (ids) =>
                        setState(() => _selectedAllergyIds = ids),
                  ),
                  SizedBox(height: 20.0),

                  // tombol menyusu aktif
                  SwitchListTile(
                    title: Text('Masih menyusu ASI?'),
                    value: _isActivelyBreastfed,
                    onChanged: (val) =>
                        setState(() => _isActivelyBreastfed = val),
                  ),
                  SizedBox(height: 20.0),

                  // checkbox prematur, nampilin field usia gestasi kalo true
                  SwitchListTile(
                    title: Text('Bayi lahir prematur?'),
                    value: _isPremature,
                    onChanged: (val) => setState(() {
                      _isPremature = val;
                      // reset usia gestasi kalo toggle dimatiin
                      if (!val) _gestationalAgeWeeks = null;
                    }),
                  ),

                  //  field usia gestasi cuman muncul kalo isPremature == true
                  if (_isPremature) ...[
                    SizedBox(height: 20.0),
                    TextFormField(
                      decoration: textInputDecoration.copyWith(
                        hintText: 'Usia Gestasi Saat Lahir (minggu)',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (_isPremature && (val == null || val.isEmpty)) {
                          return 'Masukkan usia gestasi saat lahir';
                        }
                        final parsed = int.tryParse(val ?? '');
                        if (parsed == null || parsed < 24 || parsed > 36) {
                          return 'Usia gestasi prematur biasanya 24–36 minggu';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(
                        () => _gestationalAgeWeeks = int.tryParse(val),
                      ),
                    ),
                  ],
                  SizedBox(height: 20.0),

                  // jumlah gigi (opsional)
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Jumlah Gigi (Opsional)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        setState(() => _toothCount = int.tryParse(val)),
                  ),
                  SizedBox(height: 20.0),

                  // riwayat penyakit (opsional)
                  TextFormField(
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Riwayat Penyakit (Opsional)',
                    ),
                    maxLines: 3,
                    onChanged: (val) => setState(
                      () => _medicalHistory = val.trim().isEmpty
                          ? null
                          : val.trim(),
                    ),
                  ),
                  SizedBox(height: 20.0),

                  // submit
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF363434),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Add Baby',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        await DatabaseService(uid: user!.uid).addBaby(
                          _firstNameController.text,
                          _middleNameController.text.trim().isEmpty
                              ? null
                              : _middleNameController.text.trim(),
                          _lastNameController.text,
                          _currentGender,
                          _currentDOB!,
                          _currentWeight!,
                          _currentHeight!,
                          _selectedAllergyIds,
                          _isPremature,
                          _gestationalAgeWeeks,
                          _isActivelyBreastfed,
                          _toothCount,
                          _medicalHistory,
                        );
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(child: Loading()),
            ),
          ),
      ],
    );
  }
}
