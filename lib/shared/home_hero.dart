import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/models/user.dart';

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
          Text(
            getGreeting(),
            style: const TextStyle(fontSize: 15, color: Color(0xFF6A655F)),
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

          const SizedBox(height: 12),

          Text(
            'Semoga hari ini menyenangkan bersama si kecil.',
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 5),

          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: activeBaby?.id,
              isExpanded: true,
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
