import '../core/services/api_service.dart';
import '../pages/medication_tracker/models/medication.dart';

class MedicationRepository {
  final String token;

  MedicationRepository(this.token);

  Future<Map<String, dynamic>> getMedicationData() async {
    final response = await ApiService.get('/appointments/reminders', token: token);
    final data = response['data'] ?? {};
    final List remindersJson = data['reminders'] ?? [];
    final List logsJson = data['logs'] ?? [];

    final medications = remindersJson.map((json) => Medication.fromJson(json)).toList();
    final logs = logsJson.map((l) => {
      'reminderId': l['reminder_id'],
      'scheduledTime': l['scheduled_time'],
    }).toList();

    return {
      'medications': medications,
      'todayLogs': logs,
    };
  }

  Future<Medication> addMedication(Medication medication) async {
    final response = await ApiService.post(
      '/appointments/reminders',
      medication.toJson(),
      token: token,
    );
    return Medication.fromJson(response['data']);
  }

  Future<void> logDose(String reminderId, String scheduledTime) async {
    await ApiService.post(
      '/appointments/log-dose',
      {
        'reminderId': reminderId,
        'scheduledTime': scheduledTime,
      },
      token: token,
    );
  }

  Future<void> unlogDose(String reminderId, String scheduledTime) async {
    await ApiService.post(
      '/appointments/unlog-dose',
      {
        'reminderId': reminderId,
        'scheduledTime': scheduledTime,
      },
      token: token,
    );
  }

  Future<Map<DateTime, int>> getAdherence() async {
    final response = await ApiService.get('/appointments/adherence', token: token);
    final Map<String, dynamic> data = response['data'] ?? {};

    final Map<DateTime, int> processedAdherence = {};
    data.forEach((dateStr, percentage) {
      final date = DateTime.parse(dateStr);
      processedAdherence[DateTime(date.year, date.month, date.day)] = percentage as int;
    });

    return processedAdherence;
  }
}
