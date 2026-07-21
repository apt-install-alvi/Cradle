import 'package:cradle_app/pages/ai_risk_assessment/ai_risk_assessment_page.dart';
import 'package:cradle_app/pages/health_history/health_history_page.dart';
import 'package:flutter/material.dart';
import '../../core/models/diagnosis_result.dart';
import '../../core/models/symptom.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_scaffold.dart';
import './widgets/measurement_input_card.dart';
import './widgets/symptom_card.dart';
import '../../core/widgets/bottom_nav.dart';

/// First screen of the flow: the user selects symptoms from rows of
/// cards. Only symptoms that make sense to measure — Fever and High BP —
/// expand into a follow-up input card; subjective symptoms like
/// Headache or Nausea are selectable but never show an input field.
/// Tapping "Next" reveals another row under a "What else?" heading;
/// "Done" moves to the diagnosis screen.
class SymptomInputPage extends StatefulWidget {
  const SymptomInputPage({super.key});

  @override
  State<SymptomInputPage> createState() => _SymptomInputPageState();
}

class _SymptomInputPageState extends State<SymptomInputPage> {
  static const int _batchSize = 4;

  final List<Symptom> _remainingPool = List.of(kAllSymptoms);
  final List<List<Symptom>> _batches = [];
  final Set<String> _selectedIds = {};
  final Map<String, Map<String, String>> _measurementValues = {};

  @override
  void initState() {
    super.initState();
    _revealNextBatch();
  }

  void _revealNextBatch() {
    if (_remainingPool.isEmpty) return;
    final take = _remainingPool.take(_batchSize).toList();
    _remainingPool.removeRange(0, take.length);
    setState(() => _batches.add(take));
  }

  void _toggleSymptom(Symptom symptom) {
    setState(() {
      if (_selectedIds.contains(symptom.id)) {
        _selectedIds.remove(symptom.id);
        _measurementValues.remove(symptom.id);
      } else {
        _selectedIds.add(symptom.id);
        if (symptom.isMeasurable) {
          _measurementValues[symptom.id] = {};
        }
      }
    });
  }

  void _onDone() {
    final entries = _selectedIds.map((id) {
      final symptom = kAllSymptoms.firstWhere((s) => s.id == id);
      return SymptomEntry(
        symptom: symptom,
        measurements: _measurementValues[id] ?? const {},
      );
    }).toList();

    // NOTE: This mock result stands in for a real backend/AI call, which
    // would take `entries` and return an actual diagnosis + risk level.
    final result = DiagnosisResult(
      diagnosisName: 'Possible Preeclampsia',
      riskLevel: RiskLevel.high,
      reportedSymptoms: entries,
      warningMessage:
          'Your symptoms suggest a condition that can affect you and your '
          'baby quickly. Please see a doctor today.',
      timestamp: DateTime.now(),
    );

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AiRiskAssessmentPage(result: result)),
    );
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HealthHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasMore = _remainingPool.isNotEmpty;

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(
      selectedIndex: 1,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            _Header(onHistoryTap: _openHistory),
            const SizedBox(height: 4),
            const Text(
              "Select all that apply — you can add details next.",
              style: AppText.subtext,
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < _batches.length; i++) ...[
              if (i > 0) ...[
                const SizedBox(height: 4),
                Text('What else?', style: AppText.sectionHeading),
                const SizedBox(height: 12),
              ],
              _SymptomGrid(
                symptoms: _batches[i],
                selectedIds: _selectedIds,
                measurementValues: _measurementValues,
                onTap: _toggleSymptom,
                onMeasurementChanged: (id, values) {
                  setState(() => _measurementValues[id] = values);
                },
              ),
            ],
            const SizedBox(height: 6),
            Row(
              children: [
                if (hasMore) ...[
                  Expanded(
                    child: AppButton(
                      label: 'Next',
                      variant: AppButtonVariant.outlined,
                      onPressed: _revealNextBatch,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: AppButton(
                    label: 'Done',
                    onPressed: _selectedIds.isEmpty ? null : _onDone,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onHistoryTap;
  const _Header({required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'What problems are you facing?',
            style: AppText.headerTitle,
          ),
        ),
        Material(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onHistoryTap,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: appCardShadow,
              ),
              child: const Icon(Icons.history, size: 19, color: AppColors.roseDark),
            ),
          ),
        ),
      ],
    );
  }
}

/// A 2-column grid of symptom cards. Any measurable symptom that is
/// currently selected shows its [MeasurementInputCard] spanning both
/// columns directly beneath the grid.
class _SymptomGrid extends StatelessWidget {
  final List<Symptom> symptoms;
  final Set<String> selectedIds;
  final Map<String, Map<String, String>> measurementValues;
  final ValueChanged<Symptom> onTap;
  final void Function(String symptomId, Map<String, String> values)
      onMeasurementChanged;

  const _SymptomGrid({
    required this.symptoms,
    required this.selectedIds,
    required this.measurementValues,
    required this.onTap,
    required this.onMeasurementChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          for (int i = 0; i < symptoms.length; i += 2) ...[
            Builder(
              builder: (_) {
                final left = symptoms[i];
                final Symptom? right =
                    i + 1 < symptoms.length ? symptoms[i + 1] : null;

                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SymptomCard(
                            symptom: left,
                            selected: selectedIds.contains(left.id),
                            onTap: () => onTap(left),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: right == null
                              ? const SizedBox()
                              : SymptomCard(
                                  symptom: right,
                                  selected: selectedIds.contains(right.id),
                                  onTap: () => onTap(right),
                                ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (left.isMeasurable &&
                        selectedIds.contains(left.id))
                      MeasurementInputCard(
                        symptom: left,
                        values:
                            measurementValues[left.id] ?? const {},
                        onChanged: (values) =>
                            onMeasurementChanged(left.id, values),
                      ),

                    if (right != null &&
                        right.isMeasurable &&
                        selectedIds.contains(right.id))
                      MeasurementInputCard(
                        symptom: right,
                        values:
                            measurementValues[right.id] ?? const {},
                        onChanged: (values) =>
                            onMeasurementChanged(right.id, values),
                      ),

                    if (i + 2 < symptoms.length)
                      const SizedBox(height: 12),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

