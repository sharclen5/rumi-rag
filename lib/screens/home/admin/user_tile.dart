import 'package:flutter/material.dart';
import 'package:rumi/models/user.dart';
import 'package:rumi/screens/home/admin/user_detail.dart';

class UserTile extends StatelessWidget {
  final UserProfile user;
  const UserTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    // warna avatar sama kayak baby tile — biru laki, pink perempuan, abu kalo ga ada
    final isMale =
        user.gender.toLowerCase() == 'male' ||
        user.gender.toLowerCase() == 'laki-laki';
    final avatarColor = user.gender.isEmpty
        ? Colors.grey.shade600
        : isMale
        ? const Color.fromARGB(255, 140, 202, 253)
        : const Color.fromARGB(255, 255, 146, 182);

    final initials = [
      user.firstName,
      user.lastName,
    ].where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).join();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => showDialog(
            context: context,
            barrierColor: Colors.black.withOpacity(0.4),
            builder: (context) => UserDetail(user: user),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 12.0,
            ),
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2828),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF4A4646), width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25.0,
                  backgroundColor: avatarColor,
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
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
                        '${user.firstName} ${user.lastName}'.trim(),
                        style: const TextStyle(
                          color: Color(0xFFF2DAB1),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // badge role — biar keliatan mana yang admin
                if (user.role == 'admin')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        144,
                        121,
                        84,
                      ).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color.fromARGB(255, 144, 121, 84),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'Admin',
                      style: TextStyle(
                        color: Color(0xFFF2DAB1),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
