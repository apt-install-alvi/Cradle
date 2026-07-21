import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { filled, outlined, danger }

/// A pill-shaped button used for Next/Done, and all diagnosis-screen
/// actions. [variant] controls the visual treatment; [icon] is optional.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.button),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.button),
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              color: variant == AppButtonVariant.outlined ? Colors.white : null,
              gradient: _gradient,
              borderRadius: BorderRadius.circular(AppRadii.button),
              border: variant == AppButtonVariant.outlined
                  ? Border.all(color: AppColors.rose, width: 1.5)
                  : null,
              boxShadow: variant == AppButtonVariant.outlined
                  ? appCardShadow
                  : [
                      BoxShadow(
                        color: variant == AppButtonVariant.danger
                            ? const Color(0x59C22F2F)
                            : const Color(0x59C8466E),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: _foreground),
                  const SizedBox(width: 10),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color get _foreground =>
      variant == AppButtonVariant.outlined ? AppColors.roseDark : Colors.white;

  Gradient? get _gradient {
    switch (variant) {
      case AppButtonVariant.filled:
        return AppGradients.roseButton;
      case AppButtonVariant.danger:
        return AppGradients.ambulanceButton;
      case AppButtonVariant.outlined:
        return null;
    }
  }
}
