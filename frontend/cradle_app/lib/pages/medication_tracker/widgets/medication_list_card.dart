import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../models/medication.dart';
import '../../../providers/language_provider.dart';
import 'med_icon_avatar.dart';

/// A card in the "My Medications" list, showing the medication's icon,
/// name, dose, frequency, and its scheduled time(s), with edit/delete
/// action buttons.
class MedicationListCard extends StatelessWidget {
  final Medication medication;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicationListCard({
    super.key,
    required this.medication,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final scheduleTag = medication.times.map((t) => t.format(context)).join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        boxShadow: appCardShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MedIconAvatar(assetPath: medication.iconAsset, size: 44, iconSize: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(medication.name, style: AppText.cardLabel.copyWith(fontSize: 15)),
                const SizedBox(height: 3),
                Text(
                  '${medication.formattedAmount} ${medication.doseUnit} · ${medication.frequencyLabel(isBangla)}',
                  style: AppText.subtext,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEAF1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    scheduleTag,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: DashboardBottomNav.primaryPink,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              _ActionIcon(icon: Icons.edit_outlined, onTap: onEdit),
              const SizedBox(height: 8),
              _ActionIcon(icon: Icons.delete_outline, onTap: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ActionIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFDEAF1),
      borderRadius: BorderRadius.circular(9),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 15, color: DashboardBottomNav.primaryPink),
        ),
      ),
    );
  }
}
