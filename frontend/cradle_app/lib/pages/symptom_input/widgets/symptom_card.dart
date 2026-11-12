import 'package:flutter/material.dart';
import '../../../core/models/symptom.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/language_provider.dart';
import 'package:provider/provider.dart';

/// A single selectable symptom card in the input screen's grid.
class SymptomCard extends StatelessWidget {
  final Symptom symptom;
  final bool selected;
  final VoidCallback onTap;

  const SymptomCard({
    super.key,
    required this.symptom,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFF5F8) : Colors.white,
            borderRadius: BorderRadius.circular(AppRadii.card),
            border: Border.all(
              color: selected ? AppColors.rose : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: appCardShadow,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    symptom.icon,
                    width: 28,
                    height: 28,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    symptom.displayLabel(isBangla),
                    textAlign: TextAlign.center,
                    style: AppText.cardLabel,
                  ),
                ],
              ),
              if (selected)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: Text(
                    '✓',
                    style: TextStyle(
                      color: AppColors.roseDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
