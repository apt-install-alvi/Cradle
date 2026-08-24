import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/settings_provider.dart';

class LanguageToggle extends StatelessWidget {
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? textColor;

  const LanguageToggle({
    super.key,
    this.activeColor,
    this.inactiveColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final settingsProvider = context.read<SettingsProvider?>();
    final bool isBangla = languageProvider.isBangla;

    final Color brandColor = activeColor ?? const Color(0xFFAB0A65);
    final Color bgColor = inactiveColor ?? Colors.white.withValues(alpha: .5);
    final Color textCol = textColor ?? brandColor;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: brandColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleItem(
            label: 'English',
            isSelected: !isBangla,
            brandColor: brandColor,
            textColor: textCol,
            onTap: () {
              languageProvider.setLanguage(false);
              settingsProvider?.updateLanguage('en');
            },
          ),
          _ToggleItem(
            label: 'বাংলা',
            isSelected: isBangla,
            brandColor: brandColor,
            textColor: textCol,
            onTap: () {
              languageProvider.setLanguage(true);
              settingsProvider?.updateLanguage('bn');
            },
          ),
        ],
      ),
    );
  }
}

class _ToggleItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color brandColor;
  final Color textColor;
  final VoidCallback onTap;

  const _ToggleItem({
    required this.label,
    required this.isSelected,
    required this.brandColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? brandColor : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          label,
          style: GoogleFonts.gentiumBookPlus(
            color: isSelected ? Colors.white : textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
