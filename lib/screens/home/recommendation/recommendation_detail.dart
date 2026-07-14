import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';

// =====================
// CHANGED: StatelessWidget -> StatefulWidget, added isEaten + onToggleEaten
// =====================
class RecommendationDetailDialog extends StatefulWidget {
  final Meal meal;
  final bool isEaten; // ADDED
  final ValueChanged<bool> onToggleEaten; // ADDED

  const RecommendationDetailDialog({
    super.key,
    required this.meal,
    required this.isEaten, // ADDED
    required this.onToggleEaten, // ADDED
  });

  @override
  State<RecommendationDetailDialog> createState() =>
      _RecommendationDetailDialogState();
}

class _RecommendationDetailDialogState
    extends State<RecommendationDetailDialog> {
  late bool _isEaten = widget.isEaten;

  void _handleToggle() {
    setState(() => _isEaten = !_isEaten);
    widget.onToggleEaten(
      _isEaten,
    ); // triggers parent's backend write + snackbar
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final isAsi = meal.type == 'ASI';
    final IconData mealIcon = isAsi
        ? Icons.water_drop
        : meal.type.toLowerCase() == 'snack'
        ? Icons.cookie
        : Icons.restaurant;

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
            // header row with close button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // meal icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 48,
                      height: 48,
                      color: const Color.fromARGB(255, 122, 105, 95),
                      child: Icon(
                        mealIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // name + type badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 144, 121, 84),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            meal.type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isAsi ? 'Air Susu Ibu' : meal.name ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363434),
                          ),
                        ),
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
                  // close button
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

            // =====================
            // ADDED: toggle row, same visual language as MealCard's inline toggle
            // =====================
            GestureDetector(
              onTap: _handleToggle,
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _isEaten
                      ? const Color.fromARGB(255, 144, 121, 84).withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE8D5B7),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isEaten
                          ? Icons.check_circle
                          : Icons.check_circle_outline,
                      color: _isEaten
                          ? const Color.fromARGB(255, 144, 121, 84)
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isEaten ? 'Sudah dimakan' : 'Tandai sudah dimakan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _isEaten
                            ? const Color.fromARGB(255, 144, 121, 84)
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // END CHANGE
            Divider(color: const Color(0xFFE8D5B7), height: 1),

            // scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isAsi) ...[
                      // ingredients
                      if (meal.ingredients != null &&
                          meal.ingredients!.isNotEmpty) ...[
                        _SectionHeader(title: 'Bahan-bahan'),
                        const SizedBox(height: 8),
                        _DetailCard(
                          child: Column(
                            children: meal.ingredients!.map((ingredient) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(
                                          255,
                                          144,
                                          121,
                                          84,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        ingredient,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // steps
                      if (meal.steps != null && meal.steps!.isNotEmpty) ...[
                        _SectionHeader(title: 'Cara Membuat'),
                        const SizedBox(height: 8),
                        _DetailCard(
                          child: Column(
                            children: meal.steps!.asMap().entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(
                                          255,
                                          144,
                                          121,
                                          84,
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.key + 1}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        entry.value,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],

                    // reason — shown for all including ASI
                    if (meal.reason != null && meal.reason!.isNotEmpty) ...[
                      _SectionHeader(title: 'Alasan Rekomendasi'),
                      const SizedBox(height: 8),
                      _DetailCard(
                        child: Text(
                          meal.reason!,
                          style: const TextStyle(fontSize: 14, height: 1.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF363434),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final Widget child;
  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8D5B7), width: 1.5),
      ),
      child: child,
    );
  }
}
