import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';

/// Compact preview of a day's meal plan (time, type, name only).
/// Important: this widget's content IS what gets captured once the
/// "save as image" logic is built next phase — not throwaway preview UI.
class MealPreviewDialog extends StatelessWidget {
  final Recommendation recommendation;
  const MealPreviewDialog({super.key, required this.recommendation});

  static const _cardBg = Color(0xFF2A2828);
  static const _cardBorder = Color(0xFF4A4646);
  static const _ink = Color(0xFFF2DAB1);
  static const _brand = Color.fromARGB(255, 144, 121, 84);

  @override
  Widget build(BuildContext context) {
    // urutin by time, pola yang sama kayak di EditScheduleDialog
    final sortedMeals = [...recommendation.meals]
      ..sort(
        (a, b) => _timeToMinutes(a.time).compareTo(_timeToMinutes(b.time)),
      );

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
                      'Pratinjau ${recommendation.date}',
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

            // bagian ini yang NANTINYA jadi target RepaintBoundary pas fitur
            // capture beneran dibangun
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                  // belum ada logic capture/save beneran — nyusul fase berikutnya
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Fitur simpan gambar belum aktif'),
                      ),
                    );
                  },
                  child: const Text('Simpan sebagai Gambar'),
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
          Text(meal.type, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
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