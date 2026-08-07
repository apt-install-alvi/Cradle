import 'package:flutter/material.dart';
import '../../core/models/diagnosis_result.dart';
import '../../core/models/symptom.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_scaffold.dart';
import './widgets/history_card.dart';
import '../ai_risk_assessment/ai_risk_assessment_page.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import 'package:provider/provider.dart';

/// Lists previous symptom check-ins and their assessed risk level.
/// /// In a real app, [_entries] would be loaded from local storage or a
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
    riskLevel: RiskLevel.high,
    reportedSymptoms: [
      SymptomEntry(
        symptom: kAllSymptoms.firstWhere((s) => s.id == 'fever'),
        measurements: const {'value': '101.2'},
      ),
      SymptomEntry(
        symptom: kAllSymptoms.firstWhere((s) => s.id == 'headache'),
      ),
      SymptomEntry(
        symptom: kAllSymptoms.firstWhere((s) => s.id == 'blurred_vision'),
      ),
      SymptomEntry(
        symptom: kAllSymptoms.firstWhere((s) => s.id == 'swelling'),
      ),
    ],
    warningMessage:
        'Your symptoms suggest a condition that can affect you and your baby quickly. Please see a doctor today.',
    warningMessageBn:
        'আপনার উপসর্গগুলো মা ও শিশুর জন্য গুরুতর ঝুঁকির ইঙ্গিত দিচ্ছে। অনুগ্রহ করে আজই একজন চিকিৎসকের সঙ্গে যোগাযোগ করুন।',
    timestamp: DateTime.now(),
  ),

  DiagnosisResult(
    riskLevel: RiskLevel.medium,
    reportedSymptoms: [
      SymptomEntry(
        symptom: kAllSymptoms.firstWhere((s) => s.id == 'loose_motion'),
      ),
      SymptomEntry(
        symptom: kAllSymptoms.firstWhere((s) => s.id == 'nausea'),
      ),
    ],
    warningMessage:
        'Drink fluids and monitor your symptoms; see a doctor if they persist beyond a day.',
    warningMessageBn:
        'পর্যাপ্ত তরল পান করুন এবং আপনার উপসর্গ পর্যবেক্ষণ করুন। এক দিনের বেশি স্থায়ী হলে চিকিৎসকের পরামর্শ নিন।',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
  ),

  DiagnosisResult(
    riskLevel: RiskLevel.low,
    reportedSymptoms: [
      SymptomEntry(
        symptom: kAllSymptoms.firstWhere((s) => s.id == 'headache'),
      ),
    ],
    warningMessage:
        'No action needed — rest and stay hydrated.',
    warningMessageBn:
        'এই মুহূর্তে কোনো তাৎক্ষণিক ঝুঁকি দেখা যাচ্ছে না। বিশ্রাম নিন এবং পর্যাপ্ত পানি পান করুন।',
    timestamp: DateTime.now().subtract(const Duration(days: 8)),
  ),
];
  List<DiagnosisResult> get _filtered {
    if (_query.trim().isEmpty) return _entries;
    final q = _query.toLowerCase();
    return _entries.where((e) {
    return e.riskLevel.name.toLowerCase().contains(q) ||
      e.reportedSymptoms.any(
      (s) => s.symptom.label.toLowerCase().contains(q),
      );
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;


    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(
        selectedIndex: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        const SizedBox(height: 20),
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFAB0A65),
              size: 28,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isBangla ? 'আপনার স্বাস্থ্যের রেকর্ড' : 'Your Health Records',
              style: AppText.headerTitle.copyWith(fontSize: 24),
            ),
          ),
        ],
      ),
          const SizedBox(height: 14),
          _SearchField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            isBangla: isBangla,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Text(
                      isBangla
                          ? 'আপনার অনুসন্ধানের সঙ্গে কোনো রেকর্ড মিলে না।'
                          : 'No records match your search.',
                      style: AppText.subtext,
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final entry = _filtered[index];
                      return HistoryCard(
                        entry: entry,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AiRiskAssessmentPage(result: entry),
                            ),
                          );
                        },
                      );
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
  final bool isBangla;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.isBangla,
  });


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
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 11),
          hintText: isBangla ? 'পূর্বের রেকর্ড খুঁজুন' : 'Search past check-ins',
          hintStyle: TextStyle(fontSize: 13, color: AppColors.muted),
          prefixIcon: Icon(Icons.search, size: 18, color: AppColors.muted),
          prefixIconConstraints: BoxConstraints(minWidth: 30, minHeight: 0),
        ),
      ),
    );
  }
}
