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
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;
    final today = DateTime.now();

    final weekDays = List.generate(7, (index) => today.add(Duration(days: index - 3)));
    final progress = (weeksPregnant / totalWeeks).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(10, 18, 10, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .50),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.pink.withValues(alpha: .4)),
            boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: .18), blurRadius: 18, spreadRadius: 2)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //--------------------------------------------------
              // TITLE
              //--------------------------------------------------
              Text(
                isBangla
                    ? "অভিনন্দন! আপনার গর্ভাবস্থার ${toBanglaDigits(weeksPregnant)} সপ্তাহ চলছে!"
                    : "Congratulations! You are $weeksPregnant weeks pregnant!",
                style: GoogleFonts.gentiumBookPlus(fontWeight: FontWeight.bold, fontSize: 20, color: primaryPink),
              ),

              const SizedBox(height: 20),

              //--------------------------------------------------
              // CALENDAR (unchanged)
              //--------------------------------------------------
              LayoutBuilder(
                builder: (context, constraints) {
                  return Row(
                    children: List.generate(weekDays.length, (index) {
                      final day = weekDays[index];
                      final bool isToday = index == 3;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.3),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 66,
                            decoration: BoxDecoration(
                              color: isToday ? primaryPink : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.pink.withAlpha(50)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isBangla ? toBanglaDigits(day.day) : day.day.toString(),
                                  style: GoogleFonts.gentiumBookPlus(fontWeight: FontWeight.bold, fontSize: 20, color: isToday ? Colors.white : primaryPink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isBangla
                                      ? ["সোম", "মঙ্গল", "বুধ", "বৃহ", "শুক্র", "শনি", "রবি"][day.weekday - 1]
                                      : ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][day.weekday - 1],
                                  style: GoogleFonts.gentiumBookPlus(fontWeight: FontWeight.bold, fontSize: 12, color: isToday ? Colors.white : primaryPink),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 24),

              //--------------------------------------------------
              // BABY SIZE PANEL — growth ring + trimester bar
              //--------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 214, 228),
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Text(
                      isBangla ? "আপনার শিশুর আকার এখন প্রায় একটি $childSizeBn-এর সমান" : "Your baby is now about the size of a $childSizeEn",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.gentiumBookPlus(fontWeight: FontWeight.bold, fontSize: 18, color: primaryPink),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: 130,
                      height: 130,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: const Size(130, 130),
                            painter: GrowthRingPainter(progress: progress, trackColor: ringTrack, progressColor: primaryPink),
                          ),
                          Container(
                            width: 90,
                            height: 90,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFFFFF6FA), Color(0xFFFCE3EC)]),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              "assets/icons/placeholder.png",
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.eco, size: 40, color: primaryPink),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Trimester progress bar
                    Row(
                      children: List.generate(3, (index) {
                        final segmentNumber = index + 1;
                        final bool filled = segmentNumber < _trimester;
                        final bool partial = segmentNumber == _trimester;
                        final double fillFraction = partial ? _trimesterFraction().clamp(0.0, 1.0) : (filled ? 1.0 : 0.0);
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: index < 2 ? 6 : 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Stack(
                                children: [
                                  Container(height: 5, color: Colors.white.withValues(alpha: .6)),
                                  FractionallySizedBox(widthFactor: fillFraction, child: Container(height: 5, color: primaryPink)),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isBangla ? '১ম ত্রৈমাসিক' : '1ST TRIMESTER', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: primaryPink, letterSpacing: .3)),
                        Text(isBangla ? '২য় ত্রৈমাসিক' : '2ND TRIMESTER', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: primaryPink, letterSpacing: .3)),
                        Text(isBangla ? '৩য় ত্রৈমাসিক' : '3RD TRIMESTER', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: primaryPink, letterSpacing: .3)),
                      ],
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