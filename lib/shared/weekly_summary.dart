import 'package:flutter/material.dart';
import 'package:rumi/services/database.dart';

/// Popup showing the AI-generated weekly summary + nutrition status for a
/// given week. Mirrors EditScheduleDialog's style (dark card, rounded
/// corners, close button).
class WeeklySummary extends StatelessWidget {
  final String weeklySummary;
  final String? nutritionStatus;
  final String dateRangeLabel;

  const WeeklySummary({
    super.key,
    required this.weeklySummary,
    this.nutritionStatus,
    required this.dateRangeLabel,
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
          color: const Color(0xFF2A2828),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4A4646), width: 1.5),
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
                          'Ringkasan Mingguan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFF2DAB1),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateRangeLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // tombol close, sama persis gayanya kayak di EditScheduleDialog
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A4646),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Color(0xFFF2DAB1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFF4A4646)),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // chip status gizi, cuma muncul kalo datanya ada
                    if (nutritionStatus != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 144, 121, 84),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          nutritionStatus!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      weeklySummary,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFFF2DAB1),
                      ),
                    ),
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

// ADDED: fetch + show flow — ambil dokumen weeklySummaries dari Firestore,
// lalu tampilin popup kalo ada datanya, atau snackbar kalo belum ada/gagal.
// Pola try/catch + snackbar-nya sama kayak handleEditSchedule.
Future<void> handleShowWeeklySummary({
  required BuildContext context,
  required String uid,
  required String babyId,
  required String startDate,
  required String dateRangeLabel,
}) async {
  Map<String, dynamic>? data;
  try {
    data = await DatabaseService(
      uid: uid,
    ).getWeeklySummary(babyId, startDate, 'rag');
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil ringkasan mingguan: $e')),
      );
    }
    return;
  }

  if (data == null || data['weekly_summary'] == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ringkasan mingguan belum tersedia untuk minggu ini'),
        ),
      );
    }
    return;
  }

  if (!context.mounted) return;
  await showDialog(
    context: context,
    builder: (_) => WeeklySummary(
      weeklySummary: data!['weekly_summary'] as String,
      nutritionStatus: data['nutrition_status'] as String?,
      dateRangeLabel: dateRangeLabel,
    ),
  );
}
