import 'package:flutter/material.dart';
import '../pages/medication_tracker/models/medication.dart';
import '../pages/medication_tracker/models/scheduled_dose.dart';
import '../repositories/medication_repository.dart';

class MedicationProvider extends ChangeNotifier {
  List<Medication> _medications = [];
  List<ScheduledDose> _todayDoses = [];
  Map<DateTime, int> _adherenceByDate = {};
  bool _isLoading = false;
  String? _error;

  List<Medication> get medications => _medications;
  List<ScheduledDose> get todayDoses => _todayDoses;
  Map<DateTime, int> get adherenceByDate => _adherenceByDate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final MedicationRepository _repository;

  MedicationProvider(this._repository) {
    _init();
  }

  Future<void> _init() async {
    await fetchMedications();
    await fetchAdherence();
  }

  Future<void> fetchMedications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _repository.getMedicationData();
      _medications = data['medications'] as List<Medication>;
      final todayLogs = data['todayLogs'] as List;
      _buildTodayDoses(todayLogs);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchAdherence() async {
    try {
      _adherenceByDate = await _repository.getAdherence();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching adherence: $e');
    }
  }

  Future<void> addMedication(Medication medication) async {
    try {
      final newMed = await _repository.addMedication(medication);
      _medications.add(newMed);
      _buildTodayDoses([]); // Rebuild with current state, though logs might need refresh
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void _buildTodayDoses(List todayLogs) {
    final doses = <ScheduledDose>[];
    for (final med in _medications) {
      for (var i = 0; i < med.times.length; i++) {
        final time = med.times[i];
        final timeStr = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

        final isTaken = todayLogs.any((l) =>
          l['reminderId'] == med.id && l['scheduledTime'] == timeStr
        );

        doses.add(
          ScheduledDose(
            id: '${med.id}-$i',
            medication: med,
            time: time,
            period: dosePeriodForTime(time),
            taken: isTaken,
          ),
        );
      }
    }
    doses.sort((a, b) {
      final aMinutes = a.time.hour * 60 + a.time.minute;
      final bMinutes = b.time.hour * 60 + b.time.minute;
      return aMinutes.compareTo(bMinutes);
    });
    _todayDoses = doses;
  }

  Future<void> toggleDoseTaken(ScheduledDose dose) async {
    final wasTaken = dose.taken;
    dose.taken = !wasTaken;
    notifyListeners();

    final timeStr = '${dose.time.hour.toString().padLeft(2, '0')}:${dose.time.minute.toString().padLeft(2, '0')}';

    try {
      if (dose.taken) {
        await _repository.logDose(dose.medication.id, timeStr);
      } else {
        await _repository.unlogDose(dose.medication.id, timeStr);
      }
      await fetchAdherence(); // Refresh adherence map to update calendar
    } catch (e) {
      // Rollback if failed
      dose.taken = wasTaken;
      notifyListeners();
      debugPrint('Error toggling dose: $e');
    }
  }
}
