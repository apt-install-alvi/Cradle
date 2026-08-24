import 'package:flutter/material.dart';

/// How often a medication should be taken in a day.
enum MedicationFrequency { once, twice, thrice, custom }

/// A medication the user has added to their tracker.
class Medication {
  final String id;
  final String name;

  /// Path to the icon representing this medicine's type. Defaults to the
  /// shared placeholder PNG until real per-type icon assets are added.
  final String iconAsset;

  final double doseAmount;
  final String doseUnit;
  final MedicationFrequency frequency;

  /// Times of day this medication should be taken.
  final List<TimeOfDay> times;

  /// Only used when [frequency] is [MedicationFrequency.custom].
  /// Uses [DateTime.weekday] convention: 1 = Monday ... 7 = Sunday.
  final List<int> customDays;

  const Medication({
    required this.id,
    required this.name,
    this.iconAsset = 'assets/icons/placeholder.png',
    required this.doseAmount,
    required this.doseUnit,
    required this.frequency,
    required this.times,
    this.customDays = const [],
  });

  String get formattedAmount =>
      doseAmount % 1 == 0 ? doseAmount.toInt().toString() : doseAmount.toString();

  String frequencyLabel(bool isBangla) {
    switch (frequency) {
      case MedicationFrequency.once:
        return isBangla ? 'দিনে একবার' : 'Once daily';
      case MedicationFrequency.twice:
        return isBangla ? 'দিনে দুইবার' : 'Twice daily';
      case MedicationFrequency.thrice:
        return isBangla ? 'দিনে তিনবার' : 'Three times daily';
      case MedicationFrequency.custom:
        return isBangla ? 'নির্দিষ্ট দিনে' : 'Custom';
    }
  }

  Medication copyWith({
    String? id,
    String? name,
    String? iconAsset,
    double? doseAmount,
    String? doseUnit,
    MedicationFrequency? frequency,
    List<TimeOfDay>? times,
    List<int>? customDays,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      iconAsset: iconAsset ?? this.iconAsset,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      customDays: customDays ?? this.customDays,
    );
  }

  factory Medication.fromJson(Map<String, dynamic> json) {
    final List<String> timeStrings = List<String>.from(json['time_of_day'] ?? []);
    final times = timeStrings.map((t) {
      final parts = t.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }).toList();

    // Map frequency based on number of times if not provided
    MedicationFrequency freq = MedicationFrequency.custom;
    if (times.length == 1) freq = MedicationFrequency.once;
    if (times.length == 2) freq = MedicationFrequency.twice;
    if (times.length == 3) freq = MedicationFrequency.thrice;

    // Parse dosage "500 mg"
    final dosageStr = json['dosage'] ?? '0';
    final dosageParts = dosageStr.split(' ');
    final amount = double.tryParse(dosageParts[0]) ?? 0.0;
    final unit = dosageParts.length > 1 ? dosageParts[1] : '';

    return Medication(
      id: json['id'] ?? '',
      name: json['medication_name'] ?? '',
      doseAmount: amount,
      doseUnit: unit,
      frequency: freq,
      times: times,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationName': name,
      'dosage': '$formattedAmount $doseUnit',
      'timeOfDay': times.map((t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}').toList(),
    };
  }
}
