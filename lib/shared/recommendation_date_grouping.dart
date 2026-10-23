import 'package:rumi/models/recommendation.dart';

/// Groups a flat list of [Recommendation] by year and month, keyed off
/// each recommendation's `date` field (format: "YYYY-MM-DD").
/// Used by the capture/share date picker dialog to know which months/years
/// have data, without needing a dedicated Firestore query.
Map<int, Map<int, List<Recommendation>>> groupRecommendationsByYearMonth(
  List<Recommendation> recommendations,
) {
  final grouped = <int, Map<int, List<Recommendation>>>{};

  for (final rec in recommendations) {
    // date formatnya "YYYY-MM-DD", jadi tinggal split by "-"
    final parts = rec.date.split('-');
    if (parts.length < 2) continue; // skip kalo formatnya aneh, daripada crash

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    if (year == null || month == null) continue;

    grouped.putIfAbsent(year, () => {});
    grouped[year]!.putIfAbsent(month, () => []);
    grouped[year]![month]!.add(rec);
  }

  // urutin tiap bulan ascending by date, biar View B nanti tinggal pakai langsung
  for (final yearMap in grouped.values) {
    for (final monthList in yearMap.values) {
      monthList.sort((a, b) => a.date.compareTo(b.date));
    }
  }

  return grouped;
}

/// Returns the most recent year present in [grouped], or [fallback] if empty.
/// Used to set the picker's initial selected year when it first opens.
int latestYearIn(
  Map<int, Map<int, List<Recommendation>>> grouped, {
  required int fallback,
}) {
  if (grouped.isEmpty) return fallback; // belum ada rekomendasi sama sekali
  return grouped.keys.reduce((a, b) => a > b ? a : b);
}