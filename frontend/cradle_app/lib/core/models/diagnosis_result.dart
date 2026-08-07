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

  String displayLabel(bool isBangla) {
    if (!isBangla) return label;

    switch (this) {
      case RiskLevel.low:
        return 'নিম্ন ঝুঁকি';
      case RiskLevel.medium:
        return 'মাঝারি ঝুঁকি';
      case RiskLevel.high:
        return 'উচ্চ ঝুঁকি';
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

  String shortDisplayLabel(bool isBangla) {
    if (!isBangla) return shortLabel;

    switch (this) {
      case RiskLevel.low:
        return 'নিম্ন';
      case RiskLevel.medium:
        return 'মাঝারি';
      case RiskLevel.high:
        return 'উচ্চ';
    }
  }

  /// Green / yellow / red risk colors.
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
class SymptomEntry {
  final Symptom symptom;
  final Map<String, String> measurements;

  const SymptomEntry({
    required this.symptom,
    this.measurements = const {},
  });

  String displayLabel(bool isBangla) {
    final symptomLabel = symptom.displayLabel(isBangla);

    if (!symptom.isMeasurable || measurements.isEmpty) {
      return symptomLabel;
    }

    switch (symptom.measurementType) {
      case MeasurementType.temperature:
        final value = measurements['value'];
        return value == null ? symptomLabel : '$symptomLabel · $value°F';

      case MeasurementType.bloodPressure:
        final sys = measurements['systolic'];
        final dia = measurements['diastolic'];

        if (sys == null || dia == null) return symptomLabel;

        return '$symptomLabel · $sys/$dia mmHg';

      case null:
        return symptomLabel;
    }
  }
}

/// The result of the AI risk assessment and the record stored in history.
class DiagnosisResult {
  final RiskLevel riskLevel;
  final List<SymptomEntry> reportedSymptoms;

  /// English warning
  final String warningMessage;

  /// Bangla warning
  final String warningMessageBn;

  final DateTime timestamp;

  const DiagnosisResult({
    required this.riskLevel,
    required this.reportedSymptoms,
    required this.warningMessage,
    required this.warningMessageBn,
    required this.timestamp,
  });

  String localizedWarningMessage(bool isBangla) {
    return isBangla ? warningMessageBn : warningMessage;
  }
}