import 'package:rumi/models/meal.dart';

class Recommendation {
  final String babyId;
  final String date;
  final List<Meal> meals;
  final DateTime createdAt;
  final String source;

  Recommendation({
    required this.babyId,
    required this.date,
    required this.meals,
    required this.createdAt,
    required this.source,
  });

  // convert respon API ke objek Recommendation
  factory Recommendation.fromJson(
    String babyId,
    String date,
    Map<String, dynamic> json,
  ) {
    return Recommendation(
      babyId: babyId,
      date: date,
      meals: (json['meals'] as List)
          .map((meal) => Meal.fromJson(meal))
          .toList(),
      createdAt: DateTime.now(),
      source: json['source'] ?? 'baseline',
    );
  }

  // convert Firestore document back to Recommendation object
  factory Recommendation.fromFirestore(Map<String, dynamic> data) {
    return Recommendation(
      babyId: data['baby_id'],
      date: data['date'],
      meals: (data['meals'] as List)
          .map((meal) => Meal.fromJson(meal))
          .toList(),
      createdAt: DateTime.parse(data['created_at']),
      source: data['source'] ?? 'baseline',
    );
  }

  // convert ke JSON buat nyimpen di Firestore
  Map<String, dynamic> toJson() {
    return {
      'baby_id': babyId,
      'date': date,
      'meals': meals.map((meal) => meal.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'source': source,
    };
  }
}
