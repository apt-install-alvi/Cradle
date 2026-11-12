import 'vital_log.dart';

/// Mutable state for one vital: whether it's being tracked, its reminder
/// schedule, and its log history. Lives inside HealthTrackingProvider.
class VitalTrackingState {
  bool tracking;
  int freq;

  /// "HH:mm" 24-hour strings, one per reminder.
  List<String> times;

  /// Sunday-first, length 7.
  List<bool> days;

  List<VitalLog> logs;

  VitalTrackingState({
    this.tracking = false,
    this.freq = 1,
    List<String>? times,
    List<bool>? days,
    List<VitalLog>? logs,
  })  : times = times ?? ['08:00'],
        days = days ?? List<bool>.filled(7, true),
        logs = logs ?? [];
}
