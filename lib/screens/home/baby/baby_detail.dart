import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/screens/home/baby/update_baby_forms.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BabyDetail extends StatelessWidget {
  final Baby baby;
  final VoidCallback onDelete;

  const BabyDetail({super.key, required this.baby, required this.onDelete});

  static const _brand = Color.fromARGB(255, 144, 121, 84);

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF363434),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // resolves baby.allergyIds → comma-separated names
  Future<String> _resolveAllergyNames() async {
    if (baby.allergyIds.isEmpty) return 'Tidak Ada';
    final snapshot = await FirebaseFirestore.instance
        .collection('baby_allergies')
        .where(FieldPath.documentId, whereIn: baby.allergyIds)
        .get();
    final names = snapshot.docs
        .map((d) => d.data()['name'] as String? ?? '')
        .where((n) => n.isNotEmpty)
        .toList();
    return names.isEmpty ? '-' : names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final isMale = baby.gender.toLowerCase() == 'male';
    final avatarColor = isMale
        ? const Color.fromARGB(255, 140, 202, 253)
        : const Color.fromARGB(255, 255, 146, 182);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8D5B7), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header, same layout language as RecommendationDetailDialog
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarColor,
                    child: Text(
                      baby.firstName.isNotEmpty
                          ? baby.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          baby.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363434),
                          ),
                        ),
                        Text(
                          '${baby.ageInMonths} bulan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8D5B7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFF363434),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: const Color(0xFFE8D5B7), height: 1),

            // scrollable info body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Berat', ':  ${baby.weight} kg'),
                    _infoRow('Tinggi', ':  ${baby.height} cm'),
                    _infoRow(
                      'Tanggal Lahir',
                      ':  ${baby.dateOfBirth.day}/${baby.dateOfBirth.month}/${baby.dateOfBirth.year}',
                    ),
                    _infoRow(
                      'Jenis Kelamin',
                      baby.gender.toLowerCase() == 'male'
                          ? ':  Laki-laki'
                          : ':  Perempuan',
                    ),
                    _infoRow(
                      'Masih ASI',
                      baby.isActivelyBreastfed ? ':  Ya' : ':  Tidak',
                    ),
                    _infoRow(
                      'Prematur',
                      baby.isPremature
                          ? ':  Ya (${baby.gestationalAgeWeeks ?? '-'} minggu)'
                          : ':  Tidak',
                    ),
                    if (baby.isPremature)
                      _infoRow(
                        'Usia Koreksi',
                        ':  ${baby.correctedAgeInMonths} bulan',
                      ),
                    _infoRow(
                      'Jumlah Gigi',
                      baby.toothCount != null
                          ? ':  ${baby.toothCount}'
                          : ':  -',
                    ),

                    FutureBuilder<String>(
                      future: _resolveAllergyNames(),
                      builder: (context, snapshot) {
                        final value = snapshot.hasData
                            ? ':  ${snapshot.data}'
                            : ':  ...'; // CHANGED: prefixed with ':  ' to match the other rows
                        return _infoRow('Alergi', value);
                      },
                    ),

                    _infoRow(
                      'Riwayat Penyakit',
                      (baby.medicalHistory != null &&
                              baby.medicalHistory!.isNotEmpty)
                          ? ':  ${baby.medicalHistory!}'
                          : ':  Tidak Ada',
                    ),
                  ],
                ),
              ),
            ),

            // edit / delete footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _brand,
                        side: const BorderSide(color: _brand, width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // close detail dialog first
                        showDialog(
                          // CHANGED: showModalBottomSheet → showDialog, now that UpdateBabyForms is a Dialog itself
                          context: context,
                          barrierColor: Colors.black.withOpacity(
                            0.4,
                          ), // ADDED: matches the dim backdrop used elsewhere (NutritionCard's group dialog, etc.)
                          builder: (context) => UpdateBabyForms(
                            baby: baby,
                          ), // CHANGED: no more Padding/Container wrapper — UpdateBabyForms now builds its own Dialog+Container internally
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(
                          color: Colors.red.shade200,
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Apakah Anda Yakin?'),
                            content: Text('Hapus Data ${baby.firstName}?'),
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
                        if (confirm == true) {
                          onDelete();
                          if (context.mounted)
                            Navigator.pop(
                              context,
                            ); // close detail after deleting
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
