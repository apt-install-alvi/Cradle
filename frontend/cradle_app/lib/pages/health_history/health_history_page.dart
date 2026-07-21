import 'package:flutter/material.dart';
import '../../core/models/diagnosis_result.dart';
import '../../core/models/symptom.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_scaffold.dart';
import './widgets/history_card.dart';
import '../../core/widgets/bottom_nav.dart';

/// Lists past symptom check-ins with their diagnosis and risk level.
/// In a real app, [_entries] would be loaded from local storage or a
/// backend rather than hard-coded here.
class HealthHistoryPage extends StatefulWidget {
  const HealthHistoryPage({super.key});

  @override
  State<HealthHistoryPage> createState() => _HealthHistoryPageState();
}

class _HealthHistoryPageState extends State<HealthHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  // TODO: replace with entries loaded from persistent storage / an API.
  final List<DiagnosisResult> _entries = [
    DiagnosisResult(
      diagnosisName: 'Possible Preeclampsia',
      riskLevel: RiskLevel.high,
      reportedSymptoms: [
        SymptomEntry(
          symptom: kAllSymptoms.firstWhere((s) => s.id == 'fever'),
          measurements: const {'value': '101.2'},
        ),
        SymptomEntry(symptom: kAllSymptoms.firstWhere((s) => s.id == 'headache')),
        SymptomEntry(
          symptom: kAllSymptoms.firstWhere((s) => s.id == 'blurred_vision'),
        ),
        SymptomEntry(symptom: kAllSymptoms.firstWhere((s) => s.id == 'swelling')),
      ],
      warningMessage:
          'Your symptoms suggest a condition that can affect you and your '
          'baby quickly. Please see a doctor today.',
      timestamp: DateTime.now(),
    ),
    DiagnosisResult(
      diagnosisName: 'Mild Dehydration',
      riskLevel: RiskLevel.medium,
      reportedSymptoms: [
        SymptomEntry(symptom: kAllSymptoms.firstWhere((s) => s.id == 'loose_motion')),
        SymptomEntry(symptom: kAllSymptoms.firstWhere((s) => s.id == 'nausea')),
      ],
      warningMessage:
          'Drink fluids and monitor your symptoms; see a doctor if they '
          'persist beyond a day.',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
    ),
    DiagnosisResult(
      diagnosisName: 'Normal Pregnancy Fatigue',
      riskLevel: RiskLevel.low,
      reportedSymptoms: [
        SymptomEntry(symptom: kAllSymptoms.firstWhere((s) => s.id == 'headache')),
      ],
      warningMessage: 'No action needed — rest and stay hydrated.',
      timestamp: DateTime.now().subtract(const Duration(days: 8)),
    ),
  ];

  List<DiagnosisResult> get _filtered {
    if (_query.trim().isEmpty) return _entries;
    final q = _query.toLowerCase();
    return _entries.where((e) {
      return e.diagnosisName.toLowerCase().contains(q) ||
          e.reportedSymptoms
              .any((s) => s.symptom.label.toLowerCase().contains(q));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
        bottomNavigationBar: const DashboardBottomNav(
        selectedIndex: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
      Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        icon: const Icon(
          Icons.arrow_back,
          color: Color(0xFFAB0A65),
          size: 28,
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    const SizedBox(width: 8),
          Text('Your History', style: AppText.headerTitle.copyWith(fontSize: 24)),
          const SizedBox(height: 14),
          _SearchField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No check-ins match your search.',
                      style: AppText.subtext,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      return HistoryCard(entry: _filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: appCardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 13, color: AppColors.ink),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 11),
          hintText: 'Search past check-ins',
          hintStyle: TextStyle(fontSize: 13, color: AppColors.muted),
          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.muted),
          prefixIconConstraints: BoxConstraints(minWidth: 30, minHeight: 0),
        ),
      ),
    );
  }
}
