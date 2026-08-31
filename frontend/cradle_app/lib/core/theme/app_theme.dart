import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData.light().copyWith(
    primaryColor: const Color(0xFFAB0A65),
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: GoogleFonts.gentiumBookPlusTextTheme(ThemeData.light().textTheme),
  );
  static ThemeData get darkTheme => ThemeData.dark().copyWith(
    primaryColor: const Color(0xFFAB0A65),
    textTheme: GoogleFonts.gentiumBookPlusTextTheme(ThemeData.dark().textTheme),
  );
}

/// Central design tokens for the Maternal Symptom Checker app.
class AppColors {
  AppColors._();

  static const pinkTop = Color(0xFFFFCAE1);
  static const pinkBottom = Color(0xFFFFE8F2);

  // Accent colour + text colour (jekhane background light)
  static const rose = Color(0xFFAB0A65);
  static const roseDark = Color(0xFFAB0A65);

  // Primary colour - FFFFFF 52% opacity
  static final primary = Colors.white.withOpacity(0.52);

  // Secondary colour + text colour (jekhane bg dark)
  static const secondary = Colors.white;

  static const ink = Color(0xFFAB0A65); // Accent colour for light bg text
  static const muted = Color(0xFF8A5A72);

  // Risk-level colors
  static const low = Color(0xFF2C8A4E);
  static const lowBg = Color(0xFFE2F4E9);

  static const medium = Color(0xFFC47B0B);
  static const mediumBg = Color(0xFFFDF0D8);

  static const high = Color(0xFFAB0A65);
  static const highBg = Color(0xFFFBE4E4);

  static const cardShadow = Color(0x15AB0A65);
}

class AppGradients {
  AppGradients._();

  // Vertical linear gradient (lomba-lombi khara)
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.pinkTop, AppColors.pinkBottom],
  );

  static const roseButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFAB0A65), Color(0xFF900853)],
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
    fontWeight: FontWeight.w800,
    color: const Color(0xFFAB0A65),
    height: 1.25,
  );

  static TextStyle sectionHeading = GoogleFonts.gentiumBookPlus(
    fontSize: 19,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFAB0A65),
  );

  static TextStyle diagnosisTitle = GoogleFonts.gentiumBookPlus(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFAB0A65),
    height: 1.3,
  );

  static TextStyle historyTitle = GoogleFonts.gentiumBookPlus(
    fontSize: 17.5,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFAB0A65),
  );

  static TextStyle cardLabel = GoogleFonts.gentiumBookPlus(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: const Color(0xFFAB0A65),
  );

  static TextStyle subtext = GoogleFonts.gentiumBookPlus(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: AppColors.muted,
  );

  static TextStyle eyebrow = GoogleFonts.gentiumBookPlus(
    fontSize: 11.5,
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
