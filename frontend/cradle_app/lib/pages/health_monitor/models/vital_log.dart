class VitalLog {
  final String id;
  final DateTime date;

  /// Used for single-value vitals (temp, glucose, spo2, hr).
  final double? value;

  /// Used for blood pressure only.
  final int? systolic;
  final int? diastolic;

  /// Canonical English context string (e.g. "Fasting"). Translated at
  /// display time via localizedGlucoseContext().
  final String? context;

  final String note;

  const VitalLog({
    required this.id,
    required this.date,
    this.value,
    this.systolic,
    this.diastolic,
    this.context,
    this.note = '',
  });

  VitalLog copyWith({
    double? value,
    int? systolic,
    int? diastolic,
    String? context,
    String? note,
  }) {
    return VitalLog(
      id: id,
      date: date,
      value: value ?? this.value,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      context: context ?? this.context,
      note: note ?? this.note,
    );
  }
}
