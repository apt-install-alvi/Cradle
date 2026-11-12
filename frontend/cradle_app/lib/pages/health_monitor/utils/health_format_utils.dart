import 'package:flutter/material.dart';
import '../../../core/utils/bangla_numerals.dart';

/// Formats a TimeOfDay-like "HH:mm" 24h string as e.g. "8:00 AM".
String fmtTime12h(String hhmm, {bool isBangla = false}) {
  final parts = hhmm.split(':');
  int h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0;
  final suffixEn = h >= 12 ? 'PM' : 'AM';
  final suffixBn = h >= 12 ? 'PM' : 'AM';
  int h12 = h % 12;
  if (h12 == 0) h12 = 12;
  final mm = m.toString().padLeft(2, '0');
  final text = '$h12:$mm ${isBangla ? suffixBn : suffixEn}';
  return isBangla ? toBanglaDigits(text) : text;
}

TimeOfDay parseHHmm(String hhmm) {
  final parts = hhmm.split(':');
  return TimeOfDay(
    hour: int.tryParse(parts[0]) ?? 8,
    minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
  );
}

String timeOfDayToHHmm(TimeOfDay t) {
  return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}

/// "dd/mm" — digits swapped to Bangla numerals when isBangla.
String fmtDDMM(DateTime d, {bool isBangla = false}) {
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  final text = '$dd/$mm';
  return isBangla ? toBanglaDigits(text) : text;
}

/// "Today, 8:00 AM" / "Yesterday, 8:00 AM" / "05/08, 8:00 AM"
String fmtDateShort(DateTime d, {bool isBangla = false}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final cmp = DateTime(d.year, d.month, d.day);
  final diffDays = today.difference(cmp).inDays;
  final hhmm = '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  final time = fmtTime12h(hhmm, isBangla: isBangla);

  if (diffDays == 0) return '${isBangla ? "আজ" : "Today"}, $time';
  if (diffDays == 1) return '${isBangla ? "গতকাল" : "Yesterday"}, $time';
  return '${fmtDDMM(d, isBangla: isBangla)}, $time';
}

const Map<String, String> _glucoseContextBn = {
  'Fasting': 'উপবাসে',
  'Before meal': 'খাবারের আগে',
  'After meal': 'খাবারের পরে',
  'Random': 'যেকোনো সময়',
};

/// Translates a canonical English glucose-context string for display.
String localizedGlucoseContext(String canonicalEn, bool isBangla) {
  if (!isBangla) return canonicalEn;
  return _glucoseContextBn[canonicalEn] ?? canonicalEn;
}

String localizedNumber(num value, bool isBangla) {
  return isBangla ? toBanglaDigits(value) : value.toString();
}
