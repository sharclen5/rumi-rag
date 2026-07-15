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

  static const _brand = Color.fromARGB(255, 144, 121, 84);
  static const _brandDark = Color.fromARGB(255, 122, 105, 95);
  static const _ink = Color(0xFF363434);
  static const _cardBg = Color(0xFFFDF8F2);
  static const _cardBorder = Color(0xFFE8D5B7);

  String _dayName(int weekday) {
    const days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jum'at",
      "Sabtu",
      "Minggu",
    ];
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

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
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

  void _jumpToToday() {
    if (_isToday) return;
    setState(() {
      _selectedDate = DateTime.now();
      _recommendation = null;
    });
    if (_lastFetchedBaby != null) {
      _fetchRecommendation(_lastFetchedBaby!);
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
                  // Header row: title + dropdown on the left, "hari ini"
                  // quick-jump action on the right — mirrors the
                  // title/dropdown/action-icon layout used on Recommendation,
                  // but the action here jumps back to today instead of
                  // opening an editor, since History looks backward.
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
                                'Riwayat MPASI',
                                style: TextStyle(
                                  color: _ink,
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
                                        iconEnabledColor: _ink,
                                        style: const TextStyle(
                                          color: _ink,
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
                                                    color: _ink,
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
                                                color: _ink,
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
                        if (activeBaby != null)
                          GestureDetector(
                            onTap: _jumpToToday,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 48,
                                height: 48,
                                color: _isToday
                                    ? _brandDark.withOpacity(0.4)
                                    : _brandDark,
                                child: const Icon(
                                  Icons.today,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

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
                                  16,
                                  16,
                                  0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CalendarStrip(
                                      selectedDate: _selectedDate,
                                      onDateSelected: (date) {
                                        setState(() {
                                          _selectedDate = date;
                                          _recommendation = null;
                                        });
                                        if (_lastFetchedBaby != null) {
                                          _fetchRecommendation(
                                            _lastFetchedBaby!,
                                          );
                                        }
                                      },
                                      uid: widget.uid,
                                      babyId: activeBaby.id,
                                      showCard: true,
                                      showArrows: true,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      '${_dayName(_selectedDate.weekday)}, ${_selectedDate.day} ${_monthName(_selectedDate.month)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: _ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: _isLoading
                                    ? const Loading()
                                    : _error != null
                                    ? Center(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.error_outline,
                                                color: Colors.red,
                                                size: 48,
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Gagal memuat riwayat',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: _brand,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  if (_lastFetchedBaby !=
                                                      null) {
                                                    _fetchRecommendation(
                                                      _lastFetchedBaby!,
                                                    );
                                                  }
                                                },
                                                child: const Text('Coba Lagi'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : _recommendation == null ||
                                          _recommendation!.meals.isEmpty
                                    ? Center(
                                        child: SingleChildScrollView(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.history_toggle_off,
                                                size: 48,
                                                color: Colors.grey.shade400,
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Tidak ada rencana menu untuk hari ini',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
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
                                          _CompletionSummaryCard(
                                            meals: _recommendation!.meals,
                                            brand: _brand,
                                            ink: _ink,
                                            cardBg: _cardBg,
                                            cardBorder: _cardBorder,
                                          ),
                                          const SizedBox(height: 12),
                                          ..._recommendation!.meals.map(
                                            (meal) => Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: _HistoryMealCard(
                                                meal: meal,
                                                brand: _brand,
                                                brandDark: _brandDark,
                                                ink: _ink,
                                                cardBg: _cardBg,
                                                cardBorder: _cardBorder,
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
}

/// Unique-to-History element: a completion summary, echoing the visual
/// weight of Home's "Kelengkapan Gizi" / tips cards, but built around
/// how much of the day's plan was actually followed.
class _CompletionSummaryCard extends StatelessWidget {
  final List<Meal> meals;
  final Color brand;
  final Color ink;
  final Color cardBg;
  final Color cardBorder;

  const _CompletionSummaryCard({
    required this.meals,
    required this.brand,
    required this.ink,
    required this.cardBg,
    required this.cardBorder,
  });

  @override
  Widget build(BuildContext context) {
    final total = meals.length;
    final eaten = meals.where((m) => m.isEaten).length;
    final ratio = total == 0 ? 0.0 : eaten / total;
    final allDone = total > 0 && eaten == total;

    return Card(
      color: cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cardBorder, width: 1.5),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  allDone ? '🎉 Semua menu selesai' : 'Ringkasan hari ini',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                Text(
                  '$eaten / $total menu',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: brand,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio,
                minHeight: 8,
                backgroundColor: cardBorder.withOpacity(0.5),
                valueColor: AlwaysStoppedAnimation<Color>(brand),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Meal row rebuilt as its own card, matching the icon-chip + type-badge
/// language of Recommendation's timeline cards, but read-only and dimmed
/// for anything not marked as eaten — appropriate for a look-back view.
class _HistoryMealCard extends StatelessWidget {
  final Meal meal;
  final Color brand;
  final Color brandDark;
  final Color ink;
  final Color cardBg;
  final Color cardBorder;

  const _HistoryMealCard({
    required this.meal,
    required this.brand,
    required this.brandDark,
    required this.ink,
    required this.cardBg,
    required this.cardBorder,
  });

  @override
  Widget build(BuildContext context) {
    final isAsi = meal.type == 'ASI';
    final label = isAsi ? 'Air Susu Ibu' : (meal.name ?? '');

    final IconData mealIcon = isAsi
        ? Icons.water_drop
        : meal.type.toLowerCase() == 'snack'
        ? Icons.cookie
        : Icons.restaurant;

    return Opacity(
      opacity: meal.isEaten ? 1.0 : 0.55,
      child: Card(
        color: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: cardBorder, width: 1.5),
        ),
        elevation: 2,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 44,
                  color: brandDark,
                  child: Icon(mealIcon, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: brand,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            meal.type,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          meal.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                meal.isEaten
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: meal.isEaten ? brand : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
