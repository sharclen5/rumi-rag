import 'package:flutter/material.dart';
import 'package:rumi/models/baby.dart';
import 'package:rumi/screens/home/baby/baby_detail.dart';

class BabyTile extends StatelessWidget {
  final Baby baby;
  final VoidCallback onDelete;
  const BabyTile({super.key, required this.baby, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isMale = baby.gender.toLowerCase() == 'male';
    final avatarColor = isMale
        ? const Color.fromARGB(255, 140, 202, 253)
        : const Color.fromARGB(255, 255, 146, 182);

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Material(
        // ADDED: gives InkWell a proper ripple ancestor, same fix pattern as NutritionCard's pills
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.4),
            builder: (context) => BabyDetail(baby: baby, onDelete: onDelete),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF8F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8D5B7), width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25.0,
                  backgroundColor: avatarColor,
                  child: Text(
                    baby.firstName.isNotEmpty
                        ? baby.firstName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        baby.fullName,
                        style: const TextStyle(
                          color: Color(0xFF363434),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${baby.ageInMonths} bulan · ${baby.weight} kg',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
