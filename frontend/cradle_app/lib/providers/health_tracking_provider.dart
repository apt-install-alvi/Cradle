import 'dart:math';
import 'package:flutter/material.dart';
import '../pages/health_monitor/models/vital_definition.dart';
import '../pages/health_monitor/models/vital_log.dart';
import '../pages/health_monitor/models/vital_tracking_state.dart';

class HealthTrackingProvider extends ChangeNotifier {
  final Map<String, VitalTrackingState> _states = {
    'bp': VitalTrackingState(freq: 1, times: ['08:00']),
    'temp': VitalTrackingState(freq: 1, times: ['09:00']),
    'glucose': VitalTrackingState(freq: 2, times: ['08:00', '19:00']),
    'spo2': VitalTrackingState(freq: 1, times: ['08:00']),
    'hr': VitalTrackingState(freq: 1, times: ['08:00']),
  };

  static const List<String> _defaultTimeSlots = [
    '08:00',
    '13:00',
    '19:00',
    '21:00',
    '10:00',
    '16:00',
  ];

  /// Key of the vital card whose inline schedule config is expanded on the
  /// main screen (only one at a time), or null if none.
  String? expandedKey;

  VitalTrackingState state(String key) => _states[key]!;

  List<String> get orderedKeys => kVitalDefinitions.keys.toList();

  void toggleExpand(String key) {
    expandedKey = expandedKey == key ? null : key;
    notifyListeners();
  }

  void collapseExpand() {
    expandedKey = null;
    notifyListeners();
  }

  void changeFreq(String key, int delta) {
    final s = state(key);
    s.freq = max(1, min(6, s.freq + delta));
    _reconcileTimes(s);
    notifyListeners();
  }

  void _reconcileTimes(VitalTrackingState s) {
    while (s.times.length < s.freq) {
      final fallback = s.times.length < _defaultTimeSlots.length
          ? _defaultTimeSlots[s.times.length]
          : '08:00';
      s.times.add(fallback);
    }
    if (s.times.length > s.freq) {
      s.times = s.times.sublist(0, s.freq);
    }
  }

  void updateTime(String key, int index, String hhmm) {
    state(key).times[index] = hhmm;
    notifyListeners();
  }

  void toggleDay(String key, int index) {
    final s = state(key);
    s.days[index] = !s.days[index];
    notifyListeners();
  }

  /// Generates 6 days of plausible mock history ending yesterday, matching
  /// the HTML prototype's generateMockHistory(). Placeholder until real
  /// persistence/backend data is wired up.
  List<VitalLog> _generateMockHistory(String key) {
    final def = kVitalDefinitions[key]!;
    final s = state(key);
    final rnd = Random();
    final logs = <VitalLog>[];
    final timeParts = (s.times.isNotEmpty ? s.times[0] : '08:00').split(':');
    final hh = int.tryParse(timeParts[0]) ?? 8;
    final mm = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;

    for (int i = 6; i >= 1; i--) {
      final now = DateTime.now();
      final d = DateTime(now.year, now.month, now.day - i, hh, mm);
      if (def.type == VitalType.bp) {
        logs.add(VitalLog(
          id: _genId(rnd),
          date: d,
          systolic: def.sysMin! + rnd.nextInt(def.sysMax! - def.sysMin! + 1),
          diastolic: def.diaMin! + rnd.nextInt(def.diaMax! - def.diaMin! + 1),
        ));
      } else {
        final raw = def.min! + rnd.nextDouble() * (def.max! - def.min!);
        final value = double.parse(raw.toStringAsFixed(def.decimals));
        logs.add(VitalLog(
          id: _genId(rnd),
          date: d,
          value: value,
          context: def.hasContext
              ? kGlucoseContexts[rnd.nextInt(kGlucoseContexts.length)]
              : null,
        ));
      }
    }
    return logs;
  }

String _genId(Random rnd) =>
    'log_${DateTime.now().microsecondsSinceEpoch}_${rnd.nextInt(1 << 31).toRadixString(36)}';

  /// Saves the very first reading for a vital, turning tracking on and
  /// backfilling mock history (matches saveLogEntry() initial-mode in JS).
  void addInitialLog(String key, VitalLog log) {
    final s = state(key);
    s.logs = [..._generateMockHistory(key), log];
    s.tracking = true;
    expandedKey = null;
    notifyListeners();
  }

  void updateLog(String key, String logId, VitalLog updated) {
    final s = state(key);
    final idx = s.logs.indexWhere((l) => l.id == logId);
    if (idx != -1) s.logs[idx] = updated;
    notifyListeners();
  }

  void deleteLog(String key, String logId) {
    final s = state(key);
    s.logs.removeWhere((l) => l.id == logId);
    notifyListeners();
  }

  void stopTracking(String key) {
    state(key).tracking = false;
    notifyListeners();
  }
}
