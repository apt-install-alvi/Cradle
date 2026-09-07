import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MissedStatusRow extends StatelessWidget {
  final bool showMedication;
  final bool showHealth;

  final String medicationTitle;
  final String medicationSubtitle;

  final String healthTitle;
  final String healthSubtitle;

  final VoidCallback? onMedicationTap;
  final VoidCallback? onHealthTap;

  const MissedStatusRow({
    super.key,
    required this.showMedication,
    required this.showHealth,
    required this.medicationTitle,
    required this.medicationSubtitle,
    required this.healthTitle,
    required this.healthSubtitle,
    this.onMedicationTap,
    this.onHealthTap,
  });

  @override
  Widget build(BuildContext context) {
    // Nothing is set up, so don't show anything.
    if (!showMedication && !showHealth) {
      return const SizedBox.shrink();
    }

    // If only one tracker is set up, let its card take the full width.
    if (showMedication && !showHealth) {
      return _StatusCard(
        title: medicationTitle,
        subtitle: medicationSubtitle,
        icon: Icons.medication_outlined,
        onTap: onMedicationTap,
      );
    }

    if (!showMedication && showHealth) {
      return _StatusCard(
        title: healthTitle,
        subtitle: healthSubtitle,
        icon: Icons.favorite_outline,
        onTap: onHealthTap,
      );
    }

    // Both are set up.
    return Row(
      children: [
        Expanded(
          child: _StatusCard(
            title: medicationTitle,
            subtitle: medicationSubtitle,
            icon: Icons.medication_outlined,
            onTap: onMedicationTap,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatusCard(
            title: healthTitle,
            subtitle: healthSubtitle,
            icon: Icons.favorite_outline,
            onTap: onHealthTap,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 120,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 24,
                color: const Color(0xFFAB0A65),
              ),

              const SizedBox(height: 10),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.gentiumBookPlus(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3D2440),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.gentiumBookPlus(
                  fontSize: 12,
                  color: const Color(0xFF6B5965),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}