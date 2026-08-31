import 'package:cradle_app/pages/ai_risk_assessment/ai_risk_assessment_page.dart';
import 'package:cradle_app/pages/health_history/health_history_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/diagnosis_result.dart';
import '../../core/models/symptom.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/language_toggle.dart';
import './widgets/symptom_card.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import 'package:provider/provider.dart';

/// Class for mapping field metadata for dynamic inputs
class _FieldMeta {
  final String label;
  final String hint;
  final String unit;
  final IconData icon;

  const _FieldMeta({
    required this.label,
    required this.hint,
    required this.unit,
    required this.icon,
  });
}

class SymptomInputPage extends StatefulWidget {
  const SymptomInputPage({super.key});

  @override
  State<SymptomInputPage> createState() => _SymptomInputPageState();
}

class _SymptomInputPageState extends State<SymptomInputPage> {
  final Set<String> _selectedIds = {};
  bool _isLoading = false;

  // Controllers for parameters in the XGBoost dataset (excluding age, which is fetched from profile)
  final Map<String, TextEditingController> _paramControllers = {
    'body_temp': TextEditingController(),
    'heart_rate': TextEditingController(),
    'systolic_bp': TextEditingController(),
    'diastolic_bp': TextEditingController(),
    'bmi': TextEditingController(),
    'hba1c': TextEditingController(),
    'fasting_glucose': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (var controller in _paramControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleSymptom(Symptom symptom) {
    setState(() {
      if (_selectedIds.contains(symptom.id)) {
        _selectedIds.remove(symptom.id);
      } else {
        _selectedIds.add(symptom.id);
      }
    });
  }

  // Find the list of features needed based on union of selected symptoms (filtering out age)
  List<String> get _requiredFeatures {
    final selectedSymptoms = _selectedIds
        .map((id) => kAllSymptoms.firstWhere((s) => s.id == id))
        .toList();
    final features = selectedSymptoms.expand((s) => s.requiredFeatures).toSet().toList();
    features.remove('age');
    return features;
  }

  Future<void> _onDone() async {
    setState(() => _isLoading = true);

    // Identify which parameters of the 7 user-input fields were not selected by the symptoms
    final allParams = ['body_temp', 'heart_rate', 'systolic_bp', 'diastolic_bp', 'bmi', 'hba1c', 'fasting_glucose'];
    final reqFeatures = _requiredFeatures;
    final unselectedFeatures = allParams.where((param) => !reqFeatures.contains(param)).toList();

    if (unselectedFeatures.isNotEmpty) {
      await _showUnselectedParamsDialog(unselectedFeatures);
    } else {
      await _executePrediction();
    }
  }

  Future<void> _showUnselectedParamsDialog(List<String> unselectedFeatures) async {
    final isBangla = context.read<LanguageProvider>().isBangla;

    // Prepopulate dialog input controllers with healthy defaults
    final Map<String, TextEditingController> dialogControllers = {};
    final defaults = {
      'body_temp': '98.6',
      'heart_rate': '75',
      'systolic_bp': '120',
      'diastolic_bp': '80',
      'bmi': '22.0',
      'hba1c': '5.4',
      'fasting_glucose': '85',
    };

    for (var feature in unselectedFeatures) {
      final parentText = _paramControllers[feature]!.text;
      dialogControllers[feature] = TextEditingController(
        text: parentText.isNotEmpty ? parentText : (defaults[feature] ?? ''),
      );
    }

    final metadata = {
      'body_temp': _FieldMeta(
        label: isBangla ? 'শরীরের তাপমাত্রা (Temp)' : 'Body Temperature',
        hint: 'e.g. 98.6',
        unit: '°F',
        icon: Icons.thermostat,
      ),
      'heart_rate': _FieldMeta(
        label: isBangla ? 'হার্ট রেট (Heart Rate)' : 'Heart Rate',
        hint: 'e.g. 80',
        unit: 'bpm',
        icon: Icons.favorite,
      ),
      'systolic_bp': _FieldMeta(
        label: isBangla ? 'সিস্টোলিক রক্তচাপ' : 'Systolic BP',
        hint: 'e.g. 120',
        unit: 'mmHg',
        icon: Icons.compress,
      ),
      'diastolic_bp': _FieldMeta(
        label: isBangla ? 'ডায়াস্টোলিক রক্তচাপ' : 'Diastolic BP',
        hint: 'e.g. 80',
        unit: 'mmHg',
        icon: Icons.expand,
      ),
      'bmi': _FieldMeta(
        label: isBangla ? 'বিএমআই (BMI)' : 'BMI (kg/m²)',
        hint: 'e.g. 23.5',
        unit: 'kg/m²',
        icon: Icons.accessibility_new,
      ),
      'hba1c': _FieldMeta(
        label: isBangla ? 'এইচবিএ১সি (HbA1c)' : 'Blood Glucose (HbA1c)',
        hint: 'e.g. 5.7',
        unit: '%',
        icon: Icons.water_drop_outlined,
      ),
      'fasting_glucose': _FieldMeta(
        label: isBangla ? 'খালি পেটে সুগার' : 'Fasting Glucose',
        hint: 'e.g. 90',
        unit: 'mg/dL',
        icon: Icons.bloodtype,
      ),
    };

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
            side: const BorderSide(color: Color(0xFFFFD6E2), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.roseDark, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isBangla ? 'অতিরিক্ত স্বাস্থ্য তথ্য' : 'Unselected Health Vitals',
                  style: AppText.sectionHeading,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBangla
                        ? 'নিচের প্যারামিটারগুলো আপনার উপসর্গের সাথে সরাসরি সম্পর্কিত নয়। সঠিক এআই মূল্যায়নের জন্য এগুলো স্বাভাবিক (Default) মান হিসেবে পাঠানো হবে। আপনি চাইলে মানগুলো পরিবর্তন করতে পারেন:'
                        : 'The following vitals are not relevant to your selected symptoms. To ensure accurate prediction, they will submit with healthy defaults. You can modify them below if desired:',
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFF4A3540),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...unselectedFeatures.map((feature) {
                    final meta = metadata[feature]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meta.label,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.roseDark,
                            ),
                          ),
                          const SizedBox(height: 5),
                          TextFormField(
                            controller: dialogControllers[feature],
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A3540),
                            ),
                            decoration: InputDecoration(
                              hintText: meta.hint,
                              hintStyle: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                              filled: true,
                              fillColor: const Color(0xFFFBF2F5),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              prefixIcon: Icon(meta.icon, size: 18, color: AppColors.roseDark),
                              suffixText: meta.unit,
                              suffixStyle: const TextStyle(color: AppColors.roseDark, fontWeight: FontWeight.w800, fontSize: 11),
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
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                isBangla ? 'বাতিল' : 'Cancel',
                style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Save updated controllers back to main list
                for (var feature in unselectedFeatures) {
                  _paramControllers[feature]!.text = dialogControllers[feature]!.text;
                }
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.roseDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                isBangla ? 'নিশ্চিত করুন' : 'Confirm & Proceed',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    // Clean up local dialog controllers
    for (var controller in dialogControllers.values) {
      controller.dispose();
    }

    if (confirmed == true) {
      await _executePrediction();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _executePrediction() async {
    final isBangla = context.read<LanguageProvider>().isBangla;
    final auth = context.read<AuthProvider>();

    // 1. Fetch age from mother profile if available, default to 25.0
    final profile = auth.profile;
    final ageVal = profile['age'] ?? profile['Age'];
    final double age = ageVal != null ? (double.tryParse(ageVal.toString()) ?? 25.0) : 25.0;

    // 2. Read input values and assign standard defaults for empty fields
    final double temp = double.tryParse(_paramControllers['body_temp']!.text) ?? 98.6;
    final double hr = double.tryParse(_paramControllers['heart_rate']!.text) ?? 75.0;
    final double sys = double.tryParse(_paramControllers['systolic_bp']!.text) ?? 120.0;
    final double dia = double.tryParse(_paramControllers['diastolic_bp']!.text) ?? 80.0;
    final double bmi = double.tryParse(_paramControllers['bmi']!.text) ?? 22.0;
    final double hba1c = double.tryParse(_paramControllers['hba1c']!.text) ?? 5.4;
    final double fasting = double.tryParse(_paramControllers['fasting_glucose']!.text) ?? 85.0;

    // 2. Prepare symptom entries for the local UI models (to ensure compatibility with assessment screen)
    final entries = _selectedIds.map((id) {
      final symptom = kAllSymptoms.firstWhere((s) => s.id == id);
      
      // Inject measurements into SymptomEntry so standard labels print details
      final Map<String, String> measurements = {};
      if (id == 'maternal_infection' || id == 'gastroenteritis') {
        measurements['value'] = temp.toStringAsFixed(1);
      } else if (id == 'preeclampsia' || id == 'chronic_hypertension' || id == 'hypertensive_encephalopathy') {
        measurements['systolic'] = sys.toStringAsFixed(0);
        measurements['diastolic'] = dia.toStringAsFixed(0);
      }
      return SymptomEntry(symptom: symptom, measurements: measurements);
    }).toList();

    // 3. Prepare payload for the API endpoints
    final symptomsListPayload = _selectedIds.map((id) {
      final symptom = kAllSymptoms.firstWhere((s) => s.id == id);
      double severity = 5.0; // standard baseline severity for subjective ones
      
      // Scale severity dynamically for measurable vitals
      if (id == 'maternal_infection' || id == 'gastroenteritis') {
        severity = ((temp - 98.0) * 1.5).clamp(1.0, 10.0);
      } else if (id == 'preeclampsia' || id == 'chronic_hypertension' || id == 'hypertensive_encephalopathy') {
        severity = ((sys - 110.0) * 0.2).clamp(1.0, 10.0);
      }
      return {
        'name': symptom.label,
        'severity': severity,
      };
    }).toList();

    final featuresPayload = {
      'age': age,
      'body_temp': temp,
      'heart_rate': hr,
      'systolic_bp': sys,
      'diastolic_bp': dia,
      'bmi': bmi,
      'hba1c': hba1c,
      'fasting_glucose': fasting,
    };

    DiagnosisResult? result;

    // Try backend assessment API first
    if (auth.isLoggedIn && auth.token != null) {
      try {
        // Step A: Log the symptoms session
        final symptomsLogResponse = await ApiService.post(
          '/symptoms', 
          {'symptomsList': symptomsListPayload}, 
          token: auth.token
        );
        
        final session = symptomsLogResponse['data']['session'];
        final sessionId = session['id'];

        // Step B: Submit features and trigger AI risk assessment
        final assessmentResponse = await ApiService.post(
          '/predictions/assess',
          {
            'symptomLogId': sessionId,
            'symptoms': symptomsListPayload,
            'features': featuresPayload,
          },
          token: auth.token,
        );

        final assessmentData = assessmentResponse['data'];
        final String riskStr = (assessmentData['risk_level'] ?? 
            assessmentData['prediction_data']?['riskLevel'] ?? 'LOW').toString().toUpperCase();
        
        RiskLevel parsedRisk = RiskLevel.low;
        if (riskStr == 'HIGH' || riskStr == 'CRITICAL') {
          parsedRisk = RiskLevel.high;
        } else if (riskStr == 'MEDIUM') {
          parsedRisk = RiskLevel.medium;
        }

        final predictionData = assessmentData['prediction_data'];
        final bool isRealModel = predictionData?['isRealModel'] ?? false;
        final String? modelLabel = predictionData?['modelLabel'];

        final List recommendations = predictionData?['recommendations'] ?? [];
        final String warningEng = recommendations.isNotEmpty 
            ? recommendations.join('\n') 
            : 'Maternal health risk is evaluated.';
        
        final String warningBn = isBangla
            ? 'আপনার তথ্যের ভিত্তিতে স্বাস্থ্যের ঝুঁকি মূল্যায়ন করা হয়েছে।'
            : warningEng;

        result = DiagnosisResult(
          riskLevel: parsedRisk,
          reportedSymptoms: entries,
          warningMessage: warningEng,
          warningMessageBn: warningBn,
          timestamp: DateTime.now(),
          isRealModel: isRealModel,
          modelLabel: modelLabel,
        );
      } catch (e) {
        debugPrint('[API Error] Failed to fetch prediction from backend: $e. Running local fallback.');
      }
    }

    // Local Fallback if API fails or token is null
    if (result == null) {
      final RiskLevel localRisk = _evaluateLocalRisk(
        age: age,
        temp: temp,
        hr: hr,
        sys: sys,
        dia: dia,
        bmi: bmi,
        hba1c: hba1c,
        fasting: fasting,
      );

      String localWarningEng = '';
      String localWarningBn = '';
      if (localRisk == RiskLevel.high) {
        localWarningEng = 'High pregnancy risk detected. Please consult your physician or visit the nearest healthcare center immediately.';
        localWarningBn = 'উচ্চ ঝুঁকি সনাক্ত করা হয়েছে। অবিলম্বে চিকিৎসকের পরামর্শ নিন বা নিকটস্থ হাসপাতালে যোগাযোগ করুন।';
      } else if (localRisk == RiskLevel.medium) {
        localWarningEng = 'Moderate risk detected. Monitor your vitals daily and schedule a check-up with your doctor.';
        localWarningBn = 'মাঝারি ঝুঁকি সনাক্ত করা হয়েছে। নিয়মিত ভাইটাল পর্যবেক্ষণ করুন এবং দ্রুত ডাক্তারের পরামর্শ নিন।';
      } else {
        localWarningEng = 'Low Risk. Your pregnancy vitals appear stable. Continue routine checks and stay hydrated.';
        localWarningBn = 'নিম্ন ঝুঁকি। আপনার গর্ভকালীন শারীরিক মাপসমূহ স্থিতিশীল দেখাচ্ছে। সাধারণ নিয়মাবলি মেনে চলুন।';
      }

      result = DiagnosisResult(
        riskLevel: localRisk,
        reportedSymptoms: entries,
        warningMessage: localWarningEng,
        warningMessageBn: localWarningBn,
        timestamp: DateTime.now(),
      );
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AiRiskAssessmentPage(result: result!),
        ),
      );
    }
  }

  RiskLevel _evaluateLocalRisk({
    required double age,
    required double temp,
    required double hr,
    required double sys,
    required double dia,
    required double bmi,
    required double hba1c,
    required double fasting,
  }) {
    if (sys >= 160 || dia >= 110 || temp >= 103.0) {
      return RiskLevel.high; // Critical limits
    }
    if (sys >= 140 || dia >= 90 || temp >= 100.4 || hr >= 120 || hr < 50 || hba1c >= 6.5 || fasting >= 126.0) {
      return RiskLevel.high;
    }
    if (sys >= 130 || dia >= 85 || temp <= 95.0 || hr >= 100 || hr < 60 || hba1c >= 5.7 || fasting >= 95.0 || bmi >= 35.0 || bmi < 18.5 || age >= 35 || age < 18) {
      return RiskLevel.medium;
    }
    return RiskLevel.low;
  }

  void _openHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HealthHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final reqFeatures = _requiredFeatures;

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(
        selectedIndex: 2,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            _Header(onHistoryTap: _openHistory),
            const SizedBox(height: 4),
            Text(
              isBangla
                  ? 'আপনার কী ধরণের শারীরিক সমস্যা বা অসুবিধা হচ্ছে তা নির্বাচন করুন:'
                  : 'Select what difficulties or sicknesses you are facing:',
              style: AppText.subtext.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 16),
            _SymptomGrid(
              symptoms: kAllSymptoms,
              selectedIds: _selectedIds,
              onTap: _toggleSymptom,
            ),
            const SizedBox(height: 6),
            
            // Dynamic parameter input section
            if (_selectedIds.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 24),
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
                    Row(
                      children: [
                        const Icon(Icons.analytics_outlined, color: AppColors.roseDark, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isBangla ? 'প্রয়োজনীয় স্বাস্থ্য ভাইটাল' : 'Required Health Vitals',
                            style: AppText.sectionHeading,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isBangla
                          ? 'সঠিক ঝুঁকি স্তর পেতে অনুগ্রহ করে নিচের প্রয়োজনীয় প্যারামিটারগুলো প্রদান করুন।'
                          : 'Please fill out these parameters to help the AI model evaluate your risk level accurately.',
                      style: AppText.subtext,
                    ),
                    const SizedBox(height: 16),
                    _buildParameterFields(reqFeatures, isBangla),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                  border: Border.all(color: const Color(0xFFFFD6E2).withOpacity(0.5), width: 1.5),
                  boxShadow: appCardShadow,
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_box_outlined, color: AppColors.muted.withOpacity(0.5), size: 36),
                    const SizedBox(height: 8),
                    Text(
                      isBangla
                          ? 'শুরু করতে উপরে আপনার শারীরিক সমস্যা নির্বাচন করুন।'
                          : 'Select your difficulties above to begin.',
                      textAlign: TextAlign.center,
                      style: AppText.subtext,
                    ),
                  ],
                ),
              ),
            ],
            
            _isLoading 
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.roseDark),
                    ),
                  )
                : AppButton(
                    label: isBangla ? 'সম্পন্ন' : 'Done',
                    onPressed: _selectedIds.isEmpty ? null : _onDone,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterFields(List<String> requiredFeatures, bool isBangla) {
    final metadata = {
      'age': _FieldMeta(
        label: isBangla ? 'বয়স (Age)' : 'Age (Years)',
        hint: 'e.g. 24',
        unit: isBangla ? 'বছর' : 'yrs',
        icon: Icons.calendar_today,
      ),
      'body_temp': _FieldMeta(
        label: isBangla ? 'শরীরের তাপমাত্রা (Temp)' : 'Body Temperature',
        hint: 'e.g. 98.6',
        unit: '°F',
        icon: Icons.thermostat,
      ),
      'heart_rate': _FieldMeta(
        label: isBangla ? 'হার্ট রেট (Heart Rate)' : 'Heart Rate',
        hint: 'e.g. 80',
        unit: 'bpm',
        icon: Icons.favorite,
      ),
      'systolic_bp': _FieldMeta(
        label: isBangla ? 'সিস্টোলিক রক্তচাপ' : 'Systolic BP',
        hint: 'e.g. 120',
        unit: 'mmHg',
        icon: Icons.compress,
      ),
      'diastolic_bp': _FieldMeta(
        label: isBangla ? 'ডায়াস্টোলিক রক্তচাপ' : 'Diastolic BP',
        hint: 'e.g. 80',
        unit: 'mmHg',
        icon: Icons.expand,
      ),
      'bmi': _FieldMeta(
        label: isBangla ? 'বিএমআই (BMI)' : 'BMI (kg/m²)',
        hint: 'e.g. 23.5',
        unit: 'kg/m²',
        icon: Icons.accessibility_new,
      ),
      'hba1c': _FieldMeta(
        label: isBangla ? 'এইচবিএ১সি (HbA1c)' : 'Blood Glucose (HbA1c)',
        hint: 'e.g. 40',
        unit: '%',
        icon: Icons.water_drop_outlined,
      ),
      'fasting_glucose': _FieldMeta(
        label: isBangla ? 'খালি পেটে সুগার' : 'Fasting Glucose',
        hint: 'e.g. 5.8',
        unit: 'mg/dL',
        icon: Icons.bloodtype,
      ),
    };

    final pairs = [
      ['age', 'bmi'],
      ['systolic_bp', 'diastolic_bp'],
      ['body_temp', 'heart_rate'],
      ['fasting_glucose', 'hba1c'],
    ];

    final renderedFields = <Widget>[];

    for (final pair in pairs) {
      final f1 = pair[0];
      final f2 = pair[1];
      final req1 = requiredFeatures.contains(f1);
      final req2 = requiredFeatures.contains(f2);

      if (req1 && req2) {
        renderedFields.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(child: _buildSingleField(f1, metadata[f1]!, isBangla)),
                const SizedBox(width: 12),
                Expanded(child: _buildSingleField(f2, metadata[f2]!, isBangla)),
              ],
            ),
          ),
        );
      } else if (req1) {
        renderedFields.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSingleField(f1, metadata[f1]!, isBangla),
          ),
        );
      } else if (req2) {
        renderedFields.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildSingleField(f2, metadata[f2]!, isBangla),
          ),
        );
      }
    }

    return Column(children: renderedFields);
  }

  Widget _buildSingleField(String key, _FieldMeta meta, bool isBangla) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meta.label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.roseDark,
          ),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: _paramControllers[key],
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4A3540),
          ),
          decoration: InputDecoration(
            hintText: meta.hint,
            hintStyle: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
            filled: true,
            fillColor: const Color(0xFFFBF2F5),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            prefixIcon: Icon(meta.icon, size: 18, color: AppColors.roseDark),
            suffixText: meta.unit,
            suffixStyle: const TextStyle(color: AppColors.roseDark, fontWeight: FontWeight.w800, fontSize: 12),
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
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onHistoryTap;
  const _Header({required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            isBangla ? 'আপনার কী ধরণের সমস্যা হচ্ছে?' : 'What difficulties are you facing?',
            style: AppText.headerTitle,
          ),
        ),
        const LanguageToggle(),
        const SizedBox(width: 12),
        Material(
          color: Colors.white,
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
              child: const Icon(Icons.history, size: 24, color: AppColors.roseDark),
            ),
          ),
        ),
      ],
    );
  }
}

class _SymptomGrid extends StatelessWidget {
  final List<Symptom> symptoms;
  final Set<String> selectedIds;
  final ValueChanged<Symptom> onTap;

  const _SymptomGrid({
    required this.symptoms,
    required this.selectedIds,
    required this.onTap,
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
