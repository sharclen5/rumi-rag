import 'dart:convert';
import 'package:http/http.dart' as http;

class DailyTipService {
  static const String _baseUrl =
      'https://rumi-rag.fastapicloud.dev'; // sesuaikan base url per app (rumi vs rumi-rag)

  Future<String> getDailyTip({
    required String babyName,
    required int ageInMonths,
    required double weight,
    required double height,
    required bool isActivelyBreastfed,
    int? toothCount,
    required List<String> allergies,
    String? medicalHistory,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/daily-tip'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'baby': {
          'baby_name': babyName,
          'age_in_months': ageInMonths,
          'weight': weight,
          'height': height,
          'is_actively_breastfed': isActivelyBreastfed,
          'tooth_count': toothCount,
          'allergies': allergies,
          'medical_history': medicalHistory,
        },
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to get daily tip: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    return data['tip'] as String;
  }
}