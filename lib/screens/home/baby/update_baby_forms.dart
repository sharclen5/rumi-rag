import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/constants.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/loading.dart';
import 'package:rumi/shared/allergy_selector.dart';

class UpdateBabyForms extends StatefulWidget {
  final Baby baby;
  const UpdateBabyForms({super.key, required this.baby});

  @override
  State<UpdateBabyForms> createState() => _UpdateBabyFormsState();
}

class _UpdateBabyFormsState extends State<UpdateBabyForms> {
  final _formKey = GlobalKey<FormState>();
  final List<String> genders = ['Male', 'Female'];

  late bool _isPremature;
  late int? _gestationalAgeWeeks;
  late bool _isActivelyBreastfed;
  late int? _toothCount;
  late String? _medicalHistory;
  late List<String> _selectedAllergyIds;

  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _gestationalAgeController;
  late final TextEditingController _toothCountController;
  late final TextEditingController _medicalHistoryController;

  String _currentGender = 'Male';
  DateTime? _currentDOB;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.baby.firstName);
    _middleNameController = TextEditingController(
      text: widget.baby.middleName ?? '',
    );
    _lastNameController = TextEditingController(text: widget.baby.lastName);
    _weightController = TextEditingController(
      text: widget.baby.weight.toString(),
    );
    _heightController = TextEditingController(
      text: widget.baby.height.toString(),
    );
    _currentGender = widget.baby.gender;
    _currentDOB = widget.baby.dateOfBirth;
    _isPremature = widget.baby.isPremature;
    _gestationalAgeWeeks = widget.baby.gestationalAgeWeeks;
    _isActivelyBreastfed = widget.baby.isActivelyBreastfed;
    _toothCount = widget.baby.toothCount;
    _medicalHistory = widget.baby.medicalHistory;
    _selectedAllergyIds = List.from(widget.baby.allergyIds);
    _gestationalAgeController = TextEditingController(
      text: widget.baby.gestationalAgeWeeks?.toString() ?? '',
    );
    _toothCountController = TextEditingController(
      text: widget.baby.toothCount?.toString() ?? '',
    );
    _medicalHistoryController = TextEditingController(
      text: widget.baby.medicalHistory ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _gestationalAgeController.dispose();
    _toothCountController.dispose();
    _medicalHistoryController.dispose();
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
                  Text('Update Baby', style: TextStyle(fontSize: 18.0)),
                  SizedBox(height: 20.0),

                  // first name
                  TextFormField(
                    controller: _firstNameController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'First Name',
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
                      labelText: 'Middle Name (Optional)',
                      hintText: 'Middle Name (Optional)',
                    ),
                  ),
                  SizedBox(height: 20.0),

                  // last name
                  TextFormField(
                    controller: _lastNameController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Last Name',
                      hintText: 'Last Name',
                    ),
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a last name' : null,
                  ),
                  SizedBox(height: 20.0),

                  // gender
                  DropdownButtonFormField(
                    value: _currentGender,
                    decoration: InputDecoration(labelText: 'Gender'),
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
                        controller: TextEditingController(
                          text: _currentDOB == null
                              ? ''
                              : '${_currentDOB!.day}/${_currentDOB!.month}/${_currentDOB!.year}',
                        ),
                        decoration: textInputDecoration.copyWith(
                          labelText: 'Date of Birth',
                          hintText: 'Pilih Tanggal Lahir',
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
                    controller: _weightController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Weight (kg)',
                      hintText: 'Weight (kg)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a weight' : null,
                  ),
                  SizedBox(height: 20.0),

                  // height
                  TextFormField(
                    controller: _heightController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Height (cm)',
                      hintText: 'Height (cm)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a height' : null,
                  ),
                  SizedBox(height: 20.0),

                  // alergi selector dengan nilai awal dari data bayi
                  AllergySelector(
                    initialSelectedIds: _selectedAllergyIds,
                    onChanged: (ids) =>
                        setState(() => _selectedAllergyIds = ids),
                  ),
                  SizedBox(height: 20.0),

                  // toggle menyusu aktif
                  SwitchListTile(
                    title: Text('Masih menyusu ASI?'),
                    value: _isActivelyBreastfed,
                    onChanged: (val) =>
                        setState(() => _isActivelyBreastfed = val),
                  ),
                  SizedBox(height: 20.0),

                  // toggle prematur
                  SwitchListTile(
                    title: Text('Bayi lahir prematur?'),
                    value: _isPremature,
                    onChanged: (val) => setState(() {
                      _isPremature = val;
                      // ✏️ reset usia gestasi dan controller-nya kalau toggle dimatikan
                      if (!val) {
                        _gestationalAgeWeeks = null;
                        _gestationalAgeController.clear();
                      }
                    }),
                  ),

                  // ✏️ field usia gestasi hanya muncul jika isPremature == true
                  if (_isPremature) ...[
                    SizedBox(height: 20.0),
                    TextFormField(
                      controller: _gestationalAgeController,
                      decoration: textInputDecoration.copyWith(
                        labelText: 'Usia Gestasi Saat Lahir (minggu)',
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
                    controller: _toothCountController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Jumlah Gigi (Opsional)',
                      hintText: 'Jumlah Gigi (Opsional)',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) =>
                        setState(() => _toothCount = int.tryParse(val)),
                  ),
                  SizedBox(height: 20.0),

                  // riwayat penyakit (opsional)
                  TextFormField(
                    controller: _medicalHistoryController,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Riwayat Penyakit (Opsional)',
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
                          _firstNameController.text,
                          _middleNameController.text.trim().isEmpty
                              ? null
                              : _middleNameController.text.trim(),
                          _lastNameController.text,
                          _currentGender,
                          _currentDOB!,
                          double.parse(_weightController.text),
                          double.parse(_heightController.text),
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
