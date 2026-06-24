import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rumi/models/recommendation.dart';

class RecommendationService {
  // static const String _baseUrl = 'http://localhost:8000';
  // static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String _baseUrl = 'http://192.168.100.9:8000'; // physical device

  Future<Recommendation> getRecommendation({
    // return type changed
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
    required String date,
    List<String> previousMeals = const [],
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/recommend'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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
        'date': date,
        'previous_meals': previousMeals,
      }),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Recommendation.fromJson(babyId, date, json);
    } else {
      throw Exception('Failed to get recommendation: ${response.statusCode}');
    }
  }
}
