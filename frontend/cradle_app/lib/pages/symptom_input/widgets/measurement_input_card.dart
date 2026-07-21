import 'package:flutter/material.dart';
import '../../../core/models/symptom.dart';
import '../../../core/theme/app_theme.dart';

/// Follow-up input card shown directly under a measurable symptom once
/// it's selected. Only symptoms with `symptom.isMeasurable == true`
/// (Fever, High BP) ever render this — subjective symptoms like
/// Headache or Nausea never show an input field.
class MeasurementInputCard extends StatelessWidget {
  final Symptom symptom;
  final Map<String, String> values;
  final ValueChanged<Map<String, String>> onChanged;

  MeasurementInputCard({
    super.key,
    required this.symptom,
    required this.values,
    required this.onChanged,
  }) : assert(symptom.isMeasurable);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: const Color(0xFFFFD6E2), width: 1.5),
        boxShadow: appCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.roseDark,
            ),
          ),
          const SizedBox(height: 8),
          _buildFields(),
        ],
      ),
    );
  }

  String get _label {
    switch (symptom.measurementType!) {
      case MeasurementType.temperature:
        return "What's the temperature?";
      case MeasurementType.bloodPressure:
        return "What's your blood pressure reading?";
    }
  }

  Widget _buildFields() {
    switch (symptom.measurementType!) {
      case MeasurementType.temperature:
        return Row(
          children: [
            Expanded(
              child: _MeasurementField(
                initialValue: values['value'],
                onChanged: (v) => onChanged({...values, 'value': v}),
              ),
            ),
            const SizedBox(width: 10),
            const _UnitLabel('°F'),
          ],
        );
      case MeasurementType.bloodPressure:
        return Row(
          children: [
            Expanded(
              child: _MeasurementField(
                initialValue: values['systolic'],
                onChanged: (v) => onChanged({...values, 'systolic': v}),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '/',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted,
                ),
              ),
            ),
            Expanded(
              child: _MeasurementField(
                initialValue: values['diastolic'],
                onChanged: (v) => onChanged({...values, 'diastolic': v}),
              ),
            ),
            const SizedBox(width: 10),
            const _UnitLabel('mmHg'),
          ],
        );
    }
  }
}

class _MeasurementField extends StatelessWidget {
  final String? initialValue;
  final ValueChanged<String> onChanged;

  const _MeasurementField({required this.initialValue, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4A3540),
      ),
      decoration: InputDecoration(
        hintText: 'Type here',
        hintStyle: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: const Color(0xFFFBF2F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF3D6E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF3D6E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.rose, width: 1.5),
        ),
      ),
    );
  }
}

class _UnitLabel extends StatelessWidget {
  final String unit;
  const _UnitLabel(this.unit);

  @override
  Widget build(BuildContext context) {
    return Text(
      unit,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: AppColors.roseDark,
      ),
    );
  }
}
