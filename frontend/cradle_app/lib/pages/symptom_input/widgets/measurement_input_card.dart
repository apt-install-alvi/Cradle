import 'package:flutter/material.dart';
import '../../../core/models/symptom.dart';
import '../../../core/theme/app_theme.dart';
import '../../../providers/language_provider.dart';
import 'package:provider/provider.dart';

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
    final isBangla = context.watch<LanguageProvider>().isBangla;

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
            _label(isBangla),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.roseDark,
            ),
          ),
          const SizedBox(height: 8),
          _buildFields(isBangla),
        ],
      ),
    );
  }

  String _label(bool isBangla) {
    switch (symptom.measurementType!) {
      case MeasurementType.temperature:
        return isBangla ? 'তাপমাত্রা কত?' : "What's the temperature?";
      case MeasurementType.bloodPressure:
        return isBangla ? 'আপনার রক্তচাপ কত?' : "What's your blood pressure reading?";
    }
  }

  Widget _buildFields(bool isBangla) {
    switch (symptom.measurementType!) {
      case MeasurementType.temperature:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MeasurementField(
                initialValue: values['value'],
                isBangla: isBangla,
                fieldType: 'temperature',
                onChanged: (v) => onChanged({...values, 'value': v}),
              ),
            ),
            const SizedBox(width: 10),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: _UnitLabel('°F'),
            ),
          ],
        );
      case MeasurementType.bloodPressure:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _MeasurementField(
                initialValue: values['systolic'],
                isBangla: isBangla,
                fieldType: 'systolic',
                onChanged: (v) => onChanged({...values, 'systolic': v}),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 12, left: 8, right: 8),
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
                isBangla: isBangla,
                fieldType: 'diastolic',
                onChanged: (v) => onChanged({...values, 'diastolic': v}),
              ),
            ),
            const SizedBox(width: 10),
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: _UnitLabel('mmHg'),
            ),
          ],
        );
    }
  }
}

class _MeasurementField extends StatefulWidget {
  final String? initialValue;
  final bool isBangla;
  final String fieldType;
  final ValueChanged<String> onChanged;

  const _MeasurementField({
    required this.initialValue,
    required this.isBangla,
    required this.fieldType,
    required this.onChanged,
  });

  @override
  State<_MeasurementField> createState() => _MeasurementFieldState();
}

class _MeasurementFieldState extends State<_MeasurementField> {
  late TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _validate(_controller.text);
  }

  @override
  void didUpdateWidget(covariant _MeasurementField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue ?? '';
      _validate(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _validate(String input) {
    final trimmed = input.trim();
    String? err;

    if (trimmed.isNotEmpty) {
      final numVal = double.tryParse(trimmed);
      if (numVal == null) {
        err = widget.isBangla ? 'অকার্যকর ইনপুট' : 'Invalid input';
      } else if (widget.fieldType == 'temperature' && (numVal < 70 || numVal > 115)) {
        err = widget.isBangla ? 'অকার্যকর ইনপুট' : 'Invalid input';
      } else if (widget.fieldType == 'systolic' && (numVal < 40 || numVal > 250)) {
        err = widget.isBangla ? 'অকার্যকর ইনপুট' : 'Invalid input';
      } else if (widget.fieldType == 'diastolic' && (numVal < 30 || numVal > 150)) {
        err = widget.isBangla ? 'অকার্যকর ইনপুট' : 'Invalid input';
      }
    }

    setState(() {
      _errorText = err;
    });

    if (err == null) {
      widget.onChanged(trimmed);
    } else {
      widget.onChanged('');
    }
  }

  String get _hintText {
    if (widget.fieldType == 'temperature') return '98.6';
    if (widget.fieldType == 'systolic') return '120';
    if (widget.fieldType == 'diastolic') return '80';
    return widget.isBangla ? 'এখানে লিখুন' : 'Type here';
  }

  @override
  Widget build(BuildContext context) {
    final isInvalid = _errorText != null;

    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: _validate,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isInvalid ? Colors.red.shade900 : const Color(0xFF4A3540),
      ),
      decoration: InputDecoration(
        hintText: _hintText,
        hintStyle: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
        filled: true,
        fillColor: isInvalid ? const Color(0xFFFFF0F0) : const Color(0xFFFBF2F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        errorText: _errorText,
        errorStyle: const TextStyle(
          color: Colors.red,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFF3D6E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isInvalid ? Colors.red : const Color(0xFFF3D6E0),
            width: isInvalid ? 1.5 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isInvalid ? Colors.red : AppColors.rose,
            width: isInvalid ? 2.0 : 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
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
