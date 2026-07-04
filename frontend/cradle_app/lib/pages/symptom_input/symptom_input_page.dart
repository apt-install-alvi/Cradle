import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../core/services/api_service.dart';

class SymptomInputPage extends StatefulWidget {
  const SymptomInputPage({Key? key}) : super(key: key);

  @override
  State<SymptomInputPage> createState() => _SymptomInputPageState();
}

class _SymptomInputPageState extends State<SymptomInputPage> {
  final _notesController = TextEditingController();
  bool _isLoading = false;

  final Map<String, double> _symptomSeverities = {
    'Headache': 0,
    'Nausea / Vomiting': 0,
    'Swelling (Hands/Face)': 0,
    'Fever': 0,
    'Abdominal Pain': 0,
    'Fatigue': 0,
    'Vision Changes (Blurriness)': 0,
  };

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _logAndAnalyze() async {
    // Collect active symptoms (severity > 0)
    final List<Map<String, dynamic>> symptomsList = [];
    _symptomSeverities.forEach((name, severity) {
      if (severity > 0) {
        symptomsList.add({
          'name': name,
          'severity': severity.toInt(),
        });
      }
    });

    if (symptomsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log at least one symptom intensity')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Log symptoms
      final logRes = await ApiService.logSymptoms(symptomsList, _notesController.text.trim());
      
      if (logRes['success'] == true) {
        // 2. Assess Risk via AI
        await ApiService.runAiAssessment(symptomsList);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Symptoms logged and assessed by AI successfully.')),
          );
          // 3. Go directly to Risk Assessment Page to see results
          Navigator.pushReplacementNamed(context, AppRoutes.riskAssessment);
        }
      } else {
        throw Exception(logRes['message'] ?? 'Failed to log symptoms');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error analyzing symptoms: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Symptoms'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'How are you feeling today?',
                      style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Move the sliders to rank the severity of any symptoms you are currently experiencing (1 = mild, 10 = severe).',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    
                    // Symptoms Sliders
                    ..._symptomSeverities.keys.map((symptom) {
                      final val = _symptomSeverities[symptom]!;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    symptom,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    val == 0 ? 'None' : val.toInt().toString(),
                                    style: TextStyle(
                                      color: val == 0 ? theme.hintColor : theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: val,
                                min: 0,
                                max: 10,
                                divisions: 10,
                                activeColor: theme.primaryColor,
                                onChanged: (newVal) {
                                  setState(() {
                                    _symptomSeverities[symptom] = newVal;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    
                    const SizedBox(height: 16),
                    Text(
                      'Additional Notes',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      controller: _notesController,
                      labelText: 'Notes / Context',
                      hintText: 'e.g. Felt a bit dizzy after lunch',
                      prefixIcon: Icons.edit_note_rounded,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            
            // Log & Analyze Button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: 'Log & Analyze with AI',
                isLoading: _isLoading,
                onPressed: _logAndAnalyze,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


