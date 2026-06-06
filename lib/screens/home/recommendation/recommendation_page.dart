import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/services/database.dart';
import 'package:rumi/shared/bottomnavbar.dart';
import 'package:rumi/shared/calendar_strip.dart';

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
            toolbarHeight: 100,
            backgroundColor: const Color.fromARGB(255, 0, 138, 218),
            elevation: 0.0,
            flexibleSpace: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Jadwal MPASI',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 8),
                    babies.isEmpty
                        ? const Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Colors.white38,
                                size: 10,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Belum ada profil bayi yang aktif',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          )
                        : DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isDense: true,
                              value: activeBaby?.id,
                              dropdownColor: const Color.fromARGB(
                                255,
                                0,
                                118,
                                185,
                              ),
                              iconEnabledColor: Colors.white,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              hint: const Row(
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: Colors.white54,
                                    size: 10,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Belum ada profil bayi yang aktif',
                                    style: TextStyle(
                                      color: Colors.white70,
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
                                          color: Colors.white,
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
                                      color: Colors.white,
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
            ),
          ),

          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 113, 222, 255),
                  Color.fromARGB(255, 220, 235, 240),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // fixed top section
                  Padding(
                    padding: const EdgeInsetsGeometry.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Calendar strip
                        CalendarStrip(
                          selectedDate: _selectedDate,
                          onDateSelected: (date) {
                            setState(() => _selectedDate = date);
                          },
                          showCard: true,
                          showArrows: true,
                        ),
                        const SizedBox(height: 12),

                        // Selected date label
                        Text(
                          '${_selectedDate.day} ${_monthName(_selectedDate.month)}, ${_dayName(_selectedDate.weekday)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                  // Scrollable timeline
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      child: Column(
                        children: List.generate(24, (hour) {
                          final hasSlot = hour == 13 || hour == 18;
                          final timeLabel =
                              '${hour.toString().padLeft(2, '0')}.00';

                          return _TimeLineRow(
                            timeLabel: timeLabel,
                            hasSlot: hasSlot,
                            slotLabel: hour == 13 ? 'Tes 1' : 'Tes 2',
                          );
                        }),
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
  final String slotLabel;

  const _TimeLineRow({
    required this.timeLabel,
    required this.hasSlot,
    required this.slotLabel,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color.fromARGB(255, 0, 138, 218);

    return SizedBox(
      height: 64,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // left: card or empty
          Expanded(
            child: hasSlot
                ? GestureDetector(
                    onTap: () {
                      // detail page later
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(right: 8, bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          slotLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ),

          // right: line + time label
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

          // time label
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
