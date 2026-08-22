import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/shared/rag_badge.dart';

class HomeHero extends StatelessWidget {
  final UserProfile? profile;
  final Baby? activeBaby;
  final List<Baby> babies;
  final ValueChanged<String?> onBabyChanged;

  const HomeHero({
    super.key,
    required this.profile,
    required this.activeBaby,
    required this.babies,
    required this.onBabyChanged,
  });

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam,';
  }

  @override
  Widget build(BuildContext context) {
    final firstName = profile?.firstName ?? '';
    final isMale = profile?.gender.toLowerCase() == 'male';

    final greetingTitle = isMale ? 'Bapak $firstName' : 'Ibu $firstName';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2828),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF4A4646)),
      ),
      // bungkus isi Container pake Stack, biar badge bisa nempel fixed
      // di pojok kiri atas card, lepas dari flow Row/Column teks & logo
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            // kasih jarak dari atas, biar konten ga ketiban badge
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getGreeting(),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            greetingTitle,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFF2DAB1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset('assets/images/logo_tp.png', height: 80),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'Semoga hari ini menyenangkan bersama si kecil.',
                  style: TextStyle(color: Color(0xFFF2DAB1)),
                ),

                const SizedBox(height: 5),

                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: activeBaby?.id,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2A2828),
                    style: const TextStyle(
                      color: Color(0xFFF2DAB1),
                      fontSize: 14,
                    ),
                    items: babies.map((baby) {
                      return DropdownMenuItem(
                        value: baby.id,
                        child: Text(
                          '${baby.fullName} • ${baby.ageInMonths} bulan',
                        ),
                      );
                    }).toList(),
                    onChanged: onBabyChanged,
                  ),
                ),
              ],
            ),
          ),

          //  badge, posisi fixed top-left
          Positioned(
            top: -2,
            left: -2,
            child: RagBadge(size: RagBadgeSize.small),
          ),
        ],
      ),
    );
  }
}
