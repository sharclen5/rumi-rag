import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:rumi/shared/rag_info.dart';

// enum buat milih preset ukuran badge, biar tiap halaman ga nebak-nebak angka baru
// large = ukuran yang dipake di register & sign_in (sebelum di-share)
// small = ukuran yang dipake di home_hero (sebelum di-share)
enum RagBadgeSize { small, large }

class RagBadge extends StatelessWidget {
  final RagBadgeSize size;

  const RagBadge({super.key, this.size = RagBadgeSize.large});

  @override
  Widget build(BuildContext context) {
    // tentuin icon size & font size berdasarkan preset yang dipilih
    final double iconSize = size == RagBadgeSize.small ? 16 : 20;
    final double fontSize = size == RagBadgeSize.small ? 12 : 16;

    return GestureDetector(
      // selalu tappable, sesuai kesepakatan — buka showRagInfo tiap di-tap
      onTap: () => showRagInfo(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2DAB1),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Symbols.network_intel_node,
              size: iconSize,
              color: Color((0xFF2A2828))
            ),
            const SizedBox(width: 4),
            Text(
              'With RAG',
              style: TextStyle(
                color: Color((0xFF2A2828)),
                fontSize: fontSize,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
