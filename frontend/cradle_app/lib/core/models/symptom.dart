/// The kind of measurement a symptom collects, if any.
enum MeasurementType {
  /// A single numeric reading with a unit, e.g. body temperature.
  temperature,

  /// A two-part reading (systolic/diastolic), e.g. blood pressure.
  bloodPressure,
}

/// A selectable sickness/difficulty shown as a card on the input screen.
class Symptom {
  final String id;
  final String label;
  final String icon;

  /// Whether this sickness supports a numeric reading (for backward compatibility).
  final bool isMeasurable;

  /// Only set when [isMeasurable] is true (for backward compatibility).
  final MeasurementType? measurementType;

  /// List of physiological feature names required for predicting the risk
  /// of this sickness.
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
      case 'high_blood_pressure':
        return 'উচ্চ রক্তচাপ';
      case 'low_blood_pressure':
        return 'নিম্ন রক্তচাপ';
      case 'elevated_heart_rate':
        return 'হৃদস্পন্দন বৃদ্ধি';
      case 'vomiting':
        return 'বমি';
      case 'fever':
        return 'জ্বর';
      case 'dehydration':
        return 'পানিশূন্যতা';
      case 'high_blood_glucose':
        return 'রক্তে শর্করা বেড়ে যাওয়া (হাই সুগার)';
      case 'low_blood_glucose':
        return 'রক্তে শর্করা কমে যাওয়া (লো সুগার)';
      case 'stress':
        return 'মানসিক চাপ';
      case 'difficulty_breathing':
        return 'তীব্র শ্বাসকষ্ট';
      case 'spotting/bleeding':
        return 'রক্তপাত/স্পটিং';
      case 'diarrhoea':
        return 'ডায়রিয়া/ফুড পয়জনিং';
      case 'headache':
        return 'তীব্র মাথাব্যথা';
      default:
        return label;
    }
  }
}

/// Dynamic list of 12 clinical pregnancy complications and difficulties
/// mapping to the XGBoost model's feature set.
const List<Symptom> kAllSymptoms = [
  Symptom(
    id: 'high_blood_glucose',
    label: 'High Blood Glucose',
    icon: 'assets/icons/bp.png',
    requiredFeatures: ['hba1c', 'fasting_glucose', 'bmi', 'age'],
  ),
  Symptom(
    id: 'high_blood_pressure',
    label: 'High Blood Pressure',
    icon: 'assets/icons/high_bp.png',
    isMeasurable: true,
    measurementType: MeasurementType.bloodPressure,
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'bmi', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'vomiting',
    label: 'Vomiting',
    icon: 'assets/icons/nausea.png',
    requiredFeatures: ['fasting_glucose', 'heart_rate', 'body_temp', 'age'],
  ),
  Symptom(
    id: 'fever',
    label: 'Fever',
    icon: 'assets/icons/fever2.png',
    isMeasurable: true,
    measurementType: MeasurementType.temperature,
    requiredFeatures: ['body_temp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'low_blood_pressure',
    label: 'Low Blood Pressure',
    icon: 'assets/icons/high_bp.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'bmi', 'age'],
  ),
  Symptom(
    id: 'elevated_heart_rate',
    label: 'Elevated Heart Rate',
    icon: 'assets/icons/heartbeat.png',
    requiredFeatures: ['heart_rate', 'systolic_bp', 'diastolic_bp', 'age'],
  ),
  Symptom(
    id: 'dehydration',
    label: 'Dehydration',
    icon: 'assets/icons/swelling.png',
    requiredFeatures: ['bmi', 'systolic_bp', 'diastolic_bp', 'age'],
  ),
  Symptom(
    id: 'low_blood_glucose',
    label: 'Low Blood Glucose',
    icon: 'assets/icons/oxygen.png',
    requiredFeatures: ['fasting_glucose', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'difficulty_breathing',
    label: 'Difficulty Breathing',
    icon: 'assets/icons/breathing_problem.png',
    requiredFeatures: ['heart_rate', 'systolic_bp', 'diastolic_bp', 'bmi', 'age'],
  ),
  Symptom(
    id: 'spotting/bleeding',
    label: 'Spotting / Bleeding',
    icon: 'assets/icons/spotting.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'diarrhoea',
    label: 'Diarrhoea',
    icon: 'assets/icons/loose_motion.png',
    requiredFeatures: ['body_temp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'headache',
    label: 'Headache',
    icon: 'assets/icons/headache.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'hba1c', 'age'],
  ),
];
