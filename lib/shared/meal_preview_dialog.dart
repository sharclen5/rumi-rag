import 'dart:ui' as ui; //  buat convert RenderRepaintBoundary ke gambar
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart'; // package buat nyimpen gambar ke galeri
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';

/// Compact preview of a day's meal plan (time, type, name only).
/// Important: this widget's content IS what gets captured once the
/// "save as image" logic is built next phase — not throwaway preview UI.
class MealPreviewDialog extends StatefulWidget {
  final Recommendation recommendation;
  const MealPreviewDialog({super.key, required this.recommendation});

  @override
  State<MealPreviewDialog> createState() => _MealPreviewDialogState();
}

class _MealPreviewDialogState extends State<MealPreviewDialog> {
  // GlobalKey ini yang nanti nunjuk ke RepaintBoundary buat di-capture
  final GlobalKey _captureKey = GlobalKey();
  bool _isSaving = false; // status lagi proses simpen gambar atau nggak

  static const _cardBg = Color(0xFF2A2828);
  static const _cardBorder = Color(0xFF4A4646);
  static const _ink = Color(0xFFF2DAB1);
  static const _brand = Color.fromARGB(255, 144, 121, 84);

  // BARU: fungsi yang jalanin capture + simpen ke galeri
  Future<void> _captureAndSave() async {
    if (_isSaving) return; // jaga-jaga biar ga ke-tap dobel pas lagi proses

    setState(() => _isSaving = true);

    try {
      // ambil RenderRepaintBoundary dari widget yang nempel di _captureKey
      final boundary =
          _captureKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;

      // render jadi gambar, pixelRatio 3 biar hasilnya tajem (bukan buram
      // pas di-zoom di galeri)
      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes); // simpen ke galeri device

      if (!mounted) return; // guard, siapa tau widget udah ke-dispose duluan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar berhasil disimpan ke galeri')),
      );
    } on GalException catch (e) {
      // error spesifik dari package gal (izin ditolak, storage penuh, dll)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.type.message}')),
      );
    } catch (e) {
      // fallback buat error lain yang ga ketangkep GalException
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan, coba lagi')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // urutin by time, pola yang sama kayak di EditScheduleDialog
    final sortedMeals = [
      ...widget.recommendation.meals,
    ]..sort((a, b) => _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time)));

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pratinjau ${widget.recommendation.date}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _ink,
                      ),
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
            ),
            const Divider(height: 1, color: _cardBorder),

            // bagian ini yang jadi target capture — Column-nya dibungkus
            // RepaintBoundary, BUKAN SingleChildScrollView-nya, soalnya
            // scroll view cuma render yang keliatan di layar doang
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: RepaintBoundary(
                  key:
                      _captureKey, // nempelin key buat dipanggil nanti pas capture
                  child: Container(
                    color:
                        _cardBg, // BARU: biar background gelap ikut ke-capture, soalnya RepaintBoundary sendiri ga ngegambar background apa-apa
                    child: Column(
                      children: sortedMeals
                          .map(
                            (meal) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CompactMealRow(meal: meal),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brand,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: _isSaving
                      ? null
                      : _captureAndSave, // UBAH: panggil capture beneran, disable pas lagi proses
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan sebagai Gambar',
                        ), // tombol balik ke teks biasa kalo ga lagi nyimpen
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactMealRow extends StatelessWidget {
  final Meal meal;
  const _CompactMealRow({required this.meal});

  static const _ink = Color(0xFFF2DAB1);
  static const _cardBorder = Color(0xFF4A4646);
  static const _brand = Color.fromARGB(255, 144, 121, 84);

  @override
  Widget build(BuildContext context) {
    final label = meal.type == 'ASI' ? 'Air Susu Ibu' : (meal.name ?? '');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _cardBorder.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            meal.time,
            style: const TextStyle(
              color: _brand,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _ink, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            meal.type,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// sama kayak di edit_schedule.dart, buat sorting meal by waktu
int _timeToMinutes(String time) {
  final parts = time.split('.');
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return hour * 60 + minute;
}
