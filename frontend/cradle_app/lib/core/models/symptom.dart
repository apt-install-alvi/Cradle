/// The kind of measurement a symptom collects, if any.
enum MeasurementType {
  /// A single numeric reading with a unit, e.g. body temperature.
  temperature,

  /// A two-part reading (systolic/diastolic), e.g. blood pressure.
  bloodPressure,
}

/// A selectable symptom shown as a card on the input screen.
class Symptom {
  final String id;
  final String label;
  final String emoji;

  /// Whether this symptom should show a follow-up input card for the
  /// user to enter a concrete measurement. Only symptoms that make
  /// sense to quantify (temperature, blood pressure) are measurable —
  /// subjective symptoms like headache or nausea are not.
  final bool isMeasurable;

  /// Only set when [isMeasurable] is true.
  final MeasurementType? measurementType;

  const Symptom({
    required this.id,
    required this.label,
    required this.emoji,
    this.isMeasurable = false,
    this.measurementType,
  }) : assert(
          isMeasurable == (measurementType != null),
          'measurementType must be set if and only if isMeasurable is true',
        );
}

/// The full symptom pool the input screen draws from.
///
/// Only Fever and High BP are measurable: they expand into a follow-up
/// input card (temperature / blood pressure reading). Every other
/// symptom here is subjective and is only ever a selectable card.
const List<Symptom> kAllSymptoms = [
  Symptom(
    id: 'fever',
    label: 'Fever',
    emoji: '🌡️',
    isMeasurable: true,
    measurementType: MeasurementType.temperature,
  ),
  Symptom(
    id: 'high_bp',
    label: 'High BP',
    emoji: '💢',
    isMeasurable: true,
    measurementType: MeasurementType.bloodPressure,
  ),
  Symptom(id: 'loose_motion', label: 'Loose Motion', emoji: '💧'),
  Symptom(id: 'nausea', label: 'Nausea', emoji: '🤢'),
  Symptom(id: 'headache', label: 'Headache', emoji: '🤕'),
  Symptom(id: 'swelling', label: 'Swelling', emoji: '🦶'),
  Symptom(id: 'blurred_vision', label: 'Blurred Vision', emoji: '👁️'),
  Symptom(
    id: 'shortness_of_breath',
    label: 'Shortness of Breath',
    emoji: '😮‍💨',
  ),
  Symptom(id: 'spotting', label: 'Spotting', emoji: '🩸'),
];
