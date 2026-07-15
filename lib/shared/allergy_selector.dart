import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllergySelector extends StatefulWidget {
  final List<String> initialSelectedIds;
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
  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const _border = Color(0xFFE8D5B7);

  Map<String, String> _allergies = {};
  late Set<String> _selectedIds;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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

  Future<void> _openPicker() async {
    final result = await showDialog<Set<String>>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => _AllergyPickerDialog(
        allergies: _allergies,
        initialSelectedIds: _selectedIds,
      ),
    );

    // null means the dialog was dismissed/cancelled — keep existing selection
    if (result != null) {
      setState(() => _selectedIds = result);
      widget.onChanged(_selectedIds.toList());
    }
  }

  void _removeChip(String id) {
    setState(() => _selectedIds.remove(id));
    widget.onChanged(_selectedIds.toList());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
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
        const SizedBox(height: 8.0),

        // selected chips — only shown if something's actually selected
        if (_selectedIds.isNotEmpty) ...[
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _selectedIds.map((id) {
              final name = _allergies[id] ?? '';
              return Chip(
                label: Text(name, style: const TextStyle(fontSize: 12)),
                backgroundColor: _brand.withOpacity(0.12),
                side: BorderSide(color: _brand.withOpacity(0.3)),
                deleteIcon: const Icon(Icons.close, size: 15),
                deleteIconColor: _brand,
                onDeleted: () => _removeChip(id),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
        ],

        // picker trigger
        InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: _openPicker,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(Icons.add_circle_outline, size: 18, color: _brand),
                const SizedBox(width: 8),
                Text(
                  _selectedIds.isEmpty ? 'Pilih Alergi' : 'Ubah Pilihan Alergi',
                  style: TextStyle(
                    fontSize: 13,
                    color: _brand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6), // ADDED
        Text(
          // ADDED: guides users to Riwayat Penyakit for anything not in the list
          'Bila alergi anak Anda tidak terdaftar, silahkan tambahkan pada bagian Riwayat Penyakit.',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

// picker dialog — separate stateful widget so selection can be confirmed/cancelled
// independently of the parent form's state
class _AllergyPickerDialog extends StatefulWidget {
  final Map<String, String> allergies;
  final Set<String> initialSelectedIds;

  const _AllergyPickerDialog({
    required this.allergies,
    required this.initialSelectedIds,
  });

  @override
  State<_AllergyPickerDialog> createState() => _AllergyPickerDialogState();
}

class _AllergyPickerDialogState extends State<_AllergyPickerDialog> {
  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const _border = Color(0xFFE8D5B7);
  static const _text = Color(0xFF363434);

  late Set<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = Set.from(
      widget.initialSelectedIds,
    ); // local copy — parent only updates on "Simpan"
  }

  void _toggle(String id) {
    setState(() {
      if (_tempSelected.contains(id)) {
        _tempSelected.remove(id);
      } else {
        _tempSelected.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFDF8F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pilih Alergi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _text,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(
                      context,
                    ), // cancel — no result passed, parent keeps old selection
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
            ),
            const SizedBox(height: 12),
            Divider(color: _border, height: 1),

            // scrollable options
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: widget.allergies.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Belum ada data alergi tersedia.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      )
                    : Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: widget.allergies.entries.map((entry) {
                          final isSelected = _tempSelected.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            selectedColor: _brand.withOpacity(0.15),
                            checkmarkColor: _brand,
                            side: BorderSide(
                              color: isSelected ? _brand : _border,
                            ),
                            onSelected: (_) => _toggle(entry.key),
                          );
                        }).toList(),
                      ),
              ),
            ),

            // footer
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
                  onPressed: () => Navigator.pop(
                    context,
                    _tempSelected,
                  ), // confirms — passes the local selection back
                  child: Text('Simpan (${_tempSelected.length} dipilih)'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
