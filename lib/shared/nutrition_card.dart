import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Versi B: framing "X dari 5 Bintang", sesuai istilah klinis dari wawancara
// (menu 4 bintang / 5 bintang = kelengkapan kelompok gizi dalam satu hari)

class NutritionCard extends StatelessWidget {
  final String uid;
  final String babyId;
  final Set<String>? previewCoveredGroups;
  final String babyName;
  static const _brand = Color.fromARGB(255, 144, 121, 84);

  const NutritionCard({
    super.key,
    required this.uid,
    required this.babyId,
    required this.babyName,
    this.previewCoveredGroups,
  });

  static const _coreGroups = {
    'karbohidrat': '🍚 Karbohidrat',
    'protein_hewani': '🥩 Protein Hewani',
    'protein_nabati': '🫘 Protein Nabati',
    'sayuran': '🥦 Sayuran',
    'buah': '🥑 Buah',
  };

  String _todayDocId() {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return '${babyId}_$dateStr';
  }

  Map<String, List<MapEntry<String, bool>>> _mealsByGroup(
    Map<String, dynamic> data,
  ) {
    final meals = (data['meals'] as List?) ?? [];
    final result = <String, List<MapEntry<String, bool>>>{};
    for (final meal in meals) {
      if (meal is! Map) continue;
      if (meal['type'] == 'ASI') continue;
      final fg = meal['foodGroup'];
      final mealName =
          meal['name'] as String? ?? meal['type'] as String? ?? 'Menu';
      final isEaten = meal['isEaten'] == true;
      if (fg is List) {
        for (final g in fg) {
          if (g is String) {
            result.putIfAbsent(g, () => []).add(MapEntry(mealName, isEaten));
          }
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (previewCoveredGroups != null) {
      final preview = {
        for (final g in previewCoveredGroups!)
          g: <MapEntry<String, bool>>[MapEntry('Contoh Menu', true)],
      };
      return _buildCard(context: context, mealsByGroup: preview, hasData: true);
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('recommendations')
          .doc(_todayDocId())
          .snapshots(),
      builder: (context, snapshot) {
        final hasData = snapshot.hasData && snapshot.data!.exists;
        final mealsByGroup = hasData
            ? _mealsByGroup(snapshot.data!.data() as Map<String, dynamic>)
            : <
                String,
                List<MapEntry<String, bool>>
              >{}; // FIXED: was <String, List<String>>{} — wrong type for the empty fallback
        return _buildCard(
          context: context,
          mealsByGroup: mealsByGroup,
          hasData: hasData,
        );
      },
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required Map<String, List<MapEntry<String, bool>>>
    mealsByGroup, // FIXED: was Map<String, List<String>>
    required bool hasData,
  }) {
    final covered = mealsByGroup.entries
        .where((e) => e.value.any((meal) => meal.value))
        .map((e) => e.key)
        .toSet();
    final starCount = _coreGroups.keys.where(covered.contains).length;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDF8F2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _brand.withOpacity(0.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: Color.fromARGB(255, 144, 121, 84),
                ),
                const SizedBox(width: 8),
                Text(
                  'Kelengkapan Gizi $babyName Hari Ini',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF363434),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const SizedBox(height: 10),
            if (!hasData)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Belum ada rencana menu untuk hari ini.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
                ),
              )
            else ...[
              Row(
                children: List.generate(_coreGroups.length, (i) {
                  final filled = i < starCount;
                  return Expanded(
                    child: Container(
                      height: 8,
                      margin: EdgeInsets.only(
                        right: i == _coreGroups.length - 1 ? 0 : 6,
                      ),
                      decoration: BoxDecoration(
                        color: filled ? _brand : _brand.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                '$starCount dari ${_coreGroups.length} kelompok gizi terpenuhi hari ini',
                style: const TextStyle(fontSize: 13, color: Color(0xFF363434)),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _coreGroups.entries.map((entry) {
                  final isCovered = covered.contains(entry.key);

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showGroupDetail(
                        context,
                        entry.value,
                        isCovered,
                        mealsByGroup[entry.key] ?? [],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isCovered ? _brand : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isCovered
                                ? _brand
                                : _brand.withOpacity(0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isCovered) ...[
                              const Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              entry.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCovered
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isCovered
                                    ? Colors.white
                                    : _brand.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showGroupDetail(
    BuildContext context,
    String groupLabel,
    bool isCovered,
    List<MapEntry<String, bool>> meals,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFDF8F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8D5B7), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      groupLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF363434),
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
              const SizedBox(height: 12),
              Divider(color: const Color(0xFFE8D5B7), height: 1),
              const SizedBox(height: 12),
              if (meals.isNotEmpty)
                ...meals.map((meal) {
                  final name = meal.key;
                  final isEaten = meal.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Icon(
                          isEaten
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          size: 18,
                          color: isEaten ? _brand : Colors.grey.shade400,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              color: isEaten
                                  ? const Color(0xFF363434)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
              else
                Text(
                  'Belum ada menu yang mengandung $groupLabel hari ini.',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
