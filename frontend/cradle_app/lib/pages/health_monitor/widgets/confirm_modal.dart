import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/bottom_nav.dart';

const _brand = DashboardBottomNav.primaryPink;
const _brandSofter = Color(0xFFFCEEF5);
const _danger = Color(0xFFD64545);
const _ink = Color(0xFF3A2C33);
const _muted = Color(0xFF8A7680);

/// Centered confirmation modal matching .confirm-modal in the prototype.
Future<void> showHealthConfirmDialog(
  BuildContext context, {
  required String emoji,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  required VoidCallback onConfirm,
  bool danger = true,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.gentiumBookPlus(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: _muted, height: 1.5),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _ModalButton(
                    label: cancelLabel,
                    background: _brandSofter,
                    foreground: _brand,
                    onTap: () => Navigator.of(ctx).pop(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ModalButton(
                    label: confirmLabel,
                    background: danger ? _danger : _brand,
                    foreground: Colors.white,
                    onTap: () {
                      Navigator.of(ctx).pop();
                      onConfirm();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _ModalButton extends StatelessWidget {
  const _ModalButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

/// Toast-style snackbar matching .toast in the prototype.
void showHealthToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _ink,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: const EdgeInsets.only(bottom: 26, left: 60, right: 60),
      duration: const Duration(milliseconds: 2200),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}
