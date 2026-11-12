import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../routes/app_routes.dart';
import '../../providers/language_provider.dart';

/// Bottom navigation bar with a circular "Diagnosis" button that pokes up
/// through a matching circular notch cut into the bar.
///
/// Layout: Home + Guides on the left, Diagnosis centered as a raised
/// circle, Medicine Tracker + Health Monitor on the right. Profile has been
/// removed from the nav.
///
/// Index map: 0 Home · 1 Guides · 2 Diagnosis · 3 Medicine Tracker · 4 Health
/// Monitor. Screens outside this set (e.g. Profile, Settings) should keep
/// passing `selectedIndex: -1`.
class DashboardBottomNav extends StatelessWidget {
  const DashboardBottomNav({
    super.key,
    this.selectedIndex = 0,
  });

  final int selectedIndex;

  static const Color primaryPink = Color(0xFFAB0A65);

  // ---- Layout constants -----------------------------------------------
  static const double _barHeight = 78;
  static const double _barBottomOffset = 0;
  static const double _barSideMargin = 0;
  static const double _stackHeight = _barBottomOffset + _barHeight + 4;

  static const double _fabDiameter = 74;
  static const double _fabBottomOffset = 22;
  static const double _fabRadius = _fabDiameter / 2;

  static const double _cornerRadius = 0;
  // Gap left between the button's edge and the notch's edge, so a sliver of
  // the gradient background peeks through all the way around the circle.
  static const double _notchGap = 8;
  static const double _notchRadius = _fabRadius + _notchGap;
  // Vertical distance from the top of the bar down to the notch circle's
  // center. Derived from the fab's position: the fab's center sits
  // (_fabBottomOffset + _fabRadius) up from the stack's bottom, and the
  // bar's top sits (_barBottomOffset + _barHeight) up from the stack's
  // bottom, so the notch center is the difference between the two.
  static const double _notchCenterY =
      (_barBottomOffset + _barHeight) - (_fabBottomOffset + _fabRadius);

  static const String _medicationTrackerRoute = '/medication-tracker';
  static const String _healthMonitorRoute = '/health-monitor';

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: _stackHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ---- Notched glass bar ----------------------------------
            Positioned(
              left: _barSideMargin,
              right: _barSideMargin,
              bottom: _barBottomOffset,
              height: _barHeight,
              child: ClipPath(
                clipper: const _NotchedBarClipper(
                  cornerRadius: _cornerRadius,
                  notchRadius: _notchRadius,
                  notchCenterY: _notchCenterY,
                ),
                child: Container(
                  color: const Color(0xFFFFE8F2),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [

                    Expanded(
                      child: Row(
                        children: [

                          Expanded(
                            child: _NavItem(
                              icon: "assets/icons/home.svg",
                              label: isBangla ? "হোম" : "Home",
                              selected: selectedIndex == 0,
                              onTap: () => _navigate(
                                context,
                                0,
                                AppRoutes.dashboard,
                              ),
                            ),
                          ),

                          Expanded(
                            child: _NavItem(
                              icon: "assets/icons/guides.svg",
                              label: isBangla ? "নির্দেশিকা" : "Guides",
                              selected: selectedIndex == 1,
                              onTap: () => _navigate(
                                context,
                                1,
                                AppRoutes.education,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                    SizedBox(width: _fabDiameter + 25),

                    Expanded(
                      child: Row(
                        children: [

                          Expanded(
                            child: _NavItem(
                              icon: "assets/icons/medicine_tracker.svg",
                              label: isBangla
                                  ? "ওষুধ ট্র্যাকার"
                                  : "Medicine\nTracker",
                              selected: selectedIndex == 3,
                              onTap: () => _navigate(
                                context,
                                3,
                                _medicationTrackerRoute,
                              ),
                            ),
                          ),

                          Expanded(
                            child: _NavItem(
                              icon: "assets/icons/health_monitor.svg",
                              label: isBangla
                                  ? "স্বাস্থ্য মনিটর"
                                  : "Health\nMonitor",
                              selected: selectedIndex == 4,
                              onTap: () => _navigate(
                                context,
                                4,
                                _healthMonitorRoute,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),

                  ],
                ),
                ),
              ),
            ),

            // ---- Raised circular Diagnosis button --------------------
            Positioned(
              left: 0,
              right: 0,
              bottom: _fabBottomOffset,
              child: Center(
                child: _DiagnosisFab(
                  selected: selectedIndex == 2,
                  label: isBangla ? "রোগনির্ণয়" : "Diagnosis",
                  onTap: () =>
                      _navigate(context, 2, AppRoutes.symptomInput),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, int index, String route) {
    if (selectedIndex == index) return;
    Navigator.pushNamed(context, route);
  }
}

/// Rounded-rect bar outline with a circular notch cut into the top edge,
/// sized and positioned to match the Diagnosis button exactly (with a
/// small transparent gap around it).
class _NotchedBarClipper extends CustomClipper<Path> {
  const _NotchedBarClipper({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchCenterY,
  });

  final double cornerRadius;
  final double notchRadius;
  final double notchCenterY;

  @override
  Path getClip(Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double r = cornerRadius;

    final double halfChord =
        math.sqrt(notchRadius * notchRadius - notchCenterY * notchCenterY);
    final double leftNotchX = cx - halfChord;
    final double rightNotchX = cx + halfChord;

    return Path()
      ..moveTo(r, 0)
      ..lineTo(leftNotchX, 0)
      ..arcToPoint(
        Offset(rightNotchX, 0),
        radius: Radius.circular(notchRadius),
        clockwise: false,
        largeArc: true,
      )
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
      ..lineTo(r, h)
      ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
      ..close();
  }

  @override
  bool shouldReclip(covariant _NotchedBarClipper oldClipper) {
    return oldClipper.cornerRadius != cornerRadius ||
        oldClipper.notchRadius != notchRadius ||
        oldClipper.notchCenterY != notchCenterY;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

@override
Widget build(BuildContext context) {
  return InkWell(
    borderRadius: BorderRadius.circular(20),
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFFF7D4E3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: selected ? 1.1 : 1.0,
            child: SvgPicture.asset(
              icon,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                selected
                    ? DashboardBottomNav.primaryPink
                    : DashboardBottomNav.primaryPink.withValues(alpha: .65),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.gentiumBookPlus(
              fontWeight: selected ? FontWeight.w800 : FontWeight.bold,
              height: 1.1,
              color: selected
                  ? DashboardBottomNav.primaryPink
                  : DashboardBottomNav.primaryPink.withValues(alpha: .65),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.gentiumBookPlus(fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _DiagnosisFab extends StatelessWidget {
  const _DiagnosisFab({
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DashboardBottomNav._fabDiameter,
      height: DashboardBottomNav._fabDiameter,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Material(
          color: selected
              ? const Color(0xFFF7D4E3)
              : const Color(0xFFFFE8F2),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/icons/diagnosis.svg",
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      selected
                          ? DashboardBottomNav.primaryPink
                          : DashboardBottomNav.primaryPink.withValues(alpha: .8),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.gentiumBookPlus(
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5,
                      color: selected
                          ? DashboardBottomNav.primaryPink
                          : DashboardBottomNav.primaryPink.withValues(alpha: .8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}