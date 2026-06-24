import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllergySelector extends StatefulWidget {
  //  ID alergi buat mode edit
  final List<String> initialSelectedIds;
  // callback ke parent form setiap kali pilihan berubah
  final void Function(List<String> selectedIds) onChanged;

  const AllergySelector({
    super.key,
    this.initialSelectedIds = const [],
    required this.onChanged,
  });

  @override
  State<AllergySelector> createState() => _AllergySelectorState();
}

class _AllergySelectorState extends State<AllergySelector> {
  // nyimpen pasangan id -> nama alergi dari Firestore
  Map<String, String> _allergies = {};
  // nyimpen ID yang sedang dipilih user
  late Set<String> _selectedIds;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // set initial selection dari parent (buat mode edit)
    _selectedIds = Set.from(widget.initialSelectedIds);
    _fetchAllergies();
  }

  Future<void> _fetchAllergies() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('baby_allergies')
        .get();

    final map = <String, String>{};
    for (final doc in snapshot.docs) {
      map[doc.id] = doc.data()['name'] ?? '';
    }

    setState(() {
      _allergies = map;
      _isLoading = false;
    });
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    // kirim perubahan ke parent form
    widget.onChanged(_selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alergi (Opsional)',
          style: TextStyle(fontSize: 14.0, color: Colors.grey[700]),
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _allergies.entries.map((entry) {
            final isSelected = _selectedIds.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              selectedColor: Color(0xFF71DEFF).withValues(alpha: 0.4),
              checkmarkColor: Colors.black87,
              onSelected: (_) => _toggle(entry.key),
            );
          }).toList(),
        ),
      ],
    );
  }
}
