enum VitalType { bp, single }

/// Static, non-mutable config describing one trackable vital.
/// Mirrors the `vitals` map in the HTML prototype.
class VitalDefinition {
  final String key;
  final String nameEn;
  final String nameBn;
  final String iconAsset;
  final VitalType type;
  final String unit;
  final bool hasContext;

  // Mock-history ranges
  final double? min;
  final double? max;
  final int? sysMin;
  final int? sysMax;
  final int? diaMin;
  final int? diaMax;

  /// Decimal places used when generating mock/random values (temp uses 1).
  final int decimals;

  const VitalDefinition({
    required this.key,
    required this.nameEn,
    required this.nameBn,
    required this.type,
    required this.unit,
    this.iconAsset = 'assets/icons/placeholder.png',
    this.hasContext = false,
    this.min,
    this.max,
    this.sysMin,
    this.sysMax,
    this.diaMin,
    this.diaMax,
    this.decimals = 0,
  });

  String name(bool isBangla) => isBangla ? nameBn : nameEn;
}

const Map<String, VitalDefinition> kVitalDefinitions = {
  'bp': VitalDefinition(
    key: 'bp',
    nameEn: 'Blood Pressure',
    nameBn: 'রক্তচাপ',
    type: VitalType.bp,
    unit: 'mmHg',
    sysMin: 108,
    sysMax: 128,
    diaMin: 68,
    diaMax: 84,
  ),
  'temp': VitalDefinition(
    key: 'temp',
    nameEn: 'Temperature',
    nameBn: 'তাপমাত্রা',
    type: VitalType.single,
    unit: '°F',
    min: 97.2,
    max: 99.1,
    decimals: 1,
  ),
  'glucose': VitalDefinition(
    key: 'glucose',
    nameEn: 'Blood Glucose',
    nameBn: 'রক্তে গ্লুকোজ',
    type: VitalType.single,
    unit: 'mg/dL',
    hasContext: true,
    min: 82,
    max: 132,
  ),
  'spo2': VitalDefinition(
    key: 'spo2',
    nameEn: 'Oxygen Level (SpO₂)',
    nameBn: 'অক্সিজেন মাত্রা (SpO₂)',
    type: VitalType.single,
    unit: '%',
    min: 95,
    max: 99,
  ),
  'hr': VitalDefinition(
    key: 'hr',
    nameEn: 'Heart Rate',
    nameBn: 'হৃদস্পন্দন',
    type: VitalType.single,
    unit: 'bpm',
    min: 64,
    max: 96,
  ),
};

/// Canonical English keys are stored internally; translate at display time
/// with [localizedGlucoseContext] in health_format_utils.dart.
const List<String> kGlucoseContexts = [
  'Fasting',
  'Before meal',
  'After meal',
  'Random',
];
