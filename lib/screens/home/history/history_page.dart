import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/models/meal.dart';
import 'package:rumi/models/recommendation.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';
import 'package:rumi/shared/loading.dart';

class HistoryPage extends StatelessWidget {
  final Function(int) onTabTapped;
  const HistoryPage({super.key, required this.onTabTapped});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    return StreamProvider<List<Baby>>.value(
      value: DatabaseService(uid: user!.uid).babies,
      initialData: const [],
      child: _HistoryView(uid: user.uid, onTabTapped: onTabTapped),
    );
  }
}

class _HistoryView extends StatefulWidget {
  final String uid;
  final Function(int) onTabTapped;
  const _HistoryView({required this.uid, required this.onTabTapped});

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  Recommendation? _recommendation;
  bool _isLoading = false;
  String? _error;
  Baby? _lastFetchedBaby;
  DateTime _selectedDate = DateTime.now();

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
      builder: (context, userSnapshot) {
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Riwayat MPASI',
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
                                  iconEnabledColor: const Color(0xFF363434),
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
                  const SizedBox(height: 16),

                  Expanded(
                    child: activeBaby == null
                        ? Center(
                            child: Text(
                              'Belum ada profil bayi yang aktif',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  0,
                                ),
                                child: CalendarStrip(
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
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _isLoading
                                    ? Loading()
                                    : _error != null
                                    ? Center(
                                        child: Text(
                                          'Gagal memuat riwayat: $_error',
                                          style: TextStyle(
                                            color: Colors.red.shade400,
                                            fontSize: 12,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    : _recommendation == null ||
                                          _recommendation!.meals.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Tidak ada rencana menu untuk hari ini',
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      )
                                    : ListView(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          100,
                                        ),
                                        children: [
                                          Card(
                                            color: const Color(0xFFFDF8F2),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              side: const BorderSide(
                                                color: Color(0xFFE8D5B7),
                                                width: 1.5,
                                              ),
                                            ),
                                            elevation: 2,
                                            child: Padding(
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: _recommendation!.meals
                                                    .map(
                                                      (meal) => _HistoryMealRow(
                                                        meal: meal,
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          extendBody: true,
          bottomNavigationBar: BottomNavBar(
            currentIndex: 3,
            onTap: widget.onTabTapped,
            photoUrl: userSnapshot.data?.photoUrl,
          ),
        );
      },
    );
  }

  // END CHANGE
}

class _HistoryMealRow extends StatelessWidget {
  final Meal meal;
  const _HistoryMealRow({required this.meal});

  @override
  Widget build(BuildContext context) {
    final isAsi = meal.type == 'ASI';
    final label = isAsi ? 'Air Susu Ibu' : (meal.name ?? '');

    // marked (isEaten) meals are highlighted, unmarked are dimmed
    final opacity = meal.isEaten ? 1.0 : 0.4;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              meal.isEaten ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: meal.isEaten
                  ? const Color.fromARGB(255, 144, 121, 84)
                  : Colors.grey.shade500,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${meal.time} · $label',
                style: const TextStyle(fontSize: 13, color: Color(0xFF363434)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
