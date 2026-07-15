import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rumi/screens/home/recommendation/add_recommendation.dart';
import 'dart:convert';
import 'package:rumi/models/baby.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:rumi/shared/tour_keys.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final String? photoUrl;
  final VoidCallback? onAddRecommendationTap;
  // overridable keys, default to the real app's TourKeys
  final GlobalKey? homeKey;
  final GlobalKey? rekomendasiKey;
  final GlobalKey? addButtonKey;
  final GlobalKey? riwayatKey;
  final GlobalKey? profileKey;
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.photoUrl,
    this.onAddRecommendationTap,
    this.homeKey,
    this.rekomendasiKey,
    this.addButtonKey,
    this.riwayatKey,
    this.profileKey,
  });

  @override
  Widget build(BuildContext context) {
    // ADDED: resolve overridable keys once, use everywhere below —
    // both in the Showcase `key:` and in onTargetClick's chaining,
    // so a demo instance never references real TourKeys
    final effectiveHomeKey = homeKey ?? TourKeys.homeNavIcon;
    final effectiveRekomendasiKey =
        rekomendasiKey ?? TourKeys.rekomendasiNavIcon;
    final effectiveAddButtonKey = addButtonKey ?? TourKeys.addButton;
    final effectiveRiwayatKey = riwayatKey ?? TourKeys.riwayatNavIcon;
    final effectiveProfileKey = profileKey ?? TourKeys.profileNavIcon;

    // ADDED: chained targets also need a demo/real switch. Simplest: derive
    // "is this a demo instance" from whether homeKey was overridden, and
    // pick the matching chain target keys.
    final isDemo = homeKey != null;
    final systemNavInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: 24 + systemNavInset,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Color(0xFF363434),
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
            Showcase(
              // (wraps Beranda)
              key: effectiveHomeKey,
              disableBarrierInteraction: true,
              title: 'Beranda',
              description:
                  'Halaman utama Rumi, ringkasan harian si kecil ada di sini',
              child: _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                index: 0,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ),

            Showcase(
              // ADDED (wraps Rekomendasi)
              key: effectiveRekomendasiKey,
              disableBarrierInteraction: true,
              title: 'Rekomendasi',
              description:
                  'Lihat rencana menu yang sudah dibuat untuk si kecil',
              disposeOnTap: false,
              onTargetClick: () {
                onTap(1);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ShowcaseView.get().startShowCase(
                    isDemo
                        ? [
                            TourKeys
                                .rekomendasiEmptyState, // demo reuses same mimic keys as real page — see note below
                            effectiveAddButtonKey,
                            effectiveRiwayatKey,
                          ]
                        : [
                            TourKeys.rekomendasiEmptyState,
                            effectiveAddButtonKey,
                            effectiveRiwayatKey,
                          ],
                  );
                });
              },
              child: _NavItem(
                icon: Icons.recommend_rounded,
                label: 'Rekomendasi',
                index: 1,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ),

            Showcase(
              // (wraps Buat Rencana) — tooltip only, tap just advances
              key: effectiveAddButtonKey,
              disableBarrierInteraction: true,
              title: 'Buat Rencana',
              description: 'Buat rencana menu baru untuk si kecil dari sini',
              child: _NavItem(
                icon: Icons.add_circle_outline,
                label: 'Buat Rencana',
                index: 2,
                currentIndex: currentIndex,
                onTap: (i) {
                  if (onAddRecommendationTap != null) {
                    onAddRecommendationTap!();
                    return;
                  }
                  showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.4),
                    builder: (dialogContext) => Provider<List<Baby>?>.value(
                      value: Provider.of<List<Baby>?>(
                        context,
                        listen: false,
                      ), // outer context
                      child: const AddRecommendation(),
                    ),
                  );
                },
              ),
            ),

            Showcase(
              // ADDED (wraps Riwayat)
              key: effectiveRiwayatKey,
              disableBarrierInteraction: true,
              title: 'Riwayat',
              description: 'Lihat riwayat menu yang sudah pernah diberikan',
              disposeOnTap: false,
              onTargetClick: () {
                onTap(3);
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (!context.mounted)
                    return; // guard against disposed context
                  ShowcaseView.get().startShowCase([
                    TourKeys.riwayatPage,
                    effectiveProfileKey,
                  ]);
                });
              },
              child: _NavItem(
                icon: Icons.history_rounded,
                label: 'Riwayat',
                index: 3,
                currentIndex: currentIndex,
                onTap: onTap,
              ),
            ),

            Showcase(
              // ADDED (wraps Profile avatar)
              key: effectiveProfileKey,
              disableBarrierInteraction: true,
              title: 'Profil',
              description: 'Kelola profil bayi dan pengaturan akun di sini',
              disposeOnTap: false,
              onTargetClick: () {
                onTap(4);
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (!context.mounted)
                    return; // guard against disposed context
                  ShowcaseView.get().startShowCase([TourKeys.profilePage]);
                });
              },
              child: _AvatarNavItem(
                index: 4,
                currentIndex: currentIndex,
                onTap: onTap,
                photoUrl: photoUrl,
              ),
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
    const activeColor = Color.fromARGB(255, 242, 218, 177);

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
    const activeColor = Color.fromARGB(255, 242, 218, 177);

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
        child: photoUrl != null
            ? CircleAvatar(
                radius: 14,
                backgroundImage: photoUrl!.startsWith('data:image')
                    ? MemoryImage(base64Decode(photoUrl!.split(',').last))
                    : NetworkImage(photoUrl!) as ImageProvider,
              )
            : CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFFE8C99A),
                child: Icon(Icons.person, color: Color(0xFF8B6F47), size: 16),
              ),
      ),
    );
  }
}
