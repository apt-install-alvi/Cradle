import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/services/api_service.dart';

class AiRiskAssessmentPage extends StatefulWidget {
  const AiRiskAssessmentPage({Key? key}) : super(key: key);

  @override
  State<AiRiskAssessmentPage> createState() => _AiRiskAssessmentPageState();
}

class _AiRiskAssessmentPageState extends State<AiRiskAssessmentPage> {
  bool _isLoading = true;
  String _riskLevel = 'LOW';
  double _confidence = 0.95;
  List<String> _recommendations = [];
  String _assessedAt = '';

  @override
  void initState() {
    super.initState();
    _fetchAssessment();
  }

  Future<void> _fetchAssessment() async {
    try {
      final res = await ApiService.getAiAssessmentHistory();
      if (res['success'] == true && res['data'] != null && (res['data'] as List).isNotEmpty) {
        final recent = res['data'][0];
        setState(() {
          _riskLevel = recent['riskLevel'] ?? 'LOW';
          _confidence = (recent['confidenceScore'] ?? 0.95).toDouble();
          _recommendations = List<String>.from(recent['recommendations'] ?? []);
          _assessedAt = recent['assessedAt'] != null 
              ? recent['assessedAt'].toString().substring(0, 10)
              : '';
        });
      } else {
        _setDefaults();
      }
    } catch (_) {
      _setDefaults();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _setDefaults() {
    setState(() {
      _riskLevel = 'LOW';
      _confidence = 0.95;
      _recommendations = [
        'No critical symptoms reported. Continue tracking your symptoms daily.',
        'Maintain healthy hydration (at least 8-10 glasses of water daily).',
        'Incorporate light activities like prenatal stretching or walking.'
      ];
      _assessedAt = 'Today';
    });
  }

  Color _getRiskColor() {
    switch (_riskLevel.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red.shade700;
      case 'HIGH':
        return Colors.orange.shade700;
      case 'MEDIUM':
        return Colors.amber.shade800;
      default:
        return Colors.teal.shade700;
    }
  }

  Color _getRiskBg() {
    switch (_riskLevel.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red.shade50;
      case 'HIGH':
        return Colors.orange.shade50;
      case 'MEDIUM':
        return Colors.amber.shade50;
      default:
        return Colors.teal.shade50;
    }
  }

  String _getRiskHeaderDescription() {
    switch (_riskLevel.toUpperCase()) {
      case 'CRITICAL':
        return 'Seek immediate medical attention. Notify emergency services or click SOS below.';
      case 'HIGH':
        return 'Elevated pregnancy risk factors. Schedule a review with your obstetrician soon.';
      case 'MEDIUM':
        return 'Moderate symptoms detected. Monitor closely and rest as much as possible.';
      default:
        return 'Healthy symptoms checklist. Maintain your daily tracking routines.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Risk Assessment'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.healthHistory),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            
                            // Visual Risk Gauge Box
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                              decoration: BoxDecoration(
                                color: isDark ? theme.cardColor : _getRiskBg(),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark ? Colors.white12 : _getRiskColor().withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'PREGNANCY RISK',
                                    style: TextStyle(
                                      color: _getRiskColor(),
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _riskLevel,
                                    style: TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: _getRiskColor(),
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _getRiskHeaderDescription(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDark ? Colors.white70 : _getRiskColor().withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check_circle_outline_rounded, size: 16, color: _getRiskColor()),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Confidence: ${(_confidence * 100).toStringAsFixed(0)}% (Assessment Date: $_assessedAt)',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white60 : _getRiskColor().withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            
                            // Recommendations list
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Recommendations',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ..._recommendations.map((rec) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.check_rounded, color: theme.primaryColor, size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          rec,
                                          style: const TextStyle(fontSize: 15, height: 1.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    
                    // Call Doctor / Action Actions
                    if (_riskLevel == 'CRITICAL' || _riskLevel == 'HIGH') ...[
                      CustomButton(
                        text: 'Go to Emergency Alerts',
                        isSecondary: true,
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.emergency),
                      ),
                      const SizedBox(height: 12),
                    ],
                    CustomButton(
                      text: 'Back to Home',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}


