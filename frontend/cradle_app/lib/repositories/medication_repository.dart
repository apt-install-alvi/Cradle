import '../core/services/api_service.dart';
import '../pages/medication_tracker/models/medication.dart';

class MedicationRepository {
  final String token;

  MedicationRepository(this.token);

  Future<Map<String, dynamic>> getMedicationData() async {
    final now = DateTime.now();
    final localDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final response = await ApiService.get('/appointments/reminders?localDate=$localDate', token: token);
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

  Future<Medication> updateMedication(Medication medication) async {
    final response = await ApiService.patch(
      '/appointments/reminders/${medication.id}',
      medication.toJson(),
      token: token,
    );
    return Medication.fromJson(response['data']);
  }

  Future<void> deleteMedication(String id) async {
    // Note: Our ApiService doesn't have a delete method yet.
    // I'll need to add it or use a generic request method.
    // For now, I'll add it to ApiService first.
    await ApiService.delete('/appointments/reminders/$id', token: token);
  }

  Future<void> logDose(String reminderId, String scheduledTime) async {
    final now = DateTime.now();
    final localDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    await ApiService.post(
      '/appointments/log-dose',
      {
        'reminderId': reminderId,
        'scheduledTime': scheduledTime,
        'localDate': localDate,
      },
      token: token,
    );
  }

  Future<void> unlogDose(String reminderId, String scheduledTime) async {
    final now = DateTime.now();
    final localDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    await ApiService.post(
      '/appointments/unlog-dose',
      {
        'reminderId': reminderId,
        'scheduledTime': scheduledTime,
        'localDate': localDate,
      },
      token: token,
    );
  }

  Future<Map<DateTime, int>> getAdherence() async {
    final now = DateTime.now();
    final localDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final response = await ApiService.get('/appointments/adherence?localDate=$localDate', token: token);
    final Map<String, dynamic> data = response['data'] ?? {};

    final Map<DateTime, int> processedAdherence = {};
    data.forEach((dateStr, percentage) {
      final date = DateTime.parse(dateStr);
      processedAdherence[DateTime(date.year, date.month, date.day)] = percentage as int;
    });

    return processedAdherence;
  }
}
