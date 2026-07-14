import 'package:flutter/material.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/screens/home/recommendation/recommendation_detail.dart';

class MealCard extends StatefulWidget {
  final String uid;
  final String babyId;
  const MealCard({super.key, required this.uid, required this.babyId});

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  final PageController _controller = PageController(viewportFraction: 0.95);
  Recommendation? _recommendation;
  bool _isLoading = true;
  String? _dateStr;

  @override
  void initState() {
    super.initState();
    _loadTodayRecommendation();
  }

  Future<void> _loadTodayRecommendation() async {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _dateStr = dateStr;

    try {
      final result = await DatabaseService(
        uid: widget.uid,
      ).getRecommendation(widget.babyId, dateStr);
      setState(() => _recommendation = result);
    } catch (_) {
      setState(() => _recommendation = null);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(
            color: Color.fromARGB(255, 144, 121, 84),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_recommendation == null || _recommendation!.meals.isEmpty) {
      return _emptyCard();
    }

    return SizedBox(
      height: 180,
      child: PageView(
        controller: _controller,
        children: _recommendation!.meals
            .asMap()
            .entries
            .map(
              (entry) => _MealCardItem(
                key: ValueKey(entry.key),
                meal: entry.value,
                uid: widget.uid,
                babyId: widget.babyId,
                date: _dateStr!,
                mealIndex: entry.key,
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _emptyCard() {
    return SizedBox(
      height: 180,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4),
        color: Color(0xFFFDF8F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Color(0xFFE8D5B7), width: 1.5),
        ),
        elevation: 2,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color.fromARGB(255, 122, 105, 95),
                  child: Icon(Icons.no_meals, color: Colors.white, size: 28),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum ada rencana hari ini',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF363434),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Buat rencana menu MPASI melalui menu Buat Rencana',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCardItem extends StatefulWidget {
  final Meal meal;
  final String uid;
  final String babyId;
  final String date;
  final int mealIndex;

  const _MealCardItem({
    super.key,
    required this.meal,
    required this.uid,
    required this.babyId,
    required this.date,
    required this.mealIndex,
  });

  @override
  State<_MealCardItem> createState() => _MealCardItemState();
}

class _MealCardItemState extends State<_MealCardItem> {
  late bool _isEaten = widget.meal.isEaten;
  bool _isToggling = false;

  Future<void> _handleToggle() async {
    if (_isToggling) return;
    final newValue = !_isEaten;

    setState(() {
      _isEaten = newValue;
      _isToggling = true;
    });

    try {
      await DatabaseService(
        uid: widget.uid,
      ).toggleMealEaten(widget.babyId, widget.date, widget.mealIndex);

      if (newValue && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ditandai selesai'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      // revert optimistic update if the Firestore write fails
      if (mounted) setState(() => _isEaten = !newValue);
    } finally {
      if (mounted) setState(() => _isToggling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.meal;
    final isAsi = meal.type == 'ASI';
    final IconData mealIcon = isAsi
        ? Icons.water_drop
        : meal.type.toLowerCase() == 'snack'
        ? Icons.cookie
        : Icons.restaurant;

    return AnimatedOpacity(
      opacity: _isEaten ? 0.5 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => RecommendationDetailDialog(
              meal: meal,
              isEaten: _isEaten,
              onToggleEaten: (_) => _handleToggle(), // CHANGED
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 4),
          color: Color(0xFFFDF8F2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Color(0xFFE8D5B7), width: 1.5),
          ),
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 144, 121, 84),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              meal.type,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Pukul ${meal.time}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            isAsi ? 'Air Susu Ibu' : meal.name ?? '',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF363434),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 64,
                        height: 64,
                        color: const Color.fromARGB(255, 122, 105, 95),
                        child: Icon(
                          mealIcon,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Divider(color: Color(0xFFE8D5B7)),
                Spacer(),
                // ADDED: toggle affordance + existing "Lihat detail" in one row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _handleToggle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isEaten
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: _isEaten
                                ? Color.fromARGB(255, 144, 121, 84)
                                : Colors.grey.shade400,
                            size: 20,
                          ),
                          SizedBox(width: 4),
                          Text(
                            _isEaten ? 'Selesai' : 'Tandai selesai',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isEaten
                                  ? Color.fromARGB(255, 144, 121, 84)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Lihat detail →',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color.fromARGB(255, 144, 121, 84),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
