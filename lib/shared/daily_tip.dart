import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/services/daily_tip_service.dart';

class DailyTip extends StatefulWidget {
  final Baby baby;
  final String parentGender;
  const DailyTip({super.key, required this.baby, required this.parentGender});

  @override
  State<DailyTip> createState() => _DailyTipState();
}

class _DailyTipState extends State<DailyTip> {
  final DailyTipService _service = DailyTipService();

  String? _tip;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadTip();
  }

  // ADDED: kalo user ganti activeBaby (misal switch dari card di HomeHero),
  // widget ini di-reuse tapi baby-nya beda, jadi perlu reload tip yang sesuai
  @override
  void didUpdateWidget(covariant DailyTip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baby.id != widget.baby.id) {
      _loadTip();
    }
  }

  String get _todayKey => 'daily_tip_date_${widget.baby.id}';
  String get _tipKey => 'daily_tip_${widget.baby.id}';

  Future<void> _loadTip() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split(
        'T',
      )[0]; // format YYYY-MM-DD
      final cachedDate = prefs.getString(_todayKey);
      final cachedTip = prefs.getString(_tipKey);

      // kalo cache masih buat hari ini, langsung pake, ga usah panggil API lagi
      if (cachedDate == today && cachedTip != null) {
        setState(() {
          _tip = cachedTip;
          _isLoading = false;
        });
        return;
      }

      // cache basi atau belum ada, generate baru
      final newTip = await _service.getDailyTip(
        babyName: widget.baby.firstName,
        ageInMonths: widget.baby.correctedAgeInMonths,
        weight: widget.baby.weight,
        height: widget.baby.height,
        isActivelyBreastfed: widget.baby.isActivelyBreastfed,
        toothCount: widget.baby.toothCount,
        allergies: widget
            .baby
            .allergyIds, // sementara masih ID, belum di-resolve ke nama
        medicalHistory: widget.baby.medicalHistory,
        parentGender: widget.parentGender,
      );

      await prefs.setString(_tipKey, newTip);
      await prefs.setString(_todayKey, today);

      setState(() {
        _tip = newTip;
        _isLoading = false;
      });
    } catch (e) {
      // TEMPORARY: biar keliatan error aslinya di console, hapus lagi kalo udah ketemu masalahnya
      print('[DailyTip] Error: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFDF8F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8D5B7), width: 1.5),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                SizedBox(width: 6),
                Text(
                  '🤎 Pesan dari Rumi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF363434),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      // loading state simpel, ga usah spinkit biar ga ganggu layout card
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: SizedBox(
          height: 14,
          width: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_hasError) {
      // fallback message + tombol retry, sesuai yang diminta
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tips harian belum tersedia saat ini.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF363434),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _loadTip,
            child: const Text(
              'Coba lagi',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF8B5E34),
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _tip ?? '',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF363434),
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '— Rumi AI',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}
