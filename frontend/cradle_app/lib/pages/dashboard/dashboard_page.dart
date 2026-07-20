import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/routes/app_routes.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import './widgets/mood_card.dart';
import './widgets/pregnancy_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color topGradient = Color(0xFFFFCAE1);
  static const Color bottomGradient = Color(0xFFFFE8F2);
  static const Color primaryPink = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    return Scaffold(
      bottomNavigationBar: const DashboardBottomNav(),
      backgroundColor: Colors.transparent,
      extendBody: true,

      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              topGradient,
              bottomGradient,
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              22,
              10,
              22,
              20,
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
                      const SizedBox(width: 12),
                      Material(
                        color: Colors.white.withValues(alpha: .35),
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRoutes.settings);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              "assets/icons/settings.svg",
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                //--------------------------------------------------
                // Pregnancy Card
                //--------------------------------------------------

                const PregnancyCard(),

                const SizedBox(height: 28),

                //--------------------------------------------------
                // Mood Card
                //--------------------------------------------------

                const MoodCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}