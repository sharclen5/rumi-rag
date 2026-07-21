import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rumi/shared/rag_info.dart';

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
        color: const Color(0xFFFDF8F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE8D5B7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getGreeting(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF6A655F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      greetingTitle,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF363434),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // CHANGED: badge is now a Positioned overlay on the logo (Stack), not a Column sibling — keeps Row height unchanged
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Image.asset('assets/images/logo_tp.png', height: 80),

                  // ADDED: "With RAG" badge, floats below the logo without adding to Row height
                  Positioned(
                    bottom: -30,
                    child: GestureDetector(
                      onTap: () => showRagInfo(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF363434),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.network_intel_node,
                              size: 16,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'With RAG',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // END CHANGE
            ],
          ),
          const SizedBox(
            height: 24,
          ), // CHANGED: increased from 12 to make room for the badge floating below the logo

          Text(
            'Semoga hari ini menyenangkan bersama si kecil.',
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 5),

          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: activeBaby?.id,
              isExpanded: true,
              dropdownColor: const Color(0xFFFDF8F2),
              style: const TextStyle(color: Color(0xFF363434), fontSize: 14),
              items: babies.map((baby) {
                return DropdownMenuItem(
                  value: baby.id,
                  child: Text('${baby.fullName} • ${baby.ageInMonths} bulan'),
                );
              }).toList(),
              onChanged: onBabyChanged,
            ),
          ),
        ],
      ),
    );
  }
}
