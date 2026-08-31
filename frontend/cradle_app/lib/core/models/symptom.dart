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
      case 'gestational_diabetes':
        return 'গর্ভকালীন ডায়াবেটিস';
      case 'preeclampsia':
        return 'প্রিক্ল্যাম্পসিয়া (উচ্চ রক্তচাপ)';
      case 'hyperemesis_gravidarum':
        return 'অতিরিক্ত বমি ও পানিশূন্যতা';
      case 'maternal_infection':
        return 'মায়ের ইনফেকশন ও জ্বর';
      case 'chronic_hypertension':
        return 'উচ্চ রক্তচাপ (Hypertension)';
      case 'maternal_tachycardia':
        return 'বুক ধড়ফড়ানি ও দ্রুত হৃদস্পন্দন';
      case 'gestational_obesity':
        return 'অতিরিক্ত ওজন ও উচ্চ বিএমআই';
      case 'hypoglycemia':
        return 'রক্তে শর্করা কমে যাওয়া (লো সুগার)';
      case 'cardiovascular_stress':
        return 'রক্তচাপজনিত তীব্র শ্বাসকষ্ট';
      case 'placental_abruption':
        return 'রক্তক্ষরণ ও শারীরিক শক';
      case 'gastroenteritis':
        return 'ডায়রিয়া ও ফুড পয়জনিং';
      case 'hypertensive_encephalopathy':
        return 'উচ্চ রক্তচাপজনিত তীব্র মাথাব্যথা';
      default:
        return label;
    }
  }
}

/// Dynamic list of 12 clinical pregnancy complications and difficulties
/// mapping to the XGBoost model's feature set.
const List<Symptom> kAllSymptoms = [
  Symptom(
    id: 'gestational_diabetes',
    label: 'Gestational Diabetes',
    icon: 'assets/icons/bp.png',
    requiredFeatures: ['hba1c', 'fasting_glucose', 'bmi', 'age'],
  ),
  Symptom(
    id: 'preeclampsia',
    label: 'Preeclampsia',
    icon: 'assets/icons/high_bp.png',
    isMeasurable: true,
    measurementType: MeasurementType.bloodPressure,
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'bmi', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'hyperemesis_gravidarum',
    label: 'Hyperemesis Gravidarum',
    icon: 'assets/icons/nausea.png',
    requiredFeatures: ['fasting_glucose', 'heart_rate', 'body_temp', 'age'],
  ),
  Symptom(
    id: 'maternal_infection',
    label: 'Maternal Infection / Sepsis',
    icon: 'assets/icons/fever2.png',
    isMeasurable: true,
    measurementType: MeasurementType.temperature,
    requiredFeatures: ['body_temp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'chronic_hypertension',
    label: 'Chronic Hypertension',
    icon: 'assets/icons/high_bp.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'bmi', 'age'],
  ),
  Symptom(
    id: 'maternal_tachycardia',
    label: 'Maternal Tachycardia',
    icon: 'assets/icons/heartbeat.png',
    requiredFeatures: ['heart_rate', 'systolic_bp', 'diastolic_bp', 'age'],
  ),
  Symptom(
    id: 'gestational_obesity',
    label: 'Gestational Obesity',
    icon: 'assets/icons/swelling.png',
    requiredFeatures: ['bmi', 'systolic_bp', 'diastolic_bp', 'age'],
  ),
  Symptom(
    id: 'hypoglycemia',
    label: 'Hypoglycemia',
    icon: 'assets/icons/oxygen.png',
    requiredFeatures: ['fasting_glucose', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'cardiovascular_stress',
    label: 'Cardiovascular Stress',
    icon: 'assets/icons/breathing_problem.png',
    requiredFeatures: ['heart_rate', 'systolic_bp', 'diastolic_bp', 'bmi', 'age'],
  ),
  Symptom(
    id: 'placental_abruption',
    label: 'Placental Shock (Bleeding)',
    icon: 'assets/icons/spotting.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'gastroenteritis',
    label: 'Gastroenteritis (Diarrhea)',
    icon: 'assets/icons/loose_motion.png',
    requiredFeatures: ['body_temp', 'heart_rate', 'age'],
  ),
  Symptom(
    id: 'hypertensive_encephalopathy',
    label: 'Hypertensive Encephalopathy',
    icon: 'assets/icons/headache.png',
    requiredFeatures: ['systolic_bp', 'diastolic_bp', 'hba1c', 'age'],
  ),
];
