import 'dart:convert';
import 'package:http/http.dart' as http;

class RecommendationService {
  static const String _baseUrl = 'http://localhost:8000'; //web
  // static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  // static const String _baseUrl = 'http://192.168.100.9:8000'; // physical device

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
