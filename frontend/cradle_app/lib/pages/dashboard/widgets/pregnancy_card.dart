import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cradle_app/core/utils/bangla_numerals.dart';
import '../../../providers/language_provider.dart';
import 'growth_ring_painter.dart';

class PregnancyCard extends StatelessWidget {
  const PregnancyCard({super.key});

  final int weeksPregnant = 7;
  final int totalWeeks = 40;

  final String childSizeBn = "আঙুর";
  final String childSizeEn = "grape";

  static const Color primaryPink = Color(0xFFAB0A65);
  static const Color ringTrack = Color(0xFFFCE3EC);

  int get _trimester {
    if (weeksPregnant <= 13) return 1;
    if (weeksPregnant <= 27) return 2;
    return 3;
  }

  double _trimesterFraction() {
    switch (_trimester) {
      case 1:
        return weeksPregnant / 13;
      case 2:
        return (weeksPregnant - 13) / 14;
      default:
        return (weeksPregnant - 27) / 13;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    final progress = (weeksPregnant / totalWeeks).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            18,
            28,
            18,
            18,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.pink.withValues(alpha: .4),
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
            children: [
              //--------------------------------------------------
              // CONGRATULATIONS
              //--------------------------------------------------

              Text(
                isBangla ? "অভিনন্দন" : "CONGRATULATIONS",
                textAlign: TextAlign.center,
                style: GoogleFonts.gentiumBookPlus(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: primaryPink,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 6),

              //--------------------------------------------------
              // WEEKS PREGNANT
              //--------------------------------------------------

              Text(
                isBangla
                    ? "আপনার গর্ভাবস্থার ${toBanglaDigits(weeksPregnant)} সপ্তাহ চলছে!"
                    : "You're $weeksPregnant weeks pregnant!",
                textAlign: TextAlign.center,
                style: GoogleFonts.gentiumBookPlus(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: const Color(0xFF4A2F3A),
                ),
              ),

              const SizedBox(height: 18),

              //--------------------------------------------------
              // GROWTH RING
              //--------------------------------------------------

              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(150, 150),
                      painter: GrowthRingPainter(
                        progress: progress,
                        trackColor: ringTrack,
                        progressColor: primaryPink,
                      ),
                    ),

                    Container(
                      width: 102,
                      height: 102,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          center: Alignment(-0.3, -0.4),
                          colors: [
                            Color(0xFFFFF6FA),
                            Color(0xFFFCE3EC),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Image.asset(
                        "assets/images/grape.png",
                        fit: BoxFit.contain,
                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          return const Icon(
                            Icons.eco,
                            size: 40,
                            color: primaryPink,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              //--------------------------------------------------
              // BABY SIZE
              //--------------------------------------------------

              if (isBangla)
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.gentiumBookPlus(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3A2C33),
                    ),
                    children: [
                      const TextSpan(
                        text: "আপনার শিশুর আকার এখন প্রায় একটি\n",
                      ),
                      TextSpan(
                        text: childSizeBn,
                        style: const TextStyle(
                          color: primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: "-এর সমান",
                      ),
                    ],
                  ),
                )
              else
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.gentiumBookPlus(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3A2C33),
                    ),
                    children: [
                      const TextSpan(
                        text: "Your baby is now the size of a\n",
                      ),
                      TextSpan(
                        text: childSizeEn,
                        style: const TextStyle(
                          color: primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 28),

              //--------------------------------------------------
              // TRIMESTER PROGRESS BAR
              //--------------------------------------------------

              Row(
                children: List.generate(
                  3,
                  (index) {
                    final segmentNumber = index + 1;

                    final bool filled =
                        segmentNumber < _trimester;

                    final bool partial =
                        segmentNumber == _trimester;

                    final double fillFraction = partial
                        ? _trimesterFraction().clamp(0.0, 1.0)
                        : (filled ? 1.0 : 0.0);

                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index < 2 ? 6 : 0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Stack(
                            children: [
                              Container(
                                height: 7,
                                color: const Color(0xFFEFD9E4),
                              ),
                              FractionallySizedBox(
                                widthFactor: fillFraction,
                                child: Container(
                                  height: 7,
                                  color: primaryPink,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 10),

              //--------------------------------------------------
              // TRIMESTER LABELS
              //--------------------------------------------------

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBangla ? '১ম ত্রৈমাসিক' : '1ST TRIMESTER',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A7680),
                      letterSpacing: .2,
                    ),
                  ),
                  Text(
                    isBangla ? '২য় ত্রৈমাসিক' : '2ND TRIMESTER',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A7680),
                      letterSpacing: .2,
                    ),
                  ),
                  Text(
                    isBangla ? '৩য় ত্রৈমাসিক' : '3RD TRIMESTER',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A7680),
                      letterSpacing: .2,
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
}

class PregnancyCalendar extends StatelessWidget {
  const PregnancyCalendar({super.key});

  static const Color primaryPink = Color(0xFFAB0A65);

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final today = DateTime.now();

    // Keep the same behavior as the old version:
    // 3 days before today → today → 3 days after today.
    final weekDays = List.generate(
      7,
      (index) => today.add(Duration(days: index - 3)),
    );

    const weekdaysEn = [
      "Mon",
      "Tue",
      "Wed",
      "Thu",
      "Fri",
      "Sat",
      "Sun",
    ];

    const weekdaysBn = [
      "সোম",
      "মঙ্গল",
      "বুধ",
      "বৃহ",
      "শুক্র",
      "শনি",
      "রবি",
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        10,
        14,
        10,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.pink.withValues(alpha: .4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: .18),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: List.generate(
              weekDays.length,
              (index) {
                final day = weekDays[index];
                final bool isToday = index == 3;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 1.3,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 76,
                      decoration: BoxDecoration(
                        color: isToday
                            ? primaryPink
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        // border: Border.all(
                        //   color: Colors.pink.withValues(alpha: .20),
                        // ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Weekday
                          Text(
                            isBangla
                                ? weekdaysBn[day.weekday - 1]
                                : weekdaysEn[day.weekday - 1],
                            style: GoogleFonts.gentiumBookPlus(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isToday
                                  ? Colors.white
                                  : const Color(0xFF8A7680),
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Date
                          Text(
                            isBangla
                                ? toBanglaDigits(day.day)
                                : day.day.toString(),
                            style: GoogleFonts.gentiumBookPlus(
                              fontWeight: FontWeight.bold,
                              fontSize: 21,
                              color: isToday
                                  ? Colors.white
                                  : const Color(0xFF3A2C33),
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
    );
  }
}