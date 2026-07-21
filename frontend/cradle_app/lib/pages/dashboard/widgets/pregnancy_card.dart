import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cradle_app/core/utils/bangla_numerals.dart';
import '../../../providers/language_provider.dart';

class PregnancyCard extends StatelessWidget {
  const PregnancyCard({super.key});

  final int weeksPregnant = 7;
  final String childSizeBn = "আঙুর";
  final String childSizeEn = "grape";

  static const Color primaryPink = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;
    final today = DateTime.now();

    final weekDays = List.generate(
      7,
      (index) => today.add(
        Duration(days: index - 3),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .50),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withValues(alpha: .4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: .18),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //--------------------------------------------------
              // TITLE
              //--------------------------------------------------

              Text(
                isBangla
                    ? "অভিনন্দন! আপনার গর্ভাবস্থার ${toBanglaDigits(weeksPregnant)} সপ্তাহ চলছে।"
                    : "Congratulations! You are $weeksPregnant weeks pregnant.",
                style: GoogleFonts.gentiumBookPlus(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: primaryPink,
                ),
              ),

              const SizedBox(height: 20),

              //--------------------------------------------------
              // CALENDAR
              //--------------------------------------------------

              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: List.generate(
                      weekDays.length,
                      (index) {
                        final day = weekDays[index];
                        final bool isToday = index == 3;

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),

                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 66,

                              decoration: BoxDecoration(
                                color: isToday
                                    ? primaryPink
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: isToday
                                    ? [
                                        BoxShadow(
                                          color: primaryPink.withValues(alpha: .25),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : [],
                              ),

                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  Text(
                                    isBangla ? toBanglaDigits(day.day) : day.day.toString(),
                                    style: GoogleFonts.gentiumBookPlus(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: isToday
                                          ? Colors.white
                                          : primaryPink,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    isBangla
                                        ? [
                                            "সোম",
                                            "মঙ্গল",
                                            "বুধ",
                                            "বৃহ",
                                            "শুক্র",
                                            "শনি",
                                            "রবি",
                                          ][day.weekday - 1]
                                        : [
                                            "Mon",
                                            "Tue",
                                            "Wed",
                                            "Thu",
                                            "Fri",
                                            "Sat",
                                            "Sun",
                                          ][day.weekday - 1],
                                    style: GoogleFonts.gentiumBookPlus(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isToday
                                          ? Colors.white
                                          : primaryPink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              //--------------------------------------------------
              // BABY SIZE PANEL
              //--------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(
                    Radius.circular(28),
                  ),
                  gradient: RadialGradient(
                    center: Alignment(0.05, -.2),
                    radius: 1.75,
                    colors: [
                      Color(0xFFFFD0D3),
                      Color(0xFFEB88FF),
                    ],
                  ),
                ),
                child: Column(
                  children: [

                    Text(
                      isBangla
                          ? "আপনার শিশুর আকার এখন প্রায় একটি $childSizeBn-এর সমান"
                          : "Your baby is now about the size of a $childSizeEn",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gentiumBookPlus(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: primaryPink,
                      ),
                    ),

                    const SizedBox(height: 28),

                    SizedBox(
                      height: 80,
                      child: Image.asset(
                        "assets/images/grape.png",
                        fit: BoxFit.contain,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return const Icon(
                            Icons.eco,
                            size: 90,
                            color: Colors.orange,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}