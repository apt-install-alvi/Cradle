import 'dart:math';
import 'package:flutter/material.dart';
import '../core/services/api_service.dart';
import '../pages/health_monitor/models/vital_definition.dart';
import '../pages/health_monitor/models/vital_log.dart';
import '../pages/health_monitor/models/vital_tracking_state.dart';

class MissedVitalReading {
  final String key;
  final String scheduledTime;

  const MissedVitalReading({
    required this.key,
    required this.scheduledTime,
  });
}

class HealthTrackingProvider extends ChangeNotifier {
  final String? token;

  final Map<String, VitalTrackingState> _states = {
    'bp': VitalTrackingState(freq: 1, times: ['08:00']),
    'temp': VitalTrackingState(freq: 1, times: ['09:00']),
    'glucose': VitalTrackingState(freq: 2, times: ['08:00', '19:00']),
    'spo2': VitalTrackingState(freq: 1, times: ['08:00']),
    'hr': VitalTrackingState(freq: 1, times: ['08:00']),
  };

  VitalLog? get latestAnyVitalLog {
    VitalLog? latest;
    for (var s in _states.values) {
      if (s.logs.isNotEmpty) {
        final last = s.logs.last;
        if (latest == null || last.date.isAfter(latest.date)) {
          latest = last;
        }
      }
    }
    return latest;
  }

  String? getLatestVitalKey(VitalLog log) {
    for (var entry in _states.entries) {
      if (entry.value.logs.contains(log)) return entry.key;
    }
    return null;
  }

  HealthTrackingProvider(this.token) {
    if (token != null) {
      _fetchAllVitals();
      _fetchSettings();
    }
  }

  Future<void> _fetchSettings() async {
    try {
      final response = await ApiService.get('/vitals/settings', token: token);
      final List data = response['data'] ?? [];
      for (var item in data) {
        final key = item['vital_key'];
        if (_states.containsKey(key)) {
          final s = _states[key]!;
          s.freq = item['frequency'] ?? 1;
          s.times = List<String>.from(item['times'] ?? []);
          s.days = List<bool>.from(item['days'] ?? [true, true, true, true, true, true, true]);
          s.tracking = item['is_tracking'] ?? false;
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching vital settings: $e');
    }
  }

  Future<void> _saveSettings(String key) async {
    if (token == null) {
      debugPrint('[HealthTrackingProvider] Cannot save settings for $key: token is null');
      return;
    }
    try {
      final s = _states[key]!;
      debugPrint('[HealthTrackingProvider] Saving settings for $key: freq=${s.freq}, tracking=${s.tracking}');

      final response = await ApiService.post('/vitals/settings', {
        'vitalKey': key,
        'settings': {
          'frequency': s.freq,
          'times': s.times,
          'days': s.days,
          'isTracking': s.tracking,
        }
      }, token: token);

      debugPrint('[HealthTrackingProvider] Settings saved successfully for $key: ${response['message']}');
    } catch (e) {
      debugPrint('[HealthTrackingProvider] Error saving vital settings for $key: $e');
    }
  }

  Future<void> _fetchAllVitals() async {
    for (var key in _states.keys) {
      await fetchVitals(key);
    }
  }

  Future<void> fetchVitals(String key) async {
    if (token == null) return;
    try {
      final response = await ApiService.get('/vitals?type=$key', token: token);
      final List data = response['data'] ?? [];
      final logs = data.map((json) => VitalLog(
        id: json['id'].toString(),
        date: DateTime.parse(json['logged_at']),
        value: json['value']?.toDouble(),
        systolic: json['systolic'],
        diastolic: json['diastolic'],
        context: json['context'],
        note: json['note'] ?? '',
      )).toList();

      final s = _states[key]!;
      s.logs = logs;

      // If we have logs but it's not tracking, we sync it
      if (logs.isNotEmpty && !s.tracking) {
        s.tracking = true;
        _saveSettings(key);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching vitals for $key: $e');
    }
  }

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
    _saveSettings(key);
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
    _saveSettings(key);
    notifyListeners();
  }

  void toggleDay(String key, int index) {
    final s = state(key);
    s.days[index] = !s.days[index];
    _saveSettings(key);
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

  /// Saves the very first reading for a vital, turning tracking on.
  Future<void> addInitialLog(String key, VitalLog log) async {
    final s = state(key);
    try {
      final response = await ApiService.post('/vitals', {
        'type': key,
        'value': log.value,
        'systolic': log.systolic,
        'diastolic': log.diastolic,
        'context': log.context,
        'loggedAt': log.date.toIso8601String(),
      }, token: token);

      final newLog = VitalLog(
        id: response['data']['id'].toString(),
        date: DateTime.parse(response['data']['logged_at']),
        value: response['data']['value']?.toDouble(),
        systolic: response['data']['systolic'],
        diastolic: response['data']['diastolic'],
        context: response['data']['context'],
      );

      s.logs = [newLog]; // We don't backfill mock history in real app
      s.tracking = true;
      _saveSettings(key);
      expandedKey = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding vital: $e');
    }
  }

  Future<void> updateLog(String key, String logId, VitalLog updated) async {
    try {
      await ApiService.patch('/vitals/$logId', {
        'value': updated.value,
        'systolic': updated.systolic,
        'diastolic': updated.diastolic,
        'context': updated.context,
        'loggedAt': updated.date.toIso8601String(),
        'note': updated.note,
      }, token: token);

      final s = state(key);
      final idx = s.logs.indexWhere((l) => l.id == logId);
      if (idx != -1) {
        s.logs[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating vital: $e');
    }
  }

  Future<void> deleteLog(String key, String logId) async {
    try {
      await ApiService.delete('/vitals/$logId', token: token);
      final s = state(key);
      s.logs.removeWhere((l) => l.id == logId);

      // If last log is deleted, stop tracking in settings too
      if (s.logs.isEmpty && s.tracking) {
        s.tracking = false;
        await _saveSettings(key);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting vital: $e');
    }
  }

  void stopTracking(String key) {
    state(key).tracking = false;
    _saveSettings(key);
    notifyListeners();
  }

  /// Returns true if at least one vital is currently being tracked.
bool get hasHealthTracking {
  return _states.values.any((state) => state.tracking);
}

/// Returns all health readings that should have been logged today
/// but have not been logged.
List<MissedVitalReading> get missedReadingsToday {
  final now = DateTime.now();

  final dayIndex = now.weekday % 7;

  final missed = <MissedVitalReading>[];

  for (final entry in _states.entries) {
    final key = entry.key;
    final state = entry.value;

    if (!state.tracking) {
      continue;
    }

    // Check if this vital is scheduled today.
    if (state.days.length > dayIndex &&
        !state.days[dayIndex]) {
      continue;
    }

    // Sort today's logs.
    final todayLogs = state.logs
        .where((log) {
          return log.date.year == now.year &&
              log.date.month == now.month &&
              log.date.day == now.day;
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Sort scheduled times.
    final scheduledTimes = <DateTime>[];

    for (final timeString in state.times) {
      final parts = timeString.split(':');

      if (parts.length != 2) {
        continue;
      }

      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour == null || minute == null) {
        continue;
      }

      final scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Only times that have passed can be missed.
      if (!scheduled.isAfter(now)) {
        scheduledTimes.add(scheduled);
      }
    }

    scheduledTimes.sort();

    // Each log can satisfy one scheduled reading.
    var logIndex = 0;

    for (final scheduledTime in scheduledTimes) {
      bool foundMatchingLog = false;

      while (logIndex < todayLogs.length) {
        final log = todayLogs[logIndex];

        // A log before this scheduled time does not
        // satisfy this reminder.
        if (log.date.isBefore(scheduledTime)) {
          logIndex++;
          continue;
        }

        // This log satisfies this scheduled reading.
        foundMatchingLog = true;
        logIndex++;
        break;
      }

      if (!foundMatchingLog) {
        final hh =
            scheduledTime.hour.toString().padLeft(2, '0');

        final mm =
            scheduledTime.minute.toString().padLeft(2, '0');

        missed.add(
          MissedVitalReading(
            key: key,
            scheduledTime: '$hh:$mm',
          ),
        );
      }
    }
  }

  return missed;
}
}
