import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

// ADDED: thrown when today's plan already exists, so the UI can
// distinguish this from a real network/API failure and show a
// lightweight message instead of an error dialog.
class PlanAlreadyExistsException implements Exception {
  final String message;
  PlanAlreadyExistsException([
    this.message =
        'Rencana MPASI untuk hari ini sudah tersedia. Silahkan coba di lain hari',
  ]);

  @override
  String toString() => message;
}

class RecommendationService {
  static const String _baseUrl =
      'https://rumi-rag.fastapicloud.dev'; //tes deploy

  Future<void> getWeeklyRecommendation({
    // return type changed
    required String uid,
    required String babyId,
    required int ageInMonths,
    required int correctedAgeInMonths,
    required double weight,
    required double height,
    required String gender,
    required bool isPremature,
    required bool isActivelyBreastfed,
    int? toothCount,
    required List<String> allergies,
    String? medicalHistory,
    required String startDate,
    required int days,
    List<String> previousMeals = const [],
  }) async {
    final todayDocId = '${babyId}_$startDate';
    final todayDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recommendations')
        .doc(todayDocId)
        .get();

    if (todayDoc.exists) {
      throw PlanAlreadyExistsException();
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/recommend/weekly'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'uid': uid,
        'baby_id': babyId,
        'baby': {
          'age_in_months': ageInMonths,
          'corrected_age_in_months': correctedAgeInMonths,
          'weight': weight,
          'height': height,
          'gender': gender,
          'is_premature': isPremature,
          'is_actively_breastfed': isActivelyBreastfed,
          'tooth_count': toothCount,
          'allergies': allergies,
          'medical_history': medicalHistory,
        },
        'start_date': startDate,
        'days': days,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get recommendation: ${response.statusCode}');
    }
  }
}
