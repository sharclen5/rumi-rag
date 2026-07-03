import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/shared/constants.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/services/recommendation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddRecommendation extends StatefulWidget {
  const AddRecommendation({super.key});

  @override
  State<AddRecommendation> createState() => _AddRecommendationState();
}

class _AddRecommendationState extends State<AddRecommendation> {
  final _formKey = GlobalKey<FormState>();

  Baby? _selectedBaby;
  String _currentNotes = '';
  String? _selectedDuration;
  Map<String, String> _allergyMap = {};
  bool _allergyMapLoaded = false;
  bool _isLoading = false;

  @override
  Future<void> _loadAllergyMap() async {
    if (_allergyMapLoaded) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('baby_allergies')
        .get();
    final map = <String, String>{};
    for (final doc in snapshot.docs) {
      map[doc.id] = doc.data()['name'] ?? '';
    }
    setState(() {
      _allergyMap = map;
      _allergyMapLoaded = true;
    });
  }

  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final uid = user?.uid ?? '';
    final babies = Provider.of<List<Baby>?>(context);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text('Buat Rencana Menu MPASI', style: TextStyle(fontSize: 18.0)),
              SizedBox(height: 20.0),

              if (_selectedBaby == null) ...[
                // center the dropdown + button when no baby selected
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              ],

              // baby dropdown
              DropdownButtonFormField<Baby>(
                value: _selectedBaby,
                hint: Text('Pilih Bayi'),
                items: (babies ?? []).map((baby) {
                  return DropdownMenuItem<Baby>(
                    value: baby,
                    child: Text(baby.fullName),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() => _selectedBaby = val);
                  if (val != null) _loadAllergyMap();
                },
                validator: (val) =>
                    val == null ? 'Pilih bayi terlebih dahulu' : null,
              ),

              // munculin data bayi yang dipilih, read only
              if (_selectedBaby != null) ...[
                SizedBox(height: 20.0),

                // first name
                TextFormField(
                  initialValue: _selectedBaby!.firstName,
                  readOnly: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'First Name',
                    hintText: 'First Name',
                  ),
                ),
                SizedBox(height: 20.0),

                // middle name (read-only, only shown if exists)
                if (_selectedBaby!.middleName != null &&
                    _selectedBaby!.middleName!.isNotEmpty) ...[
                  TextFormField(
                    initialValue: _selectedBaby!.middleName,
                    readOnly: true,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Middle Name',
                      hintText: 'Middle Name',
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],

                // last name (read-only)
                TextFormField(
                  initialValue: _selectedBaby!.lastName,
                  readOnly: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Last Name',
                    hintText: 'Last Name',
                  ),
                ),
                SizedBox(height: 20.0),

                // gender (read-only)
                TextFormField(
                  initialValue: _selectedBaby!.gender,
                  readOnly: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Gender',
                    hintText: 'Gender',
                  ),
                ),
                SizedBox(height: 20.0),

                // date of birth (read-only)
                TextFormField(
                  initialValue:
                      '${_selectedBaby!.dateOfBirth.day}/${_selectedBaby!.dateOfBirth.month}/${_selectedBaby!.dateOfBirth.year}',
                  readOnly: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Date of Birth',
                    hintText: 'Date of Birth',
                  ),
                ),
                SizedBox(height: 20.0),

                // weight (read-only)
                TextFormField(
                  initialValue: '${_selectedBaby!.weight} kg',
                  readOnly: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Weight (kg)',
                    hintText: 'Weight (kg)',
                  ),
                ),
                SizedBox(height: 20.0),

                // height (read-only)
                TextFormField(
                  initialValue: '${_selectedBaby!.height} cm',
                  readOnly: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Height (cm)',
                    hintText: 'Height (cm)',
                  ),
                ),
                SizedBox(height: 20.0),

                // usia bayi dalam bulan (pake usia koreksi jika prematur)
                TextFormField(
                  initialValue: _selectedBaby!.isPremature
                      ? '${_selectedBaby!.correctedAgeInMonths} bulan (usia koreksi)'
                      : '${_selectedBaby!.ageInMonths} bulan',
                  readOnly: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Usia',
                    hintText: 'Usia',
                  ),
                ),
                SizedBox(height: 20.0),

                // status menyusu ASI
                TextFormField(
                  initialValue: _selectedBaby!.isActivelyBreastfed
                      ? 'Masih menyusu ASI'
                      : 'Tidak menyusu ASI',
                  readOnly: true,
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Status ASI',
                    hintText: 'Status ASI',
                  ),
                ),
                SizedBox(height: 20.0),

                // jumlah gigi, hanya tampil jika ada datanya
                if (_selectedBaby!.toothCount != null) ...[
                  TextFormField(
                    initialValue: '${_selectedBaby!.toothCount} gigi',
                    readOnly: true,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Jumlah Gigi',
                      hintText: 'Jumlah Gigi',
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],

                // riwayat penyakit, hanya tampil jika ada datanya
                if (_selectedBaby!.medicalHistory != null &&
                    _selectedBaby!.medicalHistory!.isNotEmpty) ...[
                  TextFormField(
                    initialValue: _selectedBaby!.medicalHistory,
                    readOnly: true,
                    maxLines: 3,
                    decoration: textInputDecoration.copyWith(
                      labelText: 'Riwayat Penyakit',
                      hintText: 'Riwayat Penyakit',
                    ),
                  ),
                  SizedBox(height: 20.0),
                ],

                // tampilkan nama alergi, hanya muncul jika bayi punya alergi
                if (_selectedBaby!.allergyIds.isNotEmpty) ...[
                  !_allergyMapLoaded
                      // loading indicator sementara map belum selesai di-fetch
                      ? Center(child: CircularProgressIndicator())
                      : TextFormField(
                          // resolve ID -> nama, gabungkan dengan koma
                          initialValue: _selectedBaby!.allergyIds
                              .map((id) => _allergyMap[id] ?? id)
                              .join(', '),
                          readOnly: true,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Alergi',
                            hintText: 'Alergi',
                          ),
                        ),
                  SizedBox(height: 20.0),
                ],

                // catatan kesehatan khusus
                TextFormField(
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Catatan Kesehatan Khusus',
                    hintText: 'Catatan Kesehatan Khusus (Opsional)',
                  ),
                  maxLines: 3,
                  onChanged: (val) => setState(() => _currentNotes = val),
                ),
                SizedBox(height: 20),

                // duration selection
                DropdownButtonFormField<String>(
                  value: _selectedDuration,
                  hint: Text('Pilih Durasi'),
                  decoration: textInputDecoration.copyWith(
                    labelText: 'Durasi Rencana',
                  ),
                  items: ['1 Minggu', '2 Minggu', '1 Bulan'].map((duration) {
                    return DropdownMenuItem<String>(
                      value: duration,
                      child: Text(duration),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedDuration = val),
                  validator: (val) =>
                      val == null ? 'Pilih durasi rencana' : null,
                ),

                SizedBox(height: 20),

                // submit
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 144, 121, 84),
                    foregroundColor: Colors.white,
                  ),
                  // =====================
                  // CHANGED: call API → save → pop
                  // =====================
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => _isLoading = true);

                          try {
                            final user = Provider.of<User?>(
                              context,
                              listen: false,
                            );
                            final uid = user?.uid ?? '';
                            final baby = _selectedBaby!;
                            final now = DateTime.now();
                            final startDate =
                                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

                            // resolve allergyIds → names
                            final allergyNames = baby.allergyIds
                                .map((id) => _allergyMap[id] ?? id)
                                .toList();

                            // convert duration selection to days int
                            final days = switch (_selectedDuration) {
                              '1 Minggu' => 7,
                              '2 Minggu' => 14,
                              '1 Bulan' => 30,
                              _ => 7,
                            };

                            // call API — backend generates each day and writes to Firestore
                            await RecommendationService()
                                .getWeeklyRecommendation(
                                  uid: uid,
                                  babyId: baby.id,
                                  ageInMonths: baby.ageInMonths,
                                  correctedAgeInMonths:
                                      baby.correctedAgeInMonths,
                                  weight: baby.weight,
                                  height: baby.height,
                                  gender: baby.gender,
                                  isPremature: baby.isPremature,
                                  isActivelyBreastfed: baby.isActivelyBreastfed,
                                  toothCount: baby.toothCount,
                                  allergies: allergyNames,
                                  medicalHistory: baby.medicalHistory,
                                  startDate: startDate,
                                  days: days,
                                );

                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal membuat rencana: $e'),
                                ),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                  // =====================
                  // END CHANGE
                  // =====================
                  child: _isLoading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Buat Rencana',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
