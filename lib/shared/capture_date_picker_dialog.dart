import 'package:flutter/material.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/recommendation_date_grouping.dart';
import 'package:rumi/shared/meal_preview_dialog.dart';

enum _PickerView { yearMonths, monthDates }

class CaptureDatePickerDialog extends StatefulWidget {
  final String uid;
  final String babyId;
  final String source;

  const CaptureDatePickerDialog({
    super.key,
    required this.uid,
    required this.babyId,
    required this.source,
  });

  @override
  State<CaptureDatePickerDialog> createState() =>
      _CaptureDatePickerDialogState();
}

class _CaptureDatePickerDialogState extends State<CaptureDatePickerDialog> {
  static const _cardBg = Color(0xFF2A2828);
  static const _cardBorder = Color(0xFF4A4646);
  static const _ink = Color(0xFFF2DAB1);
  static const _pageSize = 6; // jumlah tanggal per halaman di View B

  _PickerView _currentView = _PickerView.yearMonths;
  int _selectedYear = DateTime.now().year; // dikoreksi sekali pas data datang
  int? _selectedMonth;
  int _currentPage = 0;

  bool _yearInitialized = false;
  Map<int, Map<int, List<Recommendation>>> _lastGrouped = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder, width: 1.5),
        ),
        child: StreamBuilder<List<Recommendation>>(
          stream: DatabaseService(
            uid: widget.uid,
          ).getRecommendationHistory(widget.babyId, widget.source),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memuat riwayat: ${snapshot.error}',
                  style: const TextStyle(color: _ink),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final grouped = groupRecommendationsByYearMonth(snapshot.data!);
            _lastGrouped =
                grouped; // biar bisa dipakai _showYearDropdown di luar builder ini

            if (!_yearInitialized) {
              _selectedYear = latestYearIn(
                grouped,
                fallback: DateTime.now().year,
              );
              _yearInitialized = true;
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(),
                const Divider(height: 1, color: _cardBorder),
                Flexible(
                  child: _currentView == _PickerView.yearMonths
                      ? _buildYearMonths(grouped)
                      : _buildMonthDates(grouped),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pilih Tanggal',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pilih tanggal rencana makan yang ingin disimpan sebagai gambar',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 8),
                _buildHeaderToggle(),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _cardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.close, size: 18, color: _ink),
            ),
          ),
        ],
      ),
    );
  }

  // tombol "[ 2026 ]" / "[ April, 2026 ]" — di View B tap = balik ke View A,
  // di View A tap = buka dropdown tahun
  Widget _buildHeaderToggle() {
    final label = _currentView == _PickerView.yearMonths
        ? '$_selectedYear'
        : '${_monthName(_selectedMonth!)}, $_selectedYear';

    return GestureDetector(
      onTap: () {
        if (_currentView == _PickerView.monthDates) {
          setState(() {
            _currentView = _PickerView.yearMonths;
            _selectedMonth = null;
            _currentPage = 0;
          });
        } else {
          _showYearDropdown();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: _cardBorder),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(color: _ink, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Future<void> _showYearDropdown() async {
    final years = _lastGrouped.keys.toList()..sort((a, b) => b.compareTo(a));
    if (years.isEmpty)
      years.add(_selectedYear); // tetep ada 1 opsi walau belum ada data

    final picked = await showDialog<int>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => Dialog(
        backgroundColor: _cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _cardBorder),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: years.map((y) {
              return ListTile(
                title: Text('$y', style: const TextStyle(color: _ink)),
                onTap: () => Navigator.pop(context, y),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (picked != null) setState(() => _selectedYear = picked);
  }

  // View A — grid 12 bulan, abu-abu + catatan kalo bulan itu ga ada rekomendasi
  Widget _buildYearMonths(Map<int, Map<int, List<Recommendation>>> grouped) {
    final monthsWithData = grouped[_selectedYear]?.keys.toSet() ?? {};

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        final month = index + 1;
        final hasData = monthsWithData.contains(month);

        return GestureDetector(
          onTap: hasData
              ? () => setState(() {
                  _currentView = _PickerView.monthDates;
                  _selectedMonth = month;
                  _currentPage = 0;
                })
              : null, // bulan kosong = ga bisa di-tap
          child: Container(
            decoration: BoxDecoration(
              color: hasData
                  ? _cardBorder.withOpacity(0.5)
                  : _cardBorder.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasData ? _cardBorder : _cardBorder.withOpacity(0.3),
              ),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _monthName(month),
                  style: TextStyle(
                    color: hasData ? _ink : _ink.withOpacity(0.35),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (!hasData) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Tidak ada rencana makan',
                    style: TextStyle(color: _ink.withOpacity(0.3), fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // View B — list tanggal yang ada rekomendasi di bulan terpilih, + pagination
  Widget _buildMonthDates(Map<int, Map<int, List<Recommendation>>> grouped) {
    final recs = grouped[_selectedYear]?[_selectedMonth] ?? [];

    if (recs.isEmpty) {
      // harusnya ga kejadian karena bulan kosong udah di-disable di View A,
      // tapi dijagain buat edge case
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Tidak ada rencana makan di bulan ini',
          style: TextStyle(color: _ink),
        ),
      );
    }

    final totalPages = (recs.length / _pageSize).ceil();
    final start = _currentPage * _pageSize;
    final end = (start + _pageSize).clamp(0, recs.length);
    final pageItems = recs.sublist(start, end);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: pageItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final rec = pageItems[i];
              return GestureDetector(
                onTap: () {
                  Navigator.pop(
                    context,
                  ); // tutup picker dulu sebelum buka preview
                  showDialog(
                    context: context,
                    builder: (_) => MealPreviewDialog(recommendation: rec),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _cardBorder.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _formatDateLabel(rec.date),
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: _ink),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left, color: _ink),
                  onPressed: _currentPage > 0
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text(
                  '${_currentPage + 1} / $totalPages',
                  style: const TextStyle(color: _ink),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right, color: _ink),
                  onPressed: _currentPage < totalPages - 1
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDateLabel(String isoDate) {
    final day = int.tryParse(isoDate.split('-')[2]) ?? 0;
    return '$day ${_monthName(_selectedMonth!)} $_selectedYear';
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }
}
