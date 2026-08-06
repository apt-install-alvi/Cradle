import 'package:flutter/material.dart';
import 'medication.dart';

/// Groups a scheduled dose into one of the three timeline sections shown
/// on the Medication Tracker screen.
enum DosePeriod { morning, afternoon, night }

/// Classifies a [TimeOfDay] into a [DosePeriod].
/// Morning: before 12:00. Afternoon: 12:00-16:59. Night: 17:00 onward.
DosePeriod dosePeriodForTime(TimeOfDay time) {
  if (time.hour < 12) return DosePeriod.morning;
  if (time.hour < 17) return DosePeriod.afternoon;
  return DosePeriod.night;
}

String dosePeriodLabel(DosePeriod period, bool isBangla) {
  switch (period) {
    case DosePeriod.morning:
      return isBangla ? 'সকাল' : 'Morning';
    case DosePeriod.afternoon:
      return isBangla ? 'দুপুর' : 'Afternoon';
    case DosePeriod.night:
      return isBangla ? 'রাত' : 'Night';
  }
}

/// A single instance of a medication's dose scheduled for today.
class ScheduledDose {
  final String id;
  final Medication medication;
  final TimeOfDay time;
  final DosePeriod period;
  bool taken;

  ScheduledDose({
    required this.id,
    required this.medication,
    required this.time,
    required this.period,
    this.taken = false,
  });
}
