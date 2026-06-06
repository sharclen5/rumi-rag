import 'package:flutter/material.dart';
import 'dart:convert';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String? photoUrl;
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_rounded,
              label: 'Beranda',
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _NavItem(
              icon: Icons.recommend_rounded,
              label: 'Rekomendasi',
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap,
            ),
            _NavItem(
              icon: Icons.history_rounded,
              label: 'Riwayat',
              index: 2,
              currentIndex: currentIndex,
              onTap: (i) {},
            ),
            _AvatarNavItem(
              index: 3,
              currentIndex: currentIndex,
              onTap: onTap,
              photoUrl: photoUrl,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    const activeColor = Color.fromARGB(255, 0, 138, 218);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(microseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Icon(
          icon,
          size: 26,
          color: isSelected ? activeColor : Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _AvatarNavItem extends StatelessWidget {
  final int index;
  final int currentIndex;
  final Function(int) onTap;
  final String? photoUrl;

  const _AvatarNavItem({
    required this.index,
    required this.currentIndex,
    required this.onTap,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentIndex == index;
    const activeColor = Color.fromARGB(255, 0, 138, 218);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(microseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: CircleAvatar(
          radius: 14,
          backgroundImage:
              photoUrl != null && photoUrl!.startsWith('data:image')
              ? MemoryImage(base64Decode(photoUrl!.split(',').last))
              : const AssetImage('assets/images/placeholder.jpg')
                    as ImageProvider,
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'dart:convert';

// class BottomNavBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//   final String? photoUrl;

//   const BottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     this.photoUrl,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       backgroundColor: Color.fromARGB(255, 0, 138, 218),
//       elevation: 0.0,
//       type: BottomNavigationBarType.fixed,
//       currentIndex: currentIndex,
//       onTap: (index) {
//         if (index == 1 || index == 2)
//           return; // disable page Rekomendasi sama Riwayat buat sementara
//         onTap(index);
//       },
//       selectedItemColor: const Color.fromARGB(255, 113, 222, 255),
//       unselectedItemColor: Colors.white,
//       items: [
//         const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
//         const BottomNavigationBarItem(
//           icon: Icon(Icons.recommend),
//           label: 'Rekomendasi',
//         ),
//         const BottomNavigationBarItem(
//           icon: Icon(Icons.history),
//           label: 'Riwayat',
//         ),
//         BottomNavigationBarItem(
//           icon: Center(
//             child: CircleAvatar(
//               radius: 12,
//               backgroundImage:
//                   photoUrl != null && photoUrl!.startsWith('data:image')
//                   ? MemoryImage(base64Decode(photoUrl!.split(',').last))
//                   : const AssetImage('assets/images/placeholder.jpg')
//                         as ImageProvider,
//             ),
//           ),
//           label: 'You',
//         ),
//       ],
//     );
//   }
// }
