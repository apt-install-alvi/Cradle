import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';

enum Mood {
  happy,
  sad,
  stressed,
  sick,
}

class MoodCard extends StatefulWidget {
  const MoodCard({super.key});

  @override
  State<MoodCard> createState() => _MoodCardState();
}

class _MoodCardState extends State<MoodCard>
    with TickerProviderStateMixin {

  static const Color primaryPink = Color(0xFFAB0A65);

  static const Duration animationDuration =
      Duration(milliseconds: 350);

  Mood? selectedMood;

  final Map<Mood, String> motivationBn = {
    Mood.happy:
     "আজ আপনি ভালো অনুভব করছেন জেনে আমরা আনন্দিত। হাসিখুশি থাকুন এবং আপনার মাতৃত্বের প্রতিটি মুহূর্ত উপভোগ করুন।",
    Mood.sad:
    "কঠিন দিন আসতেই পারে, এতে দুশ্চিন্তার কিছু নেই। কিছুটা বিশ্রাম নিন, কাছের কারও সঙ্গে কথা বলুন এবং মনে রাখুন—আপনি একা নন।",
    Mood.stressed:
     "ধীরে ধীরে গভীর শ্বাস নিন। কয়েক মিনিটের আরামও আপনার এবং আপনার শিশুর জন্য ইতিবাচক পরিবর্তন আনতে পারে।",
  };

  final Map<Mood, String> motivationEn = {
    Mood.happy:
     "We're glad you're feeling happy today. Keep smiling and enjoy every moment of your pregnancy journey.",
    Mood.sad:
    "It's okay to have difficult days. Take some time to rest, speak with someone you trust, and remember you're not alone.",
    Mood.stressed:
     "Take slow deep breaths. Even a few minutes of relaxation can make a meaningful difference for both you and your baby.",
  };

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final bool isBangla = languageProvider.isBangla;

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),
        child: AnimatedSize(
          duration: animationDuration,
          curve: Curves.easeInOut,
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

                Text(
                  isBangla ? "আজ আপনার কেমন লাগছে?" : "How are you feeling today?",
                  style: GoogleFonts.gentiumBookPlus(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: primaryPink,
                  ),
                ),

                const SizedBox(height: 24),

                AnimatedSwitcher(
                  duration: animationDuration,
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,

                  child: selectedMood == null
                      ? _buildMoodChooser(isBangla)
                      : _buildSelectedMood(isBangla),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodChooser(bool isBangla) {
    return Row(
      key: const ValueKey("chooser"),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: Mood.values.map((mood) {
        return GestureDetector(
          onTap: () {
            if (mood == Mood.sick) {
              Navigator.pushNamed(
                context,
                "/symptom-input",
              );
              return;
            }

            setState(() {
              selectedMood = mood;
            });
          },
          child: Column(
            children: [
              SvgPicture.asset(
                _icon(mood),
                width: 48,
                height: 48,
              ),
              const SizedBox(height: 8),
              Text(
                _label(mood, isBangla),
                style: GoogleFonts.gentiumBookPlus(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: primaryPink,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSelectedMood(bool isBangla) {
    return Row(
      key: ValueKey(selectedMood),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        TweenAnimationBuilder<double>(
          tween: Tween(begin: 30, end: 0),
          duration: animationDuration,
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(-value, 0),
              child: child,
            );
          },
          child: Column(
            children: [

              SvgPicture.asset(
                _icon(selectedMood!),
                width: 48,
                height: 48,
              ),

              const SizedBox(height: 8),

              Text(
                _label(selectedMood!, isBangla),
                style: GoogleFonts.gentiumBookPlus(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: primaryPink,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 18),

        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 500),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(20 * (1 - value), 0),
                  child: child,
                ),
              );
            },
            child: Text(
              isBangla ? motivationBn[selectedMood]! : motivationEn[selectedMood]!,
              style: GoogleFonts.gentiumBookPlus(
                fontWeight: FontWeight.w400,
                fontSize: 16,
                color: primaryPink,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _label(Mood mood, bool isBangla) {
    if (isBangla) {
      switch (mood) {
        case Mood.happy:
          return "খুশি";
        case Mood.sad:
          return "মন খারাপ";
        case Mood.stressed:
          return "চাপগ্রস্ত";
        case Mood.sick:
          return "অসুস্থ";
      }
    } else {
      switch (mood) {
        case Mood.happy:
          return "Happy";
        case Mood.sad:
          return "Sad";
        case Mood.stressed:
          return "Stressed";
        case Mood.sick:
          return "Sick";
      }
    }
  }

  String _icon(Mood mood) {
    switch (mood) {
      case Mood.happy:
        return "assets/icons/happy.svg";
      case Mood.sad:
        return "assets/icons/sad.svg";
      case Mood.stressed:
        return "assets/icons/stressed.svg";
      case Mood.sick:
        return "assets/icons/sick.svg";
    }
  }
}