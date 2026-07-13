import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/services/database.dart';

/// Popup for choosing which meal in a day's schedule to edit.
/// Returns the selected meal's index via Navigator.pop(context, index).
/// Extracted from recommendation_page.dart to keep that file shorter.
class EditScheduleDialog extends StatelessWidget {
  final List<Meal> meals;
  final String dateLabel;

  const EditScheduleDialog({
    super.key,
    required this.meals,
    required this.dateLabel,
  });

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
          border: Border.all(color: const Color(0xFFE8D5B7), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih jadwal yang ingin diubah',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF363434),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
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
            const Divider(height: 1, color: Color(0xFFE8D5B7)),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: (() {
                    final indexedMeals =
                        List.generate(
                          meals.length,
                          (i) => MapEntry(i, meals[i]),
                        )..sort(
                          (a, b) => _timeToMinutes(
                            a.value.time,
                          ).compareTo(_timeToMinutes(b.value.time)),
                        );

                    return indexedMeals.map((entry) {
                      final originalIndex = entry.key;
                      final meal = entry.value;
                      return InkWell(
                        onTap: () => Navigator.pop(context, originalIndex),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 42,
                                  height: 42,
                                  color: const Color.fromARGB(
                                    255,
                                    122,
                                    105,
                                    95,
                                  ),
                                  child: Icon(
                                    meal.type == 'ASI'
                                        ? Icons.water_drop
                                        : Icons.lunch_dining,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.schedule,
                                          size: 14,
                                          color: Color.fromARGB(
                                            255,
                                            144,
                                            121,
                                            84,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          meal.time,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Color.fromARGB(
                                              255,
                                              144,
                                              121,
                                              84,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      meal.name ?? 'Air Susu Ibu',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF363434),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      meal.type,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Color.fromARGB(255, 144, 121, 84),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList();
                  })(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ADDED: full edit-schedule flow — meal picker, time picker, save/revert.
// Moved out of recommendation_page.dart to keep that file shorter.
// The caller (recommendation_page) only needs to supply data + a callback
// to apply the updated meal to its local state.
Future<void> handleEditSchedule({
  required BuildContext context,
  required List<Meal> meals,
  required String dateLabel,
  required String uid,
  required String babyId,
  required String dateStr,
  required void Function(int mealIndex, Meal updatedMeal) onMealTimeChanged,
}) async {
  final selectedMealIndex = await showDialog<int>(
    context: context,
    builder: (_) => EditScheduleDialog(meals: meals, dateLabel: dateLabel),
  );

  if (selectedMealIndex == null) return;

  final selectedMeal = meals[selectedMealIndex];
  final timeParts = selectedMeal.time.split('.'); // format is "HH.mm"
  final initialTime = TimeOfDay(
    hour: int.tryParse(timeParts[0]) ?? 0,
    minute: timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0,
  );

  if (!context.mounted) return;
  final pickedTime = await showTimePicker(
    context: context,
    initialTime: initialTime,
  );

  if (pickedTime == null) return;

  final newTimeStr =
      '${pickedTime.hour.toString().padLeft(2, '0')}.${pickedTime.minute.toString().padLeft(2, '0')}';
  final previousTime = selectedMeal.time;

  // optimistic update, same pattern as _handleToggleEaten in recommendation_page
  onMealTimeChanged(selectedMealIndex, selectedMeal.copyWith(time: newTimeStr));

  try {
    await DatabaseService(
      uid: uid,
    ).updateMealTime(babyId, dateStr, selectedMealIndex, newTimeStr);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil diperbarui')),
      );
    }
  } catch (e) {
    // revert on failure
    onMealTimeChanged(
      selectedMealIndex,
      selectedMeal.copyWith(time: previousTime),
    );
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memperbarui jadwal: $e')));
    }
  }
}

// ADDED: parses "HH.mm" into total minutes, for sorting meals by time
int _timeToMinutes(String time) {
  final parts = time.split('.');
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return hour * 60 + minute;
}
