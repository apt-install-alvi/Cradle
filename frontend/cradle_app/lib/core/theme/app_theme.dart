import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData.light();
  static ThemeData get darkTheme => ThemeData.dark();
}
/// Central design tokens for the Maternal Symptom Checker app.
/// Mirrors the pink/rose visual language used across all three screens.
/// Requires the `google_fonts` package (add `google_fonts: ^6.1.0` to
/// pubspec.yaml) to render the Gentium Book Plus display font.
class AppColors {
  AppColors._();

  static const pinkTop = Color(0xFFFFD9E4);
  static const pinkMid = Color(0xFFFFEEF3);
  static const pinkBottom = Color(0xFFFFFDFE);

  static const ink = Color(0xFF3A2C33);
  static const muted = Color(0xFF8A7680);

  static const rose = Color(0xFFE85D84);
  static const roseDark = Color(0xFFC8446A);

  // Risk-level colors: green / yellowish-orange / red.
  static const low = Color(0xFF3FA66B);
  static const lowBg = Color(0xFFE6F6EC);

  static const medium = Color(0xFFE8960F);
  static const mediumBg = Color(0xFFFDF0D8);

  static const high = Color(0xFFD64545);
  static const highBg = Color(0xFFFBE4E4);

  static const cardShadow = Color(0x29C87896);
}

class AppGradients {
  AppGradients._();

  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.pinkTop, AppColors.pinkMid, AppColors.pinkBottom],
    stops: [0.0, 0.45, 1.0],
  );

  static const roseButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.rose, AppColors.roseDark],
  );

  static const ambulanceButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE14B4B), Color(0xFFC22F2F)],
  );
}

class AppText {
  AppText._();

  static TextStyle headerTitle = GoogleFonts.gentiumBookPlus(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF4A2F3A),
    height: 1.25,
  );

  static TextStyle sectionHeading = GoogleFonts.gentiumBookPlus(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF4A2F3A),
  );

  static TextStyle diagnosisTitle = GoogleFonts.gentiumBookPlus(
    fontSize: 23,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF4A2F3A),
    height: 1.3,
  );

  static TextStyle historyTitle = GoogleFonts.gentiumBookPlus(
    fontSize: 16.5,
    fontWeight: FontWeight.w700,
    color: const Color(0xFF4A2F3A),
  );

  static const cardLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: Color(0xFF4A3540),
  );

  static const subtext = TextStyle(
    fontSize: 13,
    color: AppColors.muted,
  );

  static const eyebrow = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.0,
    color: AppColors.muted,
  );
}

class AppRadii {
  AppRadii._();
  static const card = 18.0;
  static const largeCard = 22.0;
  static const button = 16.0;
}

List<BoxShadow> get appCardShadow => const [
      BoxShadow(
        color: AppColors.cardShadow,
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ];

