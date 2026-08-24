import 'package:flutter/material.dart';
import 'package:cradle_app/core/theme/app_theme.dart';
import '../../../core/widgets/language_toggle.dart';

class HealthTopBar extends StatelessWidget {
  const HealthTopBar({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showLanguageToggle = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showLanguageToggle;

  static const Color _muted = Color(0xFF8A7680);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFAB0A65),
                  size: 28,
                ),
                onPressed: onBack ?? () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppText.headerTitle.copyWith(fontSize: 24),
                ),
              ),
              if (showLanguageToggle)
                const LanguageToggle(),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 2),
              child: Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 16,
                  color: _muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}