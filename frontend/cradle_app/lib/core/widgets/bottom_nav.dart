import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../../providers/language_provider.dart';

class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    this.selectedIndex = 0,
  });

  final int selectedIndex;

  static const Color primaryPink = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .35),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: .18),
              blurRadius: 18,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            _buildNavItem(
              context,
              icon: "assets/icons/home.svg",
              label: isBangla ? "হোম" : "Home",
              index: 0,
              route: "/dashboard",
            ),

            _buildNavItem(
              context,
              icon: "assets/icons/diagnosis.svg",
              label: isBangla ? "লক্ষণ" : "Diagnosis",
              index: 1,
              route: "/symptom-input",
            ),

            _buildNavItem(
              context,
              icon: "assets/icons/guides.svg",
              label: isBangla ? "নির্দেশিকা" : "Guides",
              index: 2,
              route: AppRoutes.education,
            ),

            _buildNavItem(
              context,
              icon: "assets/icons/profile.svg",
              label: isBangla ? "প্রোফাইল" : "Profile",
              index: 3,
              route: AppRoutes.personalInfo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required String icon,
    required String label,
    required int index,
    required String route,
  }) {
    final bool selected = selectedIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        if (selected) return;

        Navigator.pushReplacementNamed(
          context,
          route,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: selected ? 1.1 : 1.0,
              child: SvgPicture.asset(
                icon,
                width: 28,
                height: 28,
                colorFilter: ColorFilter.mode(
                  selected
                      ? primaryPink
                      : primaryPink.withValues(alpha: .65),
                  BlendMode.srcIn,
                ),
              ),
            ),

            const SizedBox(height: 6),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.gentiumBookPlus(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: selected
                    ? primaryPink
                    : primaryPink.withValues(alpha: .65),
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}