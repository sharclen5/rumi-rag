import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';

// =====================
// CHANGED: StatelessWidget -> StatefulWidget, added isEaten + onToggleEaten
// =====================
class RecommendationDetailDialog extends StatefulWidget {
  final Meal meal;
  final bool isEaten; // ADDED
  final String date; // ADDED
  final ValueChanged<bool> onToggleEaten; // ADDED

  const RecommendationDetailDialog({
    super.key,
    required this.meal,
    required this.isEaten, // ADDED
    required this.date, // ADDED
    required this.onToggleEaten, // ADDED
  });

  @override
  State<RecommendationDetailDialog> createState() =>
      _RecommendationDetailDialogState();
}

class _RecommendationDetailDialogState
    extends State<RecommendationDetailDialog> {
  late bool _isEaten = widget.isEaten;

  // ADDED: helper yang sama kayak di file-file laen, gabungin tanggal + jam
  // meal jadi DateTime beneran
  DateTime _mealDateTime(String date, String time) {
    final dateParts = date.split('-').map(int.parse).toList();
    final timeParts = time.split('.').map(int.parse).toList();
    return DateTime(
      dateParts[0],
      dateParts[1],
      dateParts[2],
      timeParts[0],
      timeParts.length > 1 ? timeParts[1] : 0,
    );
  }

  // ADDED: getter, dihitung ulang tiap dipanggil pake widget.date + widget.meal.time
  bool get _isFuture =>
      _mealDateTime(widget.date, widget.meal.time).isAfter(DateTime.now());

  void _handleToggle() {
    // ADDED: kalau meal-nya masih di masa depan, jangan lanjut toggle,
    if (_isFuture) {
      _showFutureMealPopup();
      return;
    }

    setState(() => _isEaten = !_isEaten);
    widget.onToggleEaten(
      _isEaten,
    ); // triggers parent's backend write + snackbar
  }

  // ADDED: pop-up peringatan, desainnya niru dialog "Registrasi Berhasil"
  // di halaman login, cuma ganti ikon & teks jadi versi warning
  void _showFutureMealPopup() {
    const brand = Color.fromARGB(255, 144, 121, 84);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2828), // CHANGED: was Color(0xFFFDF8F2)
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4A4646),
              width: 1.5,
            ), // CHANGED: was Color(0xFFE8D5B7)
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: brand,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons
                        .schedule_rounded, // beda sama ikon check di popup registrasi
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Belum Waktunya',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: Color(0xFFF2DAB1), // CHANGED: was Color(0xFF363434)
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Menu ini belum bisa ditandai karena\njadwalnya belum tiba.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.5,
                    fontFamily: 'Poppins',
                    color: Color(0xFFF2DAB1), // CHANGED: was Color(0xFF363434)
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          color: const Color(0xFF2A2828), // CHANGED: was Color(0xFFFDF8F2)
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4A4646),
            width: 1.5,
          ), // CHANGED: was Color(0xFFE8D5B7)
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
                      child: Icon(mealIcon, color: Colors.white, size: 24),
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
                            color: Color(
                              0xFFF2DAB1,
                            ), // CHANGED: was Color(0xFF363434)
                          ),
                        ),
                        Text(
                          'Pukul ${meal.time}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors
                                .grey
                                .shade400, // CHANGED: was grey.shade500, lebih terang di bg gelap
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
                        color: const Color(
                          0xFF4A4646,
                        ), // CHANGED: was Color(0xFFE8D5B7)
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(
                          0xFFF2DAB1,
                        ), // CHANGED: was Color(0xFF363434)
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
                      ? const Color.fromARGB(255, 144, 121, 84).withOpacity(
                          0.2,
                        ) // CHANGED: was 0.1, dinaikkan biar keliatan di bg gelap
                      : const Color(0xFF2A2828), // CHANGED: was Colors.white
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(
                      0xFF4A4646,
                    ), // CHANGED: was Color(0xFFE8D5B7)
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
                            : Colors
                                  .grey
                                  .shade400, // CHANGED: was grey.shade600, lebih terang di bg gelap
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // END CHANGE
            Divider(
              color: const Color(0xFF4A4646),
              height: 1,
            ), // CHANGED: was Color(0xFFE8D5B7)
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(
                                            0xFFF2DAB1,
                                          ), // CHANGED: default text jadi cream
                                        ),
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
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(
                                            0xFFF2DAB1,
                                          ), // CHANGED: default text jadi cream
                                        ),
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
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(
                              0xFFF2DAB1,
                            ), // CHANGED: default text jadi cream
                          ),
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
        color: Color(0xFFF2DAB1), // CHANGED: was Color(0xFF363434)
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
        color: const Color(0xFF2A2828), // CHANGED: was Colors.white
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4A4646),
          width: 1.5,
        ), // CHANGED: was Color(0xFFE8D5B7)
      ),
      child: child,
    );
  }
}
