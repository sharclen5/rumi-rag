import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/screens/home/admin/edit_user.dart';
import 'package:rumi/services/database.dart';
import 'package:provider/provider.dart';

class UserDetail extends StatelessWidget {
  final UserProfile user;
  const UserDetail({super.key, required this.user});

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
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFF2DAB1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<User?>(context, listen: false);

    final isMale =
        user.gender.toLowerCase() == 'male' ||
        user.gender.toLowerCase() == 'laki-laki';
    final avatarColor = user.gender.isEmpty
        ? Colors.grey.shade600
        : isMale
        ? const Color.fromARGB(255, 140, 202, 253)
        : const Color.fromARGB(255, 255, 146, 182);

    final initials = [
      user.firstName,
      user.lastName,
    ].where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).join();

    final genderLabel = user.gender.isEmpty
        ? '-'
        : isMale
        ? 'Laki-laki'
        : 'Perempuan';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2828),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4A4646), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: avatarColor,
                    child: Text(
                      initials.isEmpty ? '?' : initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                          '${user.firstName} ${user.lastName}'.trim(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF2DAB1),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: user.role == 'admin'
                                ? _brand.withOpacity(0.2)
                                : Colors.grey.shade800,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: user.role == 'admin'
                                  ? _brand
                                  : Colors.grey.shade600,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            user.role == 'admin' ? 'Admin' : 'User',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: user.role == 'admin'
                                  ? const Color(0xFFF2DAB1)
                                  : Colors.grey.shade400,
                            ),
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
                        color: const Color(0xFF4A4646),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFF2DAB1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: const Color(0xFF4A4646), height: 1),

            // scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow('Email', ':  ${user.email}'),
                    _infoRow(
                      'No. Telepon',
                      ':  ${user.phone.isEmpty ? '-' : user.phone}',
                    ),
                    _infoRow('Jenis Kelamin', ':  $genderLabel'),
                    _infoRow('UID', ':  ${user.uid}'),

                    const SizedBox(height: 16),
                    Divider(color: const Color(0xFF4A4646), height: 1),
                    const SizedBox(height: 12),

                    const Text(
                      'Data Bayi & Rekomendasi',
                      style: TextStyle(
                        color: Color(0xFFF2DAB1),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    FutureBuilder<List<Baby>>(
                      future: DatabaseService(
                        uid: currentUser!.uid,
                      ).getBabiesForUser(user.uid),
                      builder: (context, babySnapshot) {
                        if (babySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(
                                color: _brand,
                                strokeWidth: 2,
                              ),
                            ),
                          );
                        }

                        final babies = babySnapshot.data ?? [];

                        if (babies.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Belum ada data bayi.',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: babies
                              .map(
                                (baby) => _BabyCard(
                                  baby: baby,
                                  targetUid: user.uid,
                                  adminUid: currentUser.uid,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // footer — edit & delete
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD4A96A),
                        side: const BorderSide(
                          color: Color(0xFFD4A96A),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withOpacity(0.4),
                          builder: (_) => EditUser(
                            targetUser: user,
                            adminUid: currentUser.uid,
                          ),
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
                          builder: (_) => AlertDialog(
                            backgroundColor: const Color(0xFF2A2828),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(
                                color: Color(0xFF4A4646),
                                width: 1.5,
                              ),
                            ),
                            title: const Text(
                              'Hapus Pengguna?',
                              style: TextStyle(color: Color(0xFFF2DAB1)),
                            ),
                            content: Text(
                              'Semua data ${user.firstName} termasuk bayi dan rekomendasi akan dihapus permanen.',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
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
                        if (confirm == true && context.mounted) {
                          await DatabaseService(
                            uid: currentUser.uid,
                          ).deleteUserData(user.uid);
                          if (context.mounted) Navigator.pop(context);
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

// ─── _BabyCard ───────────────────────────────────────────────────────────────
// tappable card mirip BabyTile — buka _BabyDetailDialog pas di-tap
class _BabyCard extends StatelessWidget {
  final Baby baby;
  final String targetUid;
  final String adminUid;

  const _BabyCard({
    required this.baby,
    required this.targetUid,
    required this.adminUid,
  });

  @override
  Widget build(BuildContext context) {
    final isMale = baby.gender.toLowerCase() == 'male';
    final avatarColor = isMale
        ? const Color.fromARGB(255, 140, 202, 253)
        : const Color.fromARGB(255, 255, 146, 182);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.4),
            builder: (_) => _BabyDetailDialog(
              baby: baby,
              targetUid: targetUid,
              adminUid: adminUid,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2828),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4A4646), width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: avatarColor,
                  child: Text(
                    baby.firstName.isNotEmpty
                        ? baby.firstName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
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
                          color: Color(0xFFF2DAB1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${baby.ageInMonths} bulan · ${baby.weight} kg',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── _BabyDetailDialog ───────────────────────────────────────────────────────
// nampilin full detail bayi (mirip BabyDetail) + tombol lihat rekomendasi di bawah
class _BabyDetailDialog extends StatelessWidget {
  final Baby baby;
  final String targetUid;
  final String adminUid;

  const _BabyDetailDialog({
    required this.baby,
    required this.targetUid,
    required this.adminUid,
  });

  static const _brand = Color.fromARGB(255, 144, 121, 84);

  // sama persis kayak BabyDetail._infoRow
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
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFF2DAB1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // resolve allergyIds → nama, sama kayak BabyDetail
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
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2828),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4A4646), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header — sama kayak BabyDetail
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
                            color: Color(0xFFF2DAB1),
                          ),
                        ),
                        Text(
                          '${baby.ageInMonths} bulan',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
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
                        color: const Color(0xFF4A4646),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFF2DAB1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: const Color(0xFF4A4646), height: 1),

            // scrollable info — field sama persis kayak BabyDetail
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
                      isMale ? ':  Laki-laki' : ':  Perempuan',
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
                            : ':  ...';
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

            Divider(color: const Color(0xFF4A4646), height: 1),

            // tappable row buka _RecListDialog
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                onTap: () => showDialog(
                  context: context,
                  barrierColor: Colors.black.withOpacity(0.4),
                  builder: (_) => _RecListDialog(
                    baby: baby,
                    targetUid: targetUid,
                    adminUid: adminUid,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Lihat Rekomendasi',
                          style: TextStyle(
                            color: Color(0xFFF2DAB1),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey.shade500,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _RecListDialog ───────────────────────────────────────────────────────────
// popup rekomendasi paginasi — dibuka dari _BabyDetailDialog
class _RecListDialog extends StatefulWidget {
  final Baby baby;
  final String targetUid;
  final String adminUid;

  const _RecListDialog({
    required this.baby,
    required this.targetUid,
    required this.adminUid,
  });

  @override
  State<_RecListDialog> createState() => _RecListDialogState();
}

class _RecListDialogState extends State<_RecListDialog> {
  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const int _perPage = 3;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final isMale = widget.baby.gender.toLowerCase() == 'male';
    final avatarColor = isMale
        ? const Color.fromARGB(255, 140, 202, 253)
        : const Color.fromARGB(255, 255, 146, 182);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2828),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4A4646), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header bayi ringkas
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: avatarColor,
                    child: Text(
                      widget.baby.firstName.isNotEmpty
                          ? widget.baby.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
                          widget.baby.fullName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF2DAB1),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Rekomendasi MPASI',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
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
                        color: const Color(0xFF4A4646),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFF2DAB1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: const Color(0xFF4A4646), height: 1),

            // stream rekomendasi + paginasi
            Flexible(
              child: StreamBuilder<List<Recommendation>>(
                stream: DatabaseService(
                  uid: widget.adminUid,
                ).getRecommendationsForBaby(widget.targetUid, widget.baby.id),
                builder: (context, recSnapshot) {
                  if (recSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: _brand,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  final recs = recSnapshot.data ?? [];

                  if (recs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'Belum ada rekomendasi.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  }

                  final totalPages = (recs.length / _perPage).ceil();
                  final safePage = _currentPage.clamp(0, totalPages - 1);
                  final start = safePage * _perPage;
                  final end = (start + _perPage).clamp(0, recs.length);
                  final pageRecs = recs.sublist(start, end);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // label + total count
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: Row(
                          children: [
                            const Text(
                              'Rekomendasi',
                              style: TextStyle(
                                color: Color(0xFFF2DAB1),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${recs.length} total',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // list rec halaman ini
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: pageRecs.length,
                          itemBuilder: (_, i) => _RecTile(rec: pageRecs[i]),
                        ),
                      ),

                      // pagination controls
                      if (totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: safePage > 0
                                    ? () => setState(
                                        () => _currentPage = safePage - 1,
                                      )
                                    : null,
                                icon: const Icon(Icons.chevron_left),
                                color: const Color(0xFFF2DAB1),
                                disabledColor: Colors.grey.shade700,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF363434),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF4A4646),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '${safePage + 1} / $totalPages',
                                  style: const TextStyle(
                                    color: Color(0xFFF2DAB1),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: safePage < totalPages - 1
                                    ? () => setState(
                                        () => _currentPage = safePage + 1,
                                      )
                                    : null,
                                icon: const Icon(Icons.chevron_right),
                                color: const Color(0xFFF2DAB1),
                                disabledColor: Colors.grey.shade700,
                              ),
                            ],
                          ),
                        ),
                      if (totalPages <= 1) const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _RecTile ─────────────────────────────────────────────────────────────────
// tile satu entri rekomendasi
class _RecTile extends StatelessWidget {
  final Recommendation rec;
  const _RecTile({required this.rec});

  @override
  Widget build(BuildContext context) {
    final sourceLabel = rec.source == 'rag' ? 'RAG' : 'Baseline';
    final sourceBadgeColor = rec.source == 'rag'
        ? const Color.fromARGB(255, 100, 160, 100)
        : Colors.blueGrey;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF363434),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A4646), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                rec.date,
                style: const TextStyle(
                  color: Color(0xFFF2DAB1),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: sourceBadgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: sourceBadgeColor, width: 1),
                ),
                child: Text(
                  sourceLabel,
                  style: TextStyle(
                    color: sourceBadgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ...rec.meals.map(
            (meal) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${meal.type}  ',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                  ),
                  Expanded(
                    child: Text(
                      meal.name ?? '-',
                      style: const TextStyle(
                        color: Color(0xFFF2DAB1),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
