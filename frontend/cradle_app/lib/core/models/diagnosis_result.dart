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
  String displayLabel(bool isBangla) {
    final symptomLabel = symptom.displayLabel(isBangla);

    if (!symptom.isMeasurable || measurements.isEmpty) return symptomLabel;
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

  String localizedDiagnosisName(bool isBangla) {
    if (!isBangla) return diagnosisName;

    switch (diagnosisName) {
      case 'Possible Preeclampsia':
        return 'সম্ভাব্য প্রি-এক্ল্যাম্পসিয়া';
      case 'Mild Dehydration':
        return 'হালকা পানিশূন্যতা';
      case 'Normal Pregnancy Fatigue':
        return 'স্বাভাবিক গর্ভাবস্থার ক্লান্তি';
      default:
        return diagnosisName;
    }
  }

  String localizedWarningMessage(bool isBangla) {
    if (!isBangla) return warningMessage;

    switch (warningMessage) {
      case 'Your symptoms suggest a condition that can affect you and your baby quickly. Please see a doctor today.':
        return 'আপনার উপসর্গগুলো এমন একটি অবস্থার ইঙ্গিত দিচ্ছে যা আপনার এবং আপনার শিশুর ওপর দ্রুত প্রভাব ফেলতে পারে। অনুগ্রহ করে আজই একজন ডাক্তার দেখান।';
      case 'Drink fluids and monitor your symptoms; see a doctor if they persist beyond a day.':
        return 'পর্যাপ্ত তরল পান করুন এবং আপনার উপসর্গ পর্যবেক্ষণ করুন; এক দিনের বেশি থাকলে ডাক্তার দেখান।';
      case 'No action needed — rest and stay hydrated.':
        return 'কোনো তৎক্ষণাৎ পদক্ষেপ দরকার নেই — বিশ্রাম নিন এবং পর্যাপ্ত পানি পান করুন।';
      default:
        return warningMessage;
    }
  }
}
