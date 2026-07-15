import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/database.dart';
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

  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const _border = Color(0xFFE8D5B7);
  static const _text = Color(0xFF363434);

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

  // brand-matched field decoration, independent of constants.dart's textInputDecoration
  // so this dialog isn't tied to whatever styling that shared constant carries elsewhere
  InputDecoration _fieldDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 13),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border, width: 1.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _brand, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // header — same language as BabyDetail's dialog header
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Edit Data ${widget.baby.firstName}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _text,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _border,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: _text,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: _border, height: 1),

                // scrollable form body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            controller: _firstNameController,
                            decoration: _fieldDecoration('Nama Depan'),
                            validator: (val) =>
                                val!.isEmpty ? 'Masukkan nama depan' : null,
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _middleNameController,
                            decoration: _fieldDecoration(
                              'Nama Tengah (Opsional)',
                            ),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _lastNameController,
                            decoration: _fieldDecoration('Nama Belakang'),
                            validator: (val) =>
                                val!.isEmpty ? 'Masukkan nama belakang' : null,
                          ),
                          const SizedBox(height: 14),

                          DropdownButtonFormField(
                            value: _currentGender,
                            decoration: _fieldDecoration('Jenis Kelamin'),
                            dropdownColor: const Color(0xFFFDF8F2),
                            style: const TextStyle(color: _text, fontSize: 14),
                            items: genders.map((gender) {
                              return DropdownMenuItem(
                                value: gender,
                                child: Text(
                                  gender == 'Male' ? 'Laki-laki' : 'Perempuan',
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _currentGender = val!),
                          ),
                          const SizedBox(height: 14),

                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _currentDOB ?? DateTime.now(),
                                firstDate: DateTime(DateTime.now().year - 5),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null)
                                setState(() => _currentDOB = picked);
                            },
                            child: AbsorbPointer(
                              child: TextFormField(
                                controller: TextEditingController(
                                  text: _currentDOB == null
                                      ? ''
                                      : '${_currentDOB!.day}/${_currentDOB!.month}/${_currentDOB!.year}',
                                ),
                                decoration: _fieldDecoration('Tanggal Lahir')
                                    .copyWith(
                                      suffixIcon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                        color: _brand,
                                      ),
                                    ),
                                validator: (_) => _currentDOB == null
                                    ? 'Pilih tanggal lahir'
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _weightController,
                                  decoration: _fieldDecoration('Berat (kg)'),
                                  keyboardType: TextInputType.number,
                                  validator: (val) =>
                                      val!.isEmpty ? 'Masukkan berat' : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _heightController,
                                  decoration: _fieldDecoration('Tinggi (cm)'),
                                  keyboardType: TextInputType.number,
                                  validator: (val) =>
                                      val!.isEmpty ? 'Masukkan tinggi' : null,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          AllergySelector(
                            initialSelectedIds: _selectedAllergyIds,
                            onChanged: (ids) =>
                                setState(() => _selectedAllergyIds = ids),
                          ),
                          const SizedBox(height: 8),

                          // brand-styled switch container instead of stock SwitchListTile
                          _buildSwitchTile(
                            'Masih menyusu ASI?',
                            _isActivelyBreastfed,
                            (val) => setState(() => _isActivelyBreastfed = val),
                          ),
                          const SizedBox(height: 8),

                          _buildSwitchTile(
                            'Bayi lahir prematur?',
                            _isPremature,
                            (val) => setState(() {
                              _isPremature = val;
                              if (!val) {
                                _gestationalAgeWeeks = null;
                                _gestationalAgeController.clear();
                              }
                            }),
                          ),

                          if (_isPremature) ...[
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _gestationalAgeController,
                              decoration: _fieldDecoration(
                                'Usia Gestasi Saat Lahir (minggu)',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (_isPremature &&
                                    (val == null || val.isEmpty)) {
                                  return 'Masukkan usia gestasi saat lahir';
                                }
                                final parsed = int.tryParse(val ?? '');
                                if (parsed == null ||
                                    parsed < 24 ||
                                    parsed > 36) {
                                  return 'Usia gestasi prematur biasanya 24–36 minggu';
                                }
                                return null;
                              },
                              onChanged: (val) => setState(
                                () => _gestationalAgeWeeks = int.tryParse(val),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _toothCountController,
                            decoration: _fieldDecoration(
                              'Jumlah Gigi (Opsional)',
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) =>
                                setState(() => _toothCount = int.tryParse(val)),
                          ),
                          const SizedBox(height: 14),

                          TextFormField(
                            controller: _medicalHistoryController,
                            decoration: _fieldDecoration(
                              'Riwayat Penyakit (Opsional)',
                            ),
                            maxLines: 3,
                            onChanged: (val) => setState(
                              () => _medicalHistory = val.trim().isEmpty
                                  ? null
                                  : val.trim(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // footer — submit button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brand,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                          if (context.mounted) Navigator.pop(context);
                        }
                      },
                      child: const Text('Simpan Perubahan'),
                    ),
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Loading()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // brand-styled switch row, replaces the stock Material SwitchListTile
  Widget _buildSwitchTile(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: value ? _brand.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: _text,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _brand,
            activeTrackColor: _brand.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
