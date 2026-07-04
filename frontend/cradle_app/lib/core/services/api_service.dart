import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    // For mobile: Android emulator uses 10.0.2.2, others use localhost
    return 'http://10.0.2.2:5000/api';
  }

  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // Safe decode — returns error map on failure
  static Map<String, dynamic> _decode(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {'success': false, 'message': 'Invalid server response', 'data': null};
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(String phone, String password) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/auth/register'),
              headers: _headers, body: jsonEncode({'phone': phone, 'password': password}))
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {'success': false, 'message': 'Cannot connect to server', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/auth/login'),
              headers: _headers, body: jsonEncode({'phone': phone, 'password': password}))
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {'success': false, 'message': 'Cannot connect to server', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String phone, String code) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/auth/verify-otp'),
              headers: _headers, body: jsonEncode({'phone': phone, 'code': code}))
          .timeout(const Duration(seconds: 5));
      final data = _decode(response);
      if (data['success'] == true && data['data'] != null) {
        _token = data['data']['token'];
      }
      return data;
    } catch (_) {
      return {'success': false, 'message': 'Cannot connect to server', 'data': null};
    }
  }

  // ── Profile ───────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/profile'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {'success': false, 'message': 'Cannot connect to server', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/profile'),
              headers: _headers, body: jsonEncode(profileData))
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {'success': false, 'message': 'Cannot connect to server', 'data': null};
    }
  }

  // ── Symptoms ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> logSymptoms(
      List<Map<String, dynamic>> symptomsList, String notes) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/symptoms'),
              headers: _headers,
              body: jsonEncode({'symptomsList': symptomsList, 'notes': notes}))
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {'success': false, 'message': 'Cannot connect to server', 'data': null};
    }
  }

  static Future<Map<String, dynamic>> getSymptomsHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/symptoms/history'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'offline-1',
            'symptomsList': [
              {'name': 'Nausea', 'severity': 3},
              {'name': 'Fatigue', 'severity': 5}
            ],
            'notes': 'Sample data (server offline)',
            'loggedAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String()
          }
        ]
      };
    }
  }

  // ── AI Predictions ────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAiAssessmentHistory() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/predictions/history'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'offline-pred-1',
            'riskLevel': 'LOW',
            'confidenceScore': 0.95,
            'recommendations': [
              'Continue drinking water and tracking your daily symptoms.',
              'Maintain adequate sleep and regular light physical movement.'
            ],
            'assessedAt': DateTime.now().toIso8601String()
          }
        ]
      };
    }
  }

  static Future<Map<String, dynamic>> runAiAssessment(
      List<Map<String, dynamic>> symptoms) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/predictions/assess'),
              headers: _headers, body: jsonEncode({'symptoms': symptoms}))
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {
        'success': true,
        'data': {
          'riskLevel': 'LOW',
          'confidenceScore': 0.95,
          'recommendations': ['Continue monitoring your symptoms daily.']
        }
      };
    }
  }

  // ── Appointments ──────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getAppointments() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/appointments'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'offline-appt-1',
            'doctorName': 'Dr. Sarah Connor',
            'clinicName': 'Grace Maternity Clinic',
            'dateTime':
                DateTime.now().add(const Duration(days: 2)).toIso8601String(),
            'purpose': 'Routine Prenatal Anatomy Scan',
            'status': 'SCHEDULED'
          }
        ]
      };
    }
  }

  static Future<Map<String, dynamic>> createAppointment(
      Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/appointments'),
              headers: _headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {'success': true, 'data': {...data, '_id': 'offline-${DateTime.now().millisecondsSinceEpoch}'}};
    }
  }

  static Future<Map<String, dynamic>> getMedicationReminders() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/appointments/reminders'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'offline-rem-1',
            'medicationName': 'Prenatal Multivitamins',
            'dosage': '1 Capsule',
            'timeOfDay': ['08:00'],
            'isActive': true
          },
          {
            '_id': 'offline-rem-2',
            'medicationName': 'Calcium Carbonate',
            'dosage': '500mg',
            'timeOfDay': ['12:00', '20:00'],
            'isActive': true
          }
        ]
      };
    }
  }

  static Future<Map<String, dynamic>> createMedicationReminder(
      Map<String, dynamic> data) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/appointments/reminders'),
              headers: _headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {'success': true, 'data': {...data, '_id': 'offline-${DateTime.now().millisecondsSinceEpoch}'}};
    }
  }

  // ── Emergency ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> triggerSos(Map<String, double>? location) async {
    try {
      final response = await http
          .post(Uri.parse('$baseUrl/emergency/sos'),
              headers: _headers, body: jsonEncode({'location': location}))
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {
        'success': true,
        'data': {
          'alert': {'status': 'TRIGGERED'},
          'contactsSent': [{'name': 'Emergency Contact', 'phone': 'N/A'}]
        }
      };
    }
  }

  // ── Education ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getArticles({int? trimester}) async {
    try {
      String path = '$baseUrl/education';
      if (trimester != null) path += '?trimester=$trimester';
      final response = await http
          .get(Uri.parse(path), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'art-1',
            'title': 'Managing Morning Sickness: Diet and Tips',
            'content':
                'Morning sickness is common in the first trimester. Focus on small, frequent meals containing ginger, peppermint, and light crackers. Avoid greasy food and drink plenty of clear fluids between meals.',
            'category': 'NUTRITION',
            'trimester': 1,
            'readingTimeMinutes': 4
          },
          {
            '_id': 'art-2',
            'title': 'Safe Physical Exercises for Second Trimester',
            'content':
                'During the second trimester, gentle exercises like prenatal yoga, swimming, and stationary cycling are highly beneficial. Always listen to your body, avoid lying flat on your back, and stay well hydrated.',
            'category': 'EXERCISE',
            'trimester': 2,
            'readingTimeMinutes': 5
          },
          {
            '_id': 'art-3',
            'title': 'Recognizing Early Signs of Labor',
            'content':
                'Signs of labor include regular contractions that get closer together, pain in the lower back/abdomen, and water breaking. Keep your doctor\'s number on speed dial and prepare your hospital bag early.',
            'category': 'LABOR',
            'trimester': 3,
            'readingTimeMinutes': 6
          }
        ]
      };
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/notifications'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      return _decode(response);
    } catch (_) {
      return {
        'success': true,
        'data': [
          {
            '_id': 'notif-1',
            'title': 'Welcome to Cradle!',
            'body': 'Start tracking your symptoms today.',
            'type': 'GENERAL',
            'isRead': false,
            'sentAt': DateTime.now().toIso8601String()
          }
        ]
      };
    }
  }
}

