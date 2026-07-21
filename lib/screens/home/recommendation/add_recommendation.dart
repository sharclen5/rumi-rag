import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/services/recommendation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rumi/shared/loading.dart';

class AddRecommendation extends StatefulWidget {
  const AddRecommendation({super.key});

  @override
  State<AddRecommendation> createState() => _AddRecommendationState();
}

class _AddRecommendationState extends State<AddRecommendation> {
  final _formKey = GlobalKey<FormState>();

  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const _border = Color(0xFFE8D5B7);
  static const _text = Color(0xFF363434);
  static const _bg = Color(0xFFFDF8F2);

  Baby? _selectedBaby;
  String _currentNotes = '';
  Map<String, String> _allergyMap = {};
  bool _allergyMapLoaded = false;
  bool _isLoading = false;
  Stream<QuerySnapshot>? _progressStream;
  int _totalDays = 7;

  // only '1 Minggu' is actually usable right now
  String _selectedDuration = '1 Minggu';
  final List<Map<String, dynamic>> _durationOptions = const [
    {'label': '1 Minggu', 'days': 7, 'available': true},
    {'label': '2 Minggu', 'days': 14, 'available': false},
    {'label': '1 Bulan', 'days': 30, 'available': false},
  ];

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _loadAllergyMap() async {
    if (_allergyMapLoaded) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('baby_allergies')
        .get();
    final map = <String, String>{};
    for (final doc in snapshot.docs) {
      map[doc.id] = doc.data()['name'] ?? '';
    }
    if (!mounted) return;
    setState(() {
      _allergyMap = map;
      _allergyMapLoaded = true;
    });
  }

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

  Future<void> _submit(String uid) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final baby = _selectedBaby!;
      final now = DateTime.now();
      final startDate = _formatDate(now);

      final allergyNames = baby.allergyIds
          .map((id) => _allergyMap[id] ?? id)
          .toList();

      final days = switch (_selectedDuration) {
        '1 Minggu' => 7,
        '2 Minggu' => 14,
        '1 Bulan' => 30,
        _ => 7,
      };

      // ADDED: kept as a defensive fallback — UI already prevents picking
      // an unavailable duration, but this guards against future chip
      // options being marked available without the backend supporting it yet.
      if (days != 7) {
        if (mounted) {
          _showRestrictedDialog();
        }
        setState(() => _isLoading = false);
        return;
      }

      _totalDays = days;
      final expectedDocsIds = List.generate(
        days,
        (i) => '${baby.id}_${_formatDate(now.add(Duration(days: i)))}',
      );
      _progressStream = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recommendations')
          .where(FieldPath.documentId, whereIn: expectedDocsIds)
          .snapshots();

      await RecommendationService().getWeeklyRecommendation(
        uid: uid,
        babyId: baby.id,
        ageInMonths: baby.ageInMonths,
        correctedAgeInMonths: baby.correctedAgeInMonths,
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

      if (mounted) Navigator.pop(context);
    } on PlanAlreadyExistsException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Gagal Membuat Rencana'),
            content: Text('$e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _progressStream = null;
        });
      }
    }
  }

  void _showRestrictedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durasi Terbatas'),
        content: const Text(
          'Untuk versi ini, Anda hanya bisa membuat rencana dengan durasi 1 Minggu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final babies = Provider.of<List<Baby>?>(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 420,
        ),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: _isLoading ? _buildProgressView() : _buildFormView(user, babies),
      ),
    );
  }

  // ---------------- idle / form state ----------------

  Widget _buildFormView(User? user, List<Baby>? babies) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Divider(color: _border, height: 1),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<Baby>(
                    value: _selectedBaby,
                    hint: const Text('Pilih Bayi'),
                    decoration: _fieldDecoration('Bayi'),
                    dropdownColor: _bg,
                    style: const TextStyle(color: _text, fontSize: 14),
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

                  if (_selectedBaby != null) ...[
                    const SizedBox(height: 14),
                    _buildBabyInfoCard(_selectedBaby!),
                    const SizedBox(height: 14),

                    TextFormField(
                      decoration: _fieldDecoration(
                        'Catatan Kesehatan Khusus',
                        hint: 'Opsional',
                      ),
                      maxLines: 3,
                      onChanged: (val) => setState(() => _currentNotes = val),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Durasi Rencana',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDurationChips(),
                  ],
                ],
              ),
            ),
          ),
        ),
        _buildFooter(user),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _brand.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.restaurant_menu, color: _brand, size: 20),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Buat Rencana Menu MPASI',
              style: TextStyle(
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
              child: const Icon(Icons.close, size: 18, color: _text),
            ),
          ),
        ],
      ),
    );
  }

  // ADDED: read-only summary instead of a wall of disabled TextFormFields —
  // this is a confirmation step, not an edit step, so it should look like one.
  Widget _buildBabyInfoCard(Baby baby) {
    final ageLabel = baby.isPremature
        ? '${baby.correctedAgeInMonths} bulan (usia koreksi)'
        : '${baby.ageInMonths} bulan';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                baby.gender == 'Male' ? Icons.male : Icons.female,
                size: 16,
                color: _brand,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  baby.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _text,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _infoRow(Icons.cake_outlined, ageLabel),
              _infoRow(Icons.monitor_weight_outlined, '${baby.weight} kg'),
              _infoRow(Icons.height, '${baby.height} cm'),
              _infoRow(
                Icons.child_care,
                baby.isActivelyBreastfed ? 'Masih ASI' : 'Tidak ASI',
              ),
              if (baby.toothCount != null)
                _infoRow(
                  Icons.sentiment_satisfied_alt,
                  '${baby.toothCount} gigi',
                ),
            ],
          ),
          if (baby.medicalHistory != null &&
              baby.medicalHistory!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _infoRow(
              Icons.medical_information_outlined,
              baby.medicalHistory!,
              wrapText: true,
            ),
          ],
          if (baby.allergyIds.isNotEmpty) ...[
            const SizedBox(height: 10),
            !_allergyMapLoaded
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: baby.allergyIds.map((id) {
                      return Chip(
                        label: Text(
                          _allergyMap[id] ?? id,
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: Colors.amber.shade50,
                        side: BorderSide(color: Colors.amber.shade200),
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        avatar: const Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: Colors.orange,
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {bool wrapText = false}) {
    return SizedBox(
      width: wrapText ? double.infinity : null,
      child: Row(
        mainAxisSize: wrapText ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, color: _text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _durationOptions.map((opt) {
        final label = opt['label'] as String;
        final available = opt['available'] as bool;
        final isSelected = _selectedDuration == label;

        return GestureDetector(
          onTap: !available
              ? () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Durasi ini akan hadir di update berikutnya'),
                  ),
                )
              : () => setState(() => _selectedDuration = label),
          child: Opacity(
            opacity: available ? 1.0 : 0.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? _brand.withOpacity(0.12) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _brand : _border,
                  width: isSelected ? 1.6 : 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isSelected ? _brand : _text,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (!available) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Segera Hadir',
                        style: TextStyle(fontSize: 9, color: Colors.black54),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter(User? user) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          onPressed: () => _submit(user?.uid ?? ''),
          child: const Text('Buat Rencana'),
        ),
      ),
    );
  }

  // ---------------- generating state ----------------

  Widget _buildProgressView() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: StreamBuilder(
        stream: _progressStream,
        builder: (context, snapshot) {
          final daysWritten = snapshot.data?.docs.length ?? 0;
          final currentDay = (daysWritten + 1).clamp(1, _totalDays);
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _brand.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome, color: _brand),
              ),
              const SizedBox(height: 16),
              const Text(
                'Membuat Rencana Menu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Hari ke-$currentDay dari $_totalDays',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              Loading(progress: daysWritten / _totalDays, message: ''),
            ],
          );
        },
      ),
    );
  }
}
