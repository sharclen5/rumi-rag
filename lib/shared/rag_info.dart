import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Reusable popup explaining what "With RAG" means.
// Styled to match NutritionCard/BabyDetail dialog conventions.
void showRagInfo(BuildContext context) {
  const brand = Color.fromARGB(255, 144, 121, 84);

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) => Dialog(
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
            // header, same layout language as NutritionCard/BabyDetail dialogs
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 12, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: brand,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Symbols.network_intel_node,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Apa itu RAG?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF363434),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8D5B7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF363434),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Divider(color: const Color(0xFFE8D5B7), height: 1),

            // scrollable body, in case text runs long on small screens
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'RAG (Retrieval-Augmented Generation) adalah teknologi yang membantu Rumi memberikan rekomendasi MPASI yang lebih akurat.',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: Color(0xFF363434),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Sebelum menjawab, sistem terlebih dahulu mencari referensi terpercaya seperti Buku KIA dan panduan WHO, lalu menyusun rekomendasi berdasarkan referensi tersebut, tidak hanya dari ingatan model AI saja.',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: Color(0xFF363434),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Ini membuat jawaban lebih relevan dan dapat dipertanggungjawabkan.',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: Color(0xFF363434),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
