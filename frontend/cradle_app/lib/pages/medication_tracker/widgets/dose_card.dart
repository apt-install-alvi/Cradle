import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../models/scheduled_dose.dart';
import 'med_icon_avatar.dart';

/// A single row in the "Today's Schedule" timeline: shows the
/// medication's icon, name, dose amount, and scheduled time, with a
/// tappable circular check button to mark the dose taken/not taken.
class DoseCard extends StatelessWidget {
  final ScheduledDose dose;
  final VoidCallback onToggle;

  const DoseCard({super.key, required this.dose, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final med = dose.medication;
    final taken = dose.taken;

    return Opacity(
      opacity: taken ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadii.card),
          boxShadow: appCardShadow,
        ),
        child: Row(
          children: [
            MedIconAvatar(assetPath: med.iconAsset),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: AppText.cardLabel.copyWith(
                      decoration: taken ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${med.formattedAmount} ${med.doseUnit} · ${dose.time.format(context)}',
                    style: AppText.subtext,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _CheckButton(checked: taken, onTap: onToggle),
          ],
        ),
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  final bool checked;
  final VoidCallback onTap;
  const _CheckButton({required this.checked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: checked ? DashboardBottomNav.primaryPink : Colors.white,
            border: Border.all(color: DashboardBottomNav.primaryPink, width: 2),
          ),
          child: checked
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
