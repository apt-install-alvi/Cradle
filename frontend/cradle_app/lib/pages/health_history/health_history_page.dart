import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';
import './widgets/history_card.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import '../../core/models/diagnosis_result.dart';
import '../../core/models/symptom.dart';
import '../ai_risk_assessment/ai_risk_assessment_page.dart';
import 'package:provider/provider.dart';

class HealthHistoryPage extends StatefulWidget {
  const HealthHistoryPage({super.key});

  @override
  State<HealthHistoryPage> createState() => _HealthHistoryPageState();
}

class _HealthHistoryPageState extends State<HealthHistoryPage> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(
        context,
        listen: false,
      );

      final token = authProvider.token;

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await ApiService.get(
        '/predictions/history',
        token: token,
      );
      debugPrint('HISTORY RESPONSE: $response');

      final List<dynamic> data = response['data'] ?? [];

      setState(() {
        _historyItems = data
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching diagnosis history: $e');

      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered {
    if (_query.trim().isEmpty) {
      return _historyItems;
    }

    final q = _query.toLowerCase();

    return _historyItems.where((item) {
      final risk = (item['risk_level'] ?? '')
          .toString()
          .toLowerCase();

      final symptoms =
          (item['symptoms'] as List<dynamic>? ?? [])
              .map(
                (s) => (s['type'] ?? '')
                    .toString()
                    .toLowerCase(),
              )
              .join(' ');

      return risk.contains(q) || symptoms.contains(q);
    }).toList();
  }

  // ------------------------------------------------------------
  // Reconstruct a DiagnosisResult from a saved history item.
  // ------------------------------------------------------------

  DiagnosisResult _buildDiagnosisResult(
    Map<String, dynamic> item,
  ) {
    final riskString = (item['risk_level'] ?? 'LOW')
        .toString()
        .toUpperCase();

    final RiskLevel riskLevel;

    switch (riskString) {
      case 'HIGH':
      case 'CRITICAL':
        riskLevel = RiskLevel.high;
        break;

      case 'MEDIUM':
      case 'MID':
        riskLevel = RiskLevel.medium;
        break;

      default:
        riskLevel = RiskLevel.low;
    }

    final rawSymptoms =
        (item['symptoms'] as List<dynamic>?) ?? [];

    final rawVitals =
        (item['diagnosis_vitals'] as List<dynamic>?) ?? [];

    final reportedSymptoms = <SymptomEntry>[];

    for (final rawSymptom in rawSymptoms) {
      if (rawSymptom is! Map) continue;

      final symptomName =
    (rawSymptom['type'] ?? '').toString().trim();

if (symptomName.isEmpty) continue;

// The history API stores the symptom's display name
// in `type`, not the Flutter Symptom.id.
Symptom? symptom;

for (final candidate in kAllSymptoms) {
  if (candidate.label.toLowerCase() ==
      symptomName.toLowerCase()) {
    symptom = candidate;
    break;
  }
}

if (symptom == null) {
  debugPrint(
    'History: unknown symptom "$symptomName"',
  );
  continue;
}

      final measurements = <String, String>{};

      // Some history records may already contain measurements
      // inside the symptom object.
      final rawMeasurements =
          rawSymptom['measurements'];

      if (rawMeasurements is Map) {
        rawMeasurements.forEach((key, value) {
          measurements[key.toString()] =
              value.toString();
        });
      }

      // Also reconstruct measurements from diagnosis_vitals.
      for (final rawVital in rawVitals) {
        if (rawVital is! Map) continue;

        final vitalName =
            (rawVital['vital_name'] ?? '').toString();

        final value =
            (rawVital['value'] ?? '').toString();

        if (value.isEmpty) continue;

        switch (vitalName.toLowerCase()) {
          case 'body_temp':
          case 'body temperature':
          case 'temperature':
            measurements['value'] = value;
            break;

          case 'systolic_bp':
          case 'systolic blood pressure':
          case 'systolic':
            measurements['systolic'] = value;
            break;

          case 'diastolic_bp':
          case 'diastolic blood pressure':
          case 'diastolic':
            measurements['diastolic'] = value;
            break;
        }
      }

      reportedSymptoms.add(
        SymptomEntry(
          symptom: symptom,
          measurements: measurements,
        ),
      );
    }

    final timestamp = item['created_at'] != null
        ? DateTime.tryParse(
              item['created_at'].toString(),
            )?.toLocal() ??
            DateTime.now()
        : DateTime.now();

    return DiagnosisResult(
      riskLevel: riskLevel,
      reportedSymptoms: reportedSymptoms,
      warningMessage: _warningForRisk(
        riskLevel,
        isBangla: false,
      ),
      warningMessageBn: _warningForRisk(
        riskLevel,
        isBangla: true,
      ),
      timestamp: timestamp,
      isRealModel:
          item['is_real_model'] == true,
      modelLabel:
          item['model_label']?.toString(),
    );
  }

  String _warningForRisk(
    RiskLevel risk,
    {required bool isBangla}
  ) {
    switch (risk) {
      case RiskLevel.low:
        return isBangla
            ? 'আপনার বর্তমান স্বাস্থ্য পরিমাপ অনুযায়ী ঝুঁকির মাত্রা কম। নিয়মিত স্বাস্থ্য পরীক্ষা চালিয়ে যান।'
            : 'Your current health measurements indicate a low level of risk. Continue with regular prenatal checkups.';

      case RiskLevel.medium:
        return isBangla
            ? 'আপনার কিছু স্বাস্থ্য পরিমাপ মাঝারি ঝুঁকির ইঙ্গিত দিচ্ছে। পরবর্তী চেকআপে আপনার স্বাস্থ্যসেবা প্রদানকারীর সাথে বিষয়টি আলোচনা করুন।'
            : 'Some of your health measurements indicate a moderate level of risk. Discuss these findings with your healthcare provider at your next checkup.';

      case RiskLevel.high:
        return isBangla
            ? 'আপনার স্বাস্থ্য পরিমাপ উচ্চ ঝুঁকির ইঙ্গিত দিচ্ছে। যত দ্রুত সম্ভব আপনার চিকিৎসকের সাথে যোগাযোগ করুন।'
            : 'Your health measurements indicate a high level of risk. Please contact your healthcare provider as soon as possible.';
    }
  }

  void _openHistoryResult(
    Map<String, dynamic> item,
  ) {
    final result = _buildDiagnosisResult(item);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiRiskAssessmentPage(
          result: result,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isBangla =
        context.watch<LanguageProvider>().isBangla;

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
                onPressed: () =>
                    Navigator.of(context).pop(),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  isBangla
                      ? 'ডায়াগনোসিস ইতিহাস'
                      : 'Diagnosis History',
                  style: AppText.headerTitle.copyWith(
                    fontSize: 24,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFFAB0A65),
                ),
                onPressed: _fetchHistory,
              ),
            ],
          ),

          const SizedBox(height: 14),

          _SearchField(
            controller: _searchController,
            onChanged: (v) =>
                setState(() => _query = v),
            isBangla: isBangla,
          ),

          const SizedBox(height: 12),

          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFAB0A65),
                    ),
                  )
                : _filtered.isEmpty
                    ? Center(
                        child: Text(
                          isBangla
                              ? 'আপনার ডায়াগনোসিস ইতিহাস পাওয়া যায়নি।'
                              : 'No diagnosis history found.',
                          style: AppText.subtext,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 180,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (context, index) {
                          final item =
                              _filtered[index];

                          return HistoryCard(
                            item: item,

                            // THIS RESTORES THE CLICKABLE
                            // HISTORY BEHAVIOUR.
                            onTap: () {
                              _openHistoryResult(item);
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
      padding:
          const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: appCardShadow,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 11),
          hintText: isBangla
              ? 'ইতিহাস খুঁজুন (ঝুঁকি বা উপসর্গ)'
              : 'Search history (risk or symptom)',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.muted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            size: 18,
            color: AppColors.muted,
          ),
          prefixIconConstraints:
              const BoxConstraints(
            minWidth: 30,
            minHeight: 0,
          ),
        ),
      ),
    );
  }
}