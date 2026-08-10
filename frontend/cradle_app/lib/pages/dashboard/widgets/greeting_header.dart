import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cradle_app/core/utils/bangla_numerals.dart';
import '../../../providers/language_provider.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.userName});

  final String userName;

  static const List<String> _weekdaysEn = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];
  static const List<String> _weekdaysBn = [
    'সোমবার', 'মঙ্গলবার', 'বুধবার', 'বৃহস্পতিবার', 'শুক্রবার', 'শনিবার', 'রবিবার',
  ];
  static const List<String> _monthsEn = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  static const List<String> _monthsBn = [
    'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল', 'মে', 'জুন',
    'জুলাই', 'আগস্ট', 'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
  ];

  String _greetingWord(bool isBangla, int hour) {
    if (isBangla) {
      if (hour < 12) return 'শুভ সকাল';
      if (hour < 17) return 'শুভ অপরাহ্ন';
      return 'শুভ সন্ধ্যা';
    }
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formattedDate(bool isBangla, DateTime now) {
    final weekday = isBangla ? _weekdaysBn[now.weekday - 1] : _weekdaysEn[now.weekday - 1];
    final month = isBangla ? _monthsBn[now.month - 1] : _monthsEn[now.month - 1];
    final day = isBangla ? toBanglaDigits(now.day) : '${now.day}';
    return isBangla ? '$weekday, $day $month' : '$weekday, $month $day';
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${_greetingWord(isBangla, now.hour)}, $userName',
          style: GoogleFonts.gentiumBookPlus(
            fontWeight: FontWeight.w700,
            fontSize: 21,
            color: const Color(0xFF4A2F3A),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formattedDate(isBangla, now),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF8A7680)),
        ),
      ],
    );
  }
}