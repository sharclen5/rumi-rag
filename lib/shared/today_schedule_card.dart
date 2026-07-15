import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/screens/home/recommendation/recommendation_detail.dart';
import 'package:rumi/shared/loading.dart';

class TodayScheduleCard extends StatefulWidget {
  final String uid;
  final String babyId;
  final Function(int) onTabTapped; // needed to jump to Rekomendasi tab
  final Recommendation? previewRecommendation;

  const TodayScheduleCard({
    super.key,
    required this.uid,
    required this.babyId,
    required this.onTabTapped,
    this.previewRecommendation,
  });

  @override
  State<TodayScheduleCard> createState() => _TodayScheduleCardState();
}

class _TodayScheduleCardState extends State<TodayScheduleCard> {
  Recommendation? _recommendation;
  bool _isLoading = true;
  String _dateStr = '';
  static const int _maxItemsShown = 3;

  @override
  void initState() {
    super.initState();
    if (widget.previewRecommendation != null) {
      _recommendation = widget.previewRecommendation;
      _isLoading = false;
    } else {
      _loadTodayRecommendation();
    }
  }

  Future<void> _loadTodayRecommendation() async {
    final now = DateTime.now();
    _dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    try {
      final result = await DatabaseService(
        uid: widget.uid,
      ).getRecommendation(widget.babyId, _dateStr);
      setState(() => _recommendation = result);
    } catch (_) {
      setState(() => _recommendation = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ADDED: optimistic toggle, called from the detail dialog (not from row taps directly)
  Future<void> _handleToggleEaten(int mealIndex, bool newValue) async {
    final current = _recommendation;
    if (current == null) return;

    final previousMeal = current.meals[mealIndex];

    setState(() {
      current.meals[mealIndex] = previousMeal.copyWith(isEaten: newValue);
    });

    try {
      await DatabaseService(
        uid: widget.uid,
      ).toggleMealEaten(widget.babyId, _dateStr, mealIndex);
    } catch (e) {
      if (mounted) {
        setState(() => current.meals[mealIndex] = previousMeal);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui status: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 160,
        child: Loading(), // CHANGED: was CircularProgressIndicato
      );
    }

    if (_recommendation == null || _recommendation!.meals.isEmpty) {
      return _emptyCard();
    }

    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header row
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  size: 18,
                  color: Color.fromARGB(255, 144, 121, 84),
                ),
                SizedBox(width: 8),
                const Text(
                  'Jadwal MPASI Hari Ini',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF363434),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const SizedBox(height: 12),

            // CHANGED: sliding 3-item window centered on the first unmarked meal
            Builder(
              builder: (context) {
                final meals = _recommendation!.meals;
                final total = meals.length;
                const windowSize = _maxItemsShown;

                final highlightIndex = meals.indexWhere((m) => !m.isEaten);

                int windowStart;
                if (total <= windowSize) {
                  windowStart = 0;
                } else if (highlightIndex == -1) {
                  // all meals done — show the last window
                  windowStart = total - windowSize;
                } else {
                  windowStart = (highlightIndex - 1).clamp(
                    0,
                    total - windowSize,
                  );
                }

                final windowEnd = (windowStart + windowSize).clamp(0, total);
                final shownIndices = List.generate(
                  windowEnd - windowStart,
                  (i) => windowStart + i,
                );

                return Column(
                  children: shownIndices.asMap().entries.map((entry) {
                    final localIndex = entry.key;
                    final absoluteIndex = entry.value;
                    final meal = meals[absoluteIndex];

                    return _ScheduleRow(
                      meal: meal,
                      isNext: absoluteIndex == highlightIndex,
                      isLast: localIndex == shownIndices.length - 1,
                      onTap: widget.previewRecommendation != null
                          ? () {}
                          : () {
                              showDialog(
                                context: context,
                                builder: (_) => RecommendationDetailDialog(
                                  meal: meal,
                                  isEaten: meal.isEaten,
                                  onToggleEaten: (newValue) =>
                                      _handleToggleEaten(
                                        absoluteIndex,
                                        newValue,
                                      ), // CHANGED: uses absolute index now
                                ),
                              );
                            },
                    );
                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 8), // ADDED
            // ADDED: "Lihat Jadwal" moved here, below the last meal row, full-width and tappable
            GestureDetector(
              onTap: () => widget.onTabTapped(1),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE8D5B7),
                    width: 1.2,
                  ),
                ),
                child: const Text(
                  'Lihat Jadwal Lengkap →',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 144, 121, 84),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Card(
      color: const Color(0xFFFDF8F2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8D5B7), width: 1.5),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 56,
                height: 56,
                color: const Color.fromARGB(255, 122, 105, 95),
                child: const Icon(
                  Icons.no_meals,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum ada rencana hari ini',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF363434),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Buat rencana menu MPASI melalui menu Buat Rencana',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      height: 1.4,
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

// ADDED: single timeline row — status icon + connecting line, card, checkbox indicator
class _ScheduleRow extends StatelessWidget {
  final Meal meal;
  final bool isNext;
  final bool isLast;
  final VoidCallback onTap;

  const _ScheduleRow({
    required this.meal,
    required this.isNext,
    required this.isLast,
    required this.onTap,
  });

  static const _accentColor = Color.fromARGB(255, 144, 121, 84);

  @override
  Widget build(BuildContext context) {
    final isAsi = meal.type == 'ASI';
    final label = isAsi ? 'Air Susu Ibu' : (meal.name ?? '');
    final isDone = meal.isEaten;
    final IconData mealIcon = isAsi
        ? Icons.water_drop
        : meal.type.toLowerCase() == 'snack'
        ? Icons.cookie
        : Icons.restaurant;

    return Opacity(
      opacity: isDone ? 0.5 : 1.0,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // status icon + connecting line
            Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: meal.isEaten
                        ? _accentColor
                        : (isNext ? _accentColor : Colors.grey.shade200),
                  ),
                  child: Icon(
                    meal.isEaten
                        ? Icons.check
                        : mealIcon, // CHANGED: uses mealIcon
                    size: 16,
                    color: meal.isEaten || isNext
                        ? Colors.white
                        : Colors.grey.shade400,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 1.5, color: Colors.grey.shade300),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          isNext // ADDED
                          ? Border.all(color: _accentColor, width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF363434),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pukul ${meal.time}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // checkbox is visual only — tapping anywhere opens the detail dialog
                        Icon(
                          meal.isEaten
                              ? Icons.check_box_rounded
                              : Icons.check_box_outline_blank_rounded,
                          color: (meal.isEaten || isNext)
                              ? _accentColor
                              : Colors.grey.shade300,
                          size: 22,
                        ),
                      ],
                    ),
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
