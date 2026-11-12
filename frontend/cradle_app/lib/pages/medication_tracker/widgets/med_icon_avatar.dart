import 'package:flutter/material.dart';
import '../../../core/widgets/bottom_nav.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Displays a medication/dose icon as a tinted PNG inside a rounded
/// square background. Falls back to the shared placeholder asset
/// ('assets/icons/placeholder.png') until per-medicine-type icon
/// assets are added to the project.
class MedIconAvatar extends StatelessWidget {
  final String assetPath;
  final double size;
  final double iconSize;

  const MedIconAvatar({
    super.key,
    this.assetPath = 'assets/icons/placeholder.png',
    this.size = 40,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFDEAF1),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      alignment: Alignment.center,
      child: ColorFiltered(
        colorFilter: const ColorFilter.mode(
          DashboardBottomNav.primaryPink,
          BlendMode.srcIn,
        ),
        child: SvgPicture.asset(
          assetPath,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            DashboardBottomNav.primaryPink,
            BlendMode.srcIn,
          ),
          placeholderBuilder: (_) => Icon(
            Icons.medication_outlined,
            size: iconSize,
            color: DashboardBottomNav.primaryPink,
          ),
        ),
      ),
    );
  }
}
