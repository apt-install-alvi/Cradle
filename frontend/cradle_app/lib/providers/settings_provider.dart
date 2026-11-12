import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final String? token;

  bool _pushNotificationsEnabled = true;
  bool _appointmentRemindersEnabled = true;
  bool _healthAlertsEnabled = true;
  String _language = 'en';
  bool _isLoading = false;

  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get appointmentRemindersEnabled => _appointmentRemindersEnabled;
  bool get healthAlertsEnabled => _healthAlertsEnabled;
  String get language => _language;
  bool get isLoading => _isLoading;

  SettingsProvider(this.token) {
    if (token != null) fetchSettings();
  }

  Future<void> fetchSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.get('/settings', token: token);
      final data = response['data'];
      if (data != null) {
        _pushNotificationsEnabled = data['push_notifications_enabled'] ?? true;
        _appointmentRemindersEnabled = data['appointment_reminders_enabled'] ?? true;
        _healthAlertsEnabled = data['health_alerts_enabled'] ?? true;
        _language = data['language'] ?? 'en';
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePushNotifications(bool value) async {
    _pushNotificationsEnabled = value;
    notifyListeners();
    await _updateSettings({'push_notifications_enabled': value});
  }

  Future<void> updateAppointmentReminders(bool value) async {
    _appointmentRemindersEnabled = value;
    notifyListeners();
    await _updateSettings({'appointment_reminders_enabled': value});
  }

  Future<void> updateHealthAlerts(bool value) async {
    _healthAlertsEnabled = value;
    notifyListeners();
    await _updateSettings({'health_alerts_enabled': value});
  }

  Future<void> updateLanguage(String value) async {
    _language = value;
    notifyListeners();
    await _updateSettings({'language': value});
  }

  Future<void> _updateSettings(Map<String, dynamic> data) async {
    try {
      await ApiService.patch('/settings', data, token: token);
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }
}
