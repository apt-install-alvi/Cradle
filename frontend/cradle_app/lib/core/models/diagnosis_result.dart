import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'symptom.dart';

enum RiskLevel { low, medium, high }

extension RiskLevelStyle on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }

  String get shortLabel {
    switch (this) {
      case RiskLevel.low:
        return 'Low';
      case RiskLevel.medium:
        return 'Medium';
      case RiskLevel.high:
        return 'High';
    }
  }

  /// Green / yellowish-orange / red, matching the app's risk color coding.
  Color get color {
    switch (this) {
      case RiskLevel.low:
        return AppColors.low;
      case RiskLevel.medium:
        return AppColors.medium;
      case RiskLevel.high:
        return AppColors.high;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case RiskLevel.low:
        return AppColors.lowBg;
      case RiskLevel.medium:
        return AppColors.mediumBg;
      case RiskLevel.high:
        return AppColors.highBg;
    }
  }

  bool get recommendsDoctorVisit =>
      this == RiskLevel.medium || this == RiskLevel.high;

  bool get isEmergency => this == RiskLevel.high;
}

/// A symptom the user reported, with any measurement values they entered.
///
/// [measurements] holds raw values keyed by field name, e.g.
/// `{'value': '101.2'}` for temperature or
/// `{'systolic': '150', 'diastolic': '100'}` for blood pressure.
class SymptomEntry {
  final Symptom symptom;
  final Map<String, String> measurements;

  const SymptomEntry({required this.symptom, this.measurements = const {}});

  /// A short display string for chips, e.g. "Fever · 101.2°F".
  String get displayLabel {
    if (!symptom.isMeasurable || measurements.isEmpty) return symptom.label;
    switch (symptom.measurementType) {
      case MeasurementType.temperature:
        final value = measurements['value'];
        return value == null ? symptom.label : '${symptom.label} · $value°F';
      case MeasurementType.bloodPressure:
        final sys = measurements['systolic'];
        final dia = measurements['diastolic'];
        if (sys == null || dia == null) return symptom.label;
        return '${symptom.label} · $sys/$dia mmHg';
      case null:
        return symptom.label;
    }
  }
}

/// The result shown on the diagnosis assessment screen, and the record
/// persisted for the history screen.
class DiagnosisResult {
  final String diagnosisName;
  final RiskLevel riskLevel;
  final List<SymptomEntry> reportedSymptoms;
  final String warningMessage;
  final DateTime timestamp;

  const DiagnosisResult({
    required this.diagnosisName,
    required this.riskLevel,
    required this.reportedSymptoms,
    required this.warningMessage,
    required this.timestamp,
  });
}
