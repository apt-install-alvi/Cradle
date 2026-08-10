import 'package:cradle_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/widgets/bottom_nav.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/language_provider.dart';
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

    return Scaffold(
        bottomNavigationBar: const DashboardBottomNav(),
        backgroundColor: Colors.transparent,
        // extendBody: true,

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
                130,
              ),

              child: Column(
                children: [

                  //--------------------------------------------------
                  // SETTINGS BUTTON & LANGUAGE SWITCHER
                  //--------------------------------------------------

                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Language Toggle Switch
                        Padding(padding: EdgeInsetsGeometry.all(25)),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .5),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: primaryPink.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () => context.read<LanguageProvider>().setLanguage(false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !isBangla ? primaryPink : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'English',
                                    style: GoogleFonts.gentiumBookPlus(
                                      color: !isBangla ? Colors.white : primaryPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.read<LanguageProvider>().setLanguage(true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isBangla ? primaryPink : Colors.transparent,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Text(
                                    'বাংলা',
                                    style: TextStyle(
                                      color: isBangla ? Colors.white : primaryPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.white.withValues(alpha: .0),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRoutes.settings);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(0),
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
                  ),

                  const SizedBox(height: 16),

                  //--------------------------------------------------
                  // Greeting
                  //--------------------------------------------------

                  // TODO: wire userName to a profile provider once available
                  const GreetingHeader(userName: "Nusrat"),

                  const SizedBox(height: 18),

                  //--------------------------------------------------
                  // Pregnancy Card
                  //--------------------------------------------------

                  const PregnancyCard(),

                  const SizedBox(height: 20),

                  //--------------------------------------------------
                  // Quick Status Row
                  //--------------------------------------------------

                  // TODO(Nek): replace mock values with real data from
                  // HealthTrackingProvider / medication tracker once wired
                  QuickStatusRow(
                    nextDoseName: "Iron",
                    nextDoseNameBn: "আয়রন",
                    nextDoseTime: "2:00 PM",
                    nextDoseEta: "In 2 hours",
                    nextDoseEtaBn: "২ ঘণ্টার মধ্যে",
                    lastVitalLabel: "BP 118/76",
                    lastVitalLabelBn: "BP ১১৮/৭৬",
                    lastVitalSub: "Logged today",
                    lastVitalSubBn: "আজ লগ করা হয়েছে",
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
          bottom: 30, // Sits just above the bottom navigation bar
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