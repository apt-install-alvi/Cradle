/// The kind of measurement a symptom collects, if any.
enum MeasurementType {
  /// A single numeric reading with a unit, e.g. body temperature.
  temperature,

  /// A two-part reading (systolic/diastolic), e.g. blood pressure.
  bloodPressure,
}

/// A selectable symptom/sickness shown as a card on the input screen.
class Symptom {
  final String id;
  final String label;
  final String icon;

  /// Whether this symptom should show a follow-up input card (for backward compatibility).
  final bool isMeasurable;

  /// Only set when [isMeasurable] is true (for backward compatibility).
  final MeasurementType? measurementType;

  /// List of physiological feature names required for predicting the risk
  /// of this symptom/sickness.
  final List<String> requiredFeatures;

  const Symptom({
    required this.id,
    required this.label,
    required this.icon,
    this.isMeasurable = false,
    this.measurementType,
    required this.requiredFeatures,
  });
}

extension SymptomLocalization on Symptom {
  String displayLabel(bool isBangla) {
    if (!isBangla) return label;

    switch (id) {
      case 'fever':
        return 'জ্বর ও ইনফেকশন';
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
        return 'দম বন্ধ অনুভূতি';
      case 'spotting':
        return 'রক্তের দাগ বা রক্তক্ষরণ';
      case 'gestational_diabetes':
        return 'গর্ভকালীন ডায়াবেটিস';
      case 'heart_palpitations':
        return 'বুক ধড়ফড়ানি';
      case 'extreme_fatigue':
        return 'তীব্র অবসাদ ও ক্লান্তি';
      case 'anemia':
        return 'রক্তস্বল্পতা ও দুর্বলতা';
      case 'breathing_difficulty':
        return 'শ্বাসকষ্ট';
      case 'muscle_cramps':
        return 'পেশীর টান বা ব্যথা';
      default:
        return label;
    }
  }
}

/// The full symptom/sickness pool containing 15 items.
const List<Symptom> kAllSymptoms = [
  Symptom(
    id: 'fever',
    label: 'Fever / Infection',
    icon: 'assets/icons/fever2.png',
    isMeasurable: true,
    measurementType: MeasurementType.temperature,
    requiredFeatures: ['body_temp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'high_bp',
    label: 'High BP / Hypertension',
    icon: 'assets/icons/high_bp.png',
    isMeasurable: true,
    measurementType: MeasurementType.bloodPressure,
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'bmi', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'gestational_diabetes',
    label: 'Gestational Diabetes',
    icon: 'assets/icons/bp.png',
    requiredFeatures: ['hba1c', 'fasting_glucose', 'bmi', 'age'],
  ),
  Symptom(
    id: 'nausea',
    label: 'Nausea / Vomiting',
    icon: 'assets/icons/nausea.png',
    requiredFeatures: ['fasting_glucose', 'body_temp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'headache',
    label: 'Severe Headache',
    icon: 'assets/icons/headache.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'swelling',
    label: 'Excessive Swelling',
    icon: 'assets/icons/swelling.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'bmi', 'age'],
  ),
  Symptom(
    id: 'blurred_vision',
    label: 'Blurred Vision',
    icon: 'assets/icons/blurred_vision.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'hba1c', 'fasting_glucose', 'age'],
  ),
  Symptom(
    id: 'shortness_of_breath',
    label: 'Shortness of Breath',
    icon: 'assets/icons/breathing_problem.png',
    requiredFeatures: ['heart_rate', 'systolic_bp', 'diastolic_bp', 'bmi', 'age'],
  ),
  Symptom(
    id: 'spotting',
    label: 'Spotting / Bleeding',
    icon: 'assets/icons/spotting.png',
    requiredFeatures: ['body_temp', 'heart_rate', 'systolic_bp', 'diastolic_bp', 'age'],
  ),
  Symptom(
    id: 'loose_motion',
    label: 'Loose Motion / Diarrhea',
    icon: 'assets/icons/loose_motion.png',
    requiredFeatures: ['body_temp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'heart_palpitations',
    label: 'Heart Palpitations',
    icon: 'assets/icons/heartbeat.png',
    requiredFeatures: ['heart_rate', 'systolic_bp', 'diastolic_bp', 'age'],
  ),
  Symptom(
    id: 'extreme_fatigue',
    label: 'Extreme Fatigue',
    icon: 'assets/icons/headache.png',
    requiredFeatures: ['hba1c', 'fasting_glucose', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'anemia',
    label: 'Anemia / Weakness',
    icon: 'assets/icons/oxygen.png',
    requiredFeatures: ['heart_rate', 'age'],
  ),
  Symptom(
    id: 'breathing_difficulty',
    label: 'Breathing Difficulty',
    icon: 'assets/icons/breathing_problem.png',
    requiredFeatures: ['heart_rate', 'bmi', 'age'],
  ),
  Symptom(
    id: 'muscle_cramps',
    label: 'Muscle Cramps',
    icon: 'assets/icons/swelling.png',
    requiredFeatures: ['age', 'body_temp'],
  ),
];
