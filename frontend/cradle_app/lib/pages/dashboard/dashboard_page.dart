import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/widgets/bottom_nav.dart';
import './widgets/mood_card.dart';
import './widgets/pregnancy_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color topGradient = Color(0xFFFFCAE1);
  static const Color bottomGradient = Color(0xFFFFE8F2);
 ///alvi
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: DashboardBottomNav(),
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
                // SETTINGS BUTTON
                //--------------------------------------------------

                Align(
                  alignment: Alignment.topRight,
                  child: Material(
                    color: Colors.white.withValues(alpha: .35),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // TODO: Navigate to settings
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