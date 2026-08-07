import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Shared sub-screen header: large thick chevron back button (no
/// background/shadow) + title + optional subtitle, matching the
/// established app-wide back-arrow style.
class HealthTopBar extends StatelessWidget {
  const HealthTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;

  static const Color _ink = Color(0xFF4A2F3A);
  static const Color _muted = Color(0xFF8A7680);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: onBack ?? () => Navigator.of(context).pop(),
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.chevron_left, size: 30, color: _ink),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.gentiumBookPlus(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 11.5, color: _muted),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
