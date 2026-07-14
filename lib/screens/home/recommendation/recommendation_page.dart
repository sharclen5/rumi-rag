import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/shared/loading.dart';
import 'package:rumi/screens/home/recommendation/add_recommendation.dart';
import 'package:rumi/screens/home/recommendation/recommendation_detail.dart';
import 'package:rumi/screens/home/recommendation/edit_schedule.dart';

class RecommendationPage extends StatelessWidget {
  final Function(int) onTabTapped;
  const RecommendationPage({super.key, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamProvider<List<Baby>>.value(
      value: DatabaseService(uid: user!.uid).babies,
      initialData: const [],
      child: _RecommendationView(uid: user.uid, onTabTapped: onTabTapped),
    );
  }
}

class _RecommendationView extends StatefulWidget {
  final String uid;
  final Function(int) onTabTapped;
  const _RecommendationView({required this.uid, required this.onTabTapped});

  @override
  State<_RecommendationView> createState() => _RecommendationViewState();
}

class _RecommendationViewState extends State<_RecommendationView> {
  Recommendation? _recommendation;
  bool _isLoading = false;
  String? _error;
  Baby? _lastFetchedBaby;

  DateTime _selectedDate = DateTime.now();

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _monthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

  String get _selectedDateStr =>
      '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

  Future<void> _fetchRecommendation(Baby baby) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await DatabaseService(
        uid: widget.uid,
      ).getRecommendation(baby.id, _selectedDateStr);

      setState(() => _recommendation = result);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // CHANGED: uses mealIndex + toggleMealEaten (matches DatabaseService),
  // and updates local state immutably via copyWith since Meal is final.
  Future<void> _handleToggleEaten(int mealIndex, bool newValue) async {
    if (_lastFetchedBaby == null || _recommendation == null) return;

    final previousMeal = _recommendation!.meals[mealIndex];

    // optimistic local update
    setState(() {
      _recommendation!.meals[mealIndex] = previousMeal.copyWith(
        isEaten: newValue,
      );
    });

    try {
      await DatabaseService(
        uid: widget.uid,
      ).toggleMealEaten(_lastFetchedBaby!.id, _selectedDateStr, mealIndex);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue ? 'Ditandai sudah dimakan' : 'Ditandai belum dimakan',
            ),
          ),
        );
      }
    } catch (e) {
      // revert on failure
      if (mounted) {
        setState(() {
          _recommendation!.meals[mealIndex] = previousMeal;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memperbarui status: $e')));
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final babies = context.watch<List<Baby>>();
    final activeBaby = babies.cast<Baby?>().firstWhere(
      (b) => b!.isActive,
      orElse: () => null,
    );

    if (activeBaby != null && activeBaby.id != _lastFetchedBaby?.id) {
      _lastFetchedBaby = activeBaby;
      _fetchRecommendation(activeBaby);
    }
  }

  // =====================
  // CHANGED: AppBar collapsed to match Home (toolbarHeight: 0), title +
  // baby dropdown + edit-schedule icon moved into the body as a header
  // block, same pattern as HomeHero. Dropdown/hint colors switched from
  // white-on-tan to dark-on-cream since the header now sits on the light
  // gradient background instead of the solid tan AppBar.
  // =====================
  @override
  Widget build(BuildContext context) {
    final babies = context.watch<List<Baby>>();
    final activeBaby = babies.isEmpty
        ? null
        : babies.cast<Baby?>().firstWhere(
            (b) => b!.isActive,
            orElse: () => null,
          );

    return StreamBuilder<UserProfile?>(
      stream: DatabaseService(uid: widget.uid).userProfile,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: 0,
            elevation: 0,
            backgroundColor: const Color(0xFFF2DAB1),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5EBD9), Color(0xFFFFFFFF)],
                stops: [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jadwal MPASI',
                                style: TextStyle(
                                  color: Color(0xFF363434),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              babies.isEmpty
                                  ? Row(
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          color: Colors.grey.shade400,
                                          size: 10,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Belum ada profil bayi yang aktif',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    )
                                  : DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        isDense: true,
                                        value: activeBaby?.id,
                                        dropdownColor: const Color(0xFFF5EBD9),
                                        iconEnabledColor: const Color(
                                          0xFF363434,
                                        ),
                                        style: const TextStyle(
                                          color: Color(0xFF363434),
                                          fontSize: 13,
                                        ),
                                        hint: Row(
                                          children: [
                                            Icon(
                                              Icons.circle,
                                              color: Colors.grey.shade400,
                                              size: 10,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'Belum ada profil bayi yang aktif',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        selectedItemBuilder: (context) {
                                          return babies.map((baby) {
                                            return Row(
                                              children: [
                                                const Icon(
                                                  Icons.circle,
                                                  color: Colors.greenAccent,
                                                  size: 10,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Profil aktif: ${baby.fullName} · ${baby.ageInMonths} bulan',
                                                  style: const TextStyle(
                                                    color: Color(0xFF363434),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            );
                                          }).toList();
                                        },
                                        items: babies.map((baby) {
                                          return DropdownMenuItem<String>(
                                            value: baby.id,
                                            child: Text(
                                              '${baby.fullName} · ${baby.ageInMonths} bulan',
                                              style: const TextStyle(
                                                color: Color(0xFF363434),
                                                fontSize: 13,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (selectedId) {
                                          if (selectedId != null) {
                                            DatabaseService(
                                              uid: widget.uid,
                                            ).setActiveBaby(selectedId);
                                          }
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (_recommendation == null ||
                                _lastFetchedBaby == null)
                              return;

                            await handleEditSchedule(
                              context: context,
                              meals: _recommendation!.meals,
                              dateLabel:
                                  '${_selectedDate.day} ${_monthName(_selectedDate.month)}, ${_dayName(_selectedDate.weekday)}',
                              uid: widget.uid,
                              babyId: _lastFetchedBaby!.id,
                              dateStr: _selectedDateStr,
                              onMealTimeChanged: (index, updatedMeal) {
                                setState(() {
                                  _recommendation!.meals[index] = updatedMeal;
                                });
                              },
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: const Color.fromARGB(255, 122, 105, 95),
                              child: const Icon(
                                Icons.edit_document,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activeBaby != null)
                          CalendarStrip(
                            selectedDate: _selectedDate,
                            onDateSelected: (date) {
                              setState(() {
                                _selectedDate = date;
                                _recommendation = null;
                              });
                              if (_lastFetchedBaby != null) {
                                _fetchRecommendation(_lastFetchedBaby!);
                              }
                            },
                            uid: widget.uid,
                            babyId: activeBaby.id,
                            showCard: true,
                            showArrows: true,
                          ),
                        const SizedBox(height: 12),
                        Text(
                          '${_selectedDate.day} ${_monthName(_selectedDate.month)}, ${_dayName(_selectedDate.weekday)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF363434),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  Expanded(
                    child: _isLoading
                        ? Loading()
                        : _error != null
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Gagal memuat rekomendasi',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_lastFetchedBaby != null) {
                                        _fetchRecommendation(_lastFetchedBaby!);
                                      }
                                    },
                                    child: const Text('Coba Lagi'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _recommendation == null
                        ? Center(
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.no_meals,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Belum ada rencana untuk hari ini',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                        255,
                                        144,
                                        121,
                                        84,
                                      ),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (outerContext) => Padding(
                                          padding: EdgeInsets.only(
                                            top: 20,
                                            left: 20,
                                            right: 20,
                                            bottom:
                                                MediaQuery.of(
                                                  context,
                                                ).viewInsets.bottom +
                                                20,
                                          ),
                                          child: Provider<List<Baby>?>.value(
                                            value: Provider.of<List<Baby>?>(
                                              context,
                                              listen: false,
                                            ),
                                            child: const AddRecommendation(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Buat Rekomendasi'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                            child: Column(
                              children: (() {
                                final Map<int, int> hourToIndex = {};
                                for (
                                  var i = 0;
                                  i < _recommendation!.meals.length;
                                  i++
                                ) {
                                  final meal = _recommendation!.meals[i];
                                  final hour =
                                      int.tryParse(meal.time.split('.')[0]) ??
                                      0;
                                  hourToIndex[hour] = i;
                                }
                                return List.generate(24, (hour) {
                                  final mealIndex = hourToIndex[hour];
                                  final meal = mealIndex != null
                                      ? _recommendation!.meals[mealIndex]
                                      : null;
                                  final timeLabel =
                                      '${hour.toString().padLeft(2, '0')}.00';
                                  return _TimeLineRow(
                                    timeLabel: timeLabel,
                                    hasSlot: meal != null,
                                    meal: meal,
                                    mealIndex: mealIndex,
                                    onToggleEaten: _handleToggleEaten,
                                  );
                                });
                              })(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          extendBody: true,
          bottomNavigationBar: BottomNavBar(
            currentIndex: 1,
            onTap: widget.onTabTapped,
            photoUrl: snapshot.data?.photoUrl,
          ),
        );
      },
    );
  }
}

class _TimeLineRow extends StatelessWidget {
  final String timeLabel;
  final bool hasSlot;
  final Meal? meal;
  final int? mealIndex; // ADDED
  final Future<void> Function(int mealIndex, bool newValue)
  onToggleEaten; // CHANGED

  const _TimeLineRow({
    required this.timeLabel,
    required this.hasSlot,
    this.meal,
    this.mealIndex,
    required this.onToggleEaten,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF363434);

    final IconData mealIcon = meal?.type == 'ASI'
        ? Icons.water_drop
        : meal?.type.toLowerCase() == 'snack'
        ? Icons.cookie
        : Icons.restaurant;

    return SizedBox(
      height: 90,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: hasSlot
                ? GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => RecommendationDetailDialog(
                          meal: meal!,
                          isEaten: meal!.isEaten,
                          onToggleEaten: (newValue) =>
                              onToggleEaten(mealIndex!, newValue), // CHANGED
                        ),
                      );
                    },
                    child: Opacity(
                      opacity: meal!.isEaten ? 0.5 : 1.0,
                      child: Card(
                        color: const Color(0xFFFDF8F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFFE8D5B7),
                            width: 1.5,
                          ),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.only(
                          right: 8,
                          bottom: 8,
                          top: 0,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        144,
                                        121,
                                        84,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      meal?.type ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  if (meal?.name != null)
                                    Text(
                                      meal!.name!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  else
                                    const Text(
                                      'Air Susu Ibu',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  color: const Color.fromARGB(
                                    255,
                                    122,
                                    105,
                                    95,
                                  ),
                                  child: Icon(
                                    mealIcon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    margin: const EdgeInsets.only(right: 8, top: 15),
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 1,
                      color: activeColor.withOpacity(0.2),
                    ),
                  ),
          ),

          SizedBox(
            width: 52,
            child: Column(
              children: [
                Container(
                  width: 1.5,
                  height: 12,
                  color: activeColor.withOpacity(0.2),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hasSlot ? activeColor : activeColor.withOpacity(0.3),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    color: activeColor.withOpacity(0.2),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: 40,
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                timeLabel,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
