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
  final String icon;

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
    required this.icon,
    this.isMeasurable = false,
    this.measurementType,
  }) : assert(
          isMeasurable == (measurementType != null),
          'measurementType must be set if and only if isMeasurable is true',
        );
}

extension SymptomLocalization on Symptom {
  String displayLabel(bool isBangla) {
    if (!isBangla) return label;

    switch (id) {
      case 'fever':
        return 'জ্বর';
      case 'high_bp':
        return 'উচ্চ রক্তচাপ';
      case 'loose_motion':
        return 'পাতলা পায়খানা';
      case 'nausea':
        return 'বমি বমি ভাব';
      case 'headache':
        return 'মাথা-ব্যথা';
      case 'swelling':
        return 'শরীরে ফোলা ভাব';
      case 'blurred_vision':
        return 'চোখে ঝাপসা দেখা';
      case 'shortness_of_breath':
        return 'শ্বাসকষ্ট';
      case 'spotting':
        return 'রক্তের দাগ দেখা';
      default:
        return label;
    }
  }
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
    icon: 'assets/icons/fever2.png',
    isMeasurable: true,
    measurementType: MeasurementType.temperature,
  ),
  Symptom(
    id: 'high_bp',
    label: 'High BP',
    icon: 'assets/icons/high_bp.png',
    isMeasurable: true,
    measurementType: MeasurementType.bloodPressure,
  ),
  Symptom(id: 'loose_motion', label: 'Loose Motion', icon: 'assets/icons/loose_motion.png'),
  Symptom(id: 'nausea', label: 'Nausea', icon: 'assets/icons/nausea.png'),
  Symptom(id: 'headache', label: 'Headache', icon: 'assets/icons/headache.png'),
  Symptom(id: 'swelling', label: 'Swelling', icon: 'assets/icons/swelling.png'),
  Symptom(id: 'blurred_vision', label: 'Blurred Vision', icon: 'assets/icons/blurred_vision.png'),
  Symptom(
    id: 'shortness_of_breath',
    label: 'Shortness of Breath',
    icon: 'assets/icons/breathing_problem.png',
  ),
  Symptom(id: 'spotting', label: 'Spotting', icon: 'assets/icons/spotting.png'),
];
