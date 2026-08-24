import 'package:cradle_app/core/routes/app_routes.dart';
import 'package:cradle_app/core/utils/bangla_numerals.dart';
import 'package:cradle_app/pages/health_monitor/models/vital_definition.dart';
import 'package:cradle_app/providers/health_tracking_provider.dart';
import 'package:cradle_app/providers/medication_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/language_toggle.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../medication_tracker/models/scheduled_dose.dart';
import './widgets/mood_card.dart';
import './widgets/pregnancy_card.dart';
import 'package:url_launcher/url_launcher.dart';
import './widgets/greeting_header.dart';
import './widgets/quick_status_row.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color primaryPink = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;
    final authProvider = context.watch<AuthProvider>();
    final medicationProvider = context.watch<MedicationProvider?>();
    final healthProvider = context.watch<HealthTrackingProvider>();

    // Calculate next dose for QuickStatusRow
    ScheduledDose? nextDose;
    if (medicationProvider != null && medicationProvider.todayDoses.isNotEmpty) {
      final now = TimeOfDay.now();
      final nowMinutes = now.hour * 60 + now.minute;

      try {
        nextDose = medicationProvider.todayDoses.firstWhere(
          (d) => !d.taken && (d.time.hour * 60 + d.time.minute) > nowMinutes
        );
      } catch (_) {
        // If all doses taken or none after current time, show first untaken or first
        try {
          nextDose = medicationProvider.todayDoses.firstWhere((d) => !d.taken);
        } catch (_) {
          nextDose = medicationProvider.todayDoses.first;
        }
      }
    }

    // Health monitor latest reading
    final latestLog = healthProvider.latestAnyVitalLog;
    String lastVitalLabel = "None";
    String lastVitalLabelBn = "কোনোটি নেই";
    String lastVitalSub = "--";
    String lastVitalSubBn = "--";

    if (latestLog != null) {
      final key = healthProvider.getLatestVitalKey(latestLog);
      final def = key != null ? kVitalDefinitions[key] : null;
      if (def != null) {
        lastVitalLabel = def.type == VitalType.bp
          ? "BP ${latestLog.systolic}/${latestLog.diastolic}"
          : "${def.nameEn} ${latestLog.value}";

        lastVitalLabelBn = def.type == VitalType.bp
          ? "BP ${toBanglaDigits(latestLog.systolic!)}/${toBanglaDigits(latestLog.diastolic!)}"
          : "${def.nameBn} ${toBanglaDigits(latestLog.value!)}";

        final bool isToday = latestLog.date.day == DateTime.now().day &&
            latestLog.date.month == DateTime.now().month &&
            latestLog.date.year == DateTime.now().year;

        lastVitalSub = isToday ? "Logged today" : "Last: ${latestLog.date.day}/${latestLog.date.month}";
        lastVitalSubBn = isToday ? "আজ লগ করা হয়েছে" : "সর্বশেষ: ${toBanglaDigits(latestLog.date.day)}/${toBanglaDigits(latestLog.date.month)}";
      }
    }

    return Scaffold(
        bottomNavigationBar: const DashboardBottomNav(),
        backgroundColor: Colors.transparent,
        extendBody: true,

      body: Stack(
        children: [
          Container(
          width: double.infinity,

          decoration: const BoxDecoration(
            gradient: AppGradients.background,
          ),

          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                22,
                10,
                22,
                180,
              ),

              child: Column(
                children: [

                  //--------------------------------------------------
                  // SETTINGS, NOTIFS BUTTON & LANGUAGE SWITCHER
                  //--------------------------------------------------
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ------------------------------------------------
                    // LANGUAGE TOGGLE — LEFT
                    // ------------------------------------------------
                    const LanguageToggle(),

                    // ------------------------------------------------
                    // RIGHT-SIDE BUTTONS
                    // ------------------------------------------------
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Notifications
                        Material(
                          color: Colors.white.withValues(alpha: .0),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.notifications);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                "assets/icons/notifications.svg",
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Settings
                        Material(
                          color: Colors.white.withValues(alpha: .0),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                AppRoutes.settings,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: SvgPicture.asset(
                                "assets/icons/settings.svg",
                                width: 24,
                                height: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                  const SizedBox(height: 16),

                  //--------------------------------------------------
                  // Greeting
                  //--------------------------------------------------

                  Align(
                    alignment: Alignment.centerLeft,
                    child: GreetingHeader(
                      userName: authProvider.userName.isNotEmpty ? authProvider.userName : (isBangla ? "মা" : "Mother"),
                    ),
                  ),

                  const SizedBox(height: 16),

                  //--------------------------------------------------
                  // WEEK CALENDAR
                  //--------------------------------------------------

                  const PregnancyCalendar(),

                  const SizedBox(height: 20),

                  //--------------------------------------------------
                  // PREGNANCY CARD
                  //--------------------------------------------------

                  const PregnancyCard(),

                  const SizedBox(height: 20),

                  //--------------------------------------------------
                  // Quick Status Row
                  //--------------------------------------------------

                  QuickStatusRow(
                    nextDoseName: nextDose?.medication.name ?? (isBangla ? "কোনোটি নেই" : "None"),
                    nextDoseNameBn: nextDose?.medication.name ?? "কোনোটি নেই",
                    nextDoseTime: nextDose?.time.format(context) ?? "--:--",
                    nextDoseEta: nextDose != null ? (isBangla ? "পরবর্তী ডোজ" : "Next dose") : (isBangla ? "সব শেষ" : "All set"),
                    nextDoseEtaBn: nextDose != null ? "পরবর্তী ডোজ" : "সব শেষ",
                    lastVitalLabel: lastVitalLabel,
                    lastVitalLabelBn: lastVitalLabelBn,
                    lastVitalSub: lastVitalSub,
                    lastVitalSubBn: lastVitalSubBn,
                    onMedicineTap: () => Navigator.pushNamed(context, AppRoutes.medicationTracker),
                    onHealthTap: () => Navigator.pushNamed(context, AppRoutes.healthMonitor),
                  ),

                  const SizedBox(height: 20),

                  //--------------------------------------------------
                  // Mood Card
                  //--------------------------------------------------

                  const MoodCard(),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          right: 4,
          bottom: 155, // Sits above the bottom navigation bar
          // child: SafeArea(
            child: Material(
              elevation: 8,
              color: primaryPink,
              shadowColor: primaryPink.withValues(alpha: .4),
              borderRadius: BorderRadius.circular(50),
              child: InkWell(
                borderRadius: BorderRadius.circular(50),
                onTap: () {
                  final Uri phone = Uri(
                    scheme: 'tel',
                    path: '999',
                  );

                  launchUrl(phone);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: primaryPink,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .15),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/icons/ambulance.png",
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 10),

                      // Flexible(
                        // child: Consumer<LanguageProvider>(
                          Consumer<LanguageProvider>(
                          builder: (_, languageProvider, _) {
                            return Text(
                              languageProvider.isBangla
                                  ? "জরুরি অ্যাম্বুলেন্স সেবা(৯৯৯)"
                                  : "Emergency Ambulance Service(999)",
                              style: GoogleFonts.gentiumBookPlus(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // ),
      ], 
    ));
  }
}
