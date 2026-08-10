import 'package:flutter/material.dart';
import '../../../core/widgets/bottom_nav.dart';

class QuickStatusCard extends StatelessWidget {
  const QuickStatusCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    this.iconPath = 'assets/icons/placeholder.png',
    this.onTap,
  });

  final String label;
  final String value;
  final String sub;
  final String iconPath;
  final VoidCallback? onTap;

  static const Color _brand = DashboardBottomNav.primaryPink;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Color(0x29C87896), blurRadius: 16, offset: Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: const Color(0xFFFCE3EC), borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(8),
                child: Image.asset(iconPath, fit: BoxFit.contain, colorFilter: const ColorFilter.mode(_brand, BlendMode.srcIn)),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8A7680), letterSpacing: .3)),
              const SizedBox(height: 2),
              Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF3A2C33))),
              const SizedBox(height: 2),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: Color(0xFF8A7680))),
            ],
          ),
        ),
      ),
    );
  }
}