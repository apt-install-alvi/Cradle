import 'package:flutter/material.dart';
import 'quick_status_card.dart';

class MissedStatusRow extends StatelessWidget {
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

  final bool showMedication;
  final bool showHealth;

  final String medicationTitle;
  final String medicationSubtitle;

  final String healthTitle;
  final String healthSubtitle;

  final VoidCallback? onMedicationTap;
  final VoidCallback? onHealthTap;

  @override
  Widget build(BuildContext context) {
    if (!showMedication && !showHealth) {
      return const SizedBox.shrink();
    }

    // Only medication: medication goes on the left.
    if (showMedication && !showHealth) {
      return Row(
        children: [
          QuickStatusCard(
            label: medicationTitle,
            value: medicationSubtitle,
            sub: '',
            iconPath: 'assets/icons/pill.svg',
            onTap: onMedicationTap,
            valueMaxLines: 2,
          ),
          const Expanded(
            child: SizedBox(),
          ),
        ],
      );
    }

    // Only health: health ALSO goes on the left.
    if (!showMedication && showHealth) {
      return Row(
        children: [
          QuickStatusCard(
            label: healthTitle,
            value: healthSubtitle,
            sub: '',
            iconPath: 'assets/icons/heartbeat.png',
            onTap: onHealthTap,
            valueMaxLines: 2,
          ),
          const Expanded(
            child: SizedBox(),
          ),
        ],
      );
    }

    // Both: medication left, health right.
    return Row(
      children: [
        QuickStatusCard(
          label: medicationTitle,
          value: medicationSubtitle,
          sub: '',
          iconPath: 'assets/icons/pill.svg',
          onTap: onMedicationTap,
          valueMaxLines: 2,
        ),
        const SizedBox(width: 12),
        QuickStatusCard(
          label: healthTitle,
          value: healthSubtitle,
          sub: '',
          iconPath: 'assets/icons/heartbeat.png',
          onTap: onHealthTap,
          valueMaxLines: 2,
        ),
      ],
    );
  }
}