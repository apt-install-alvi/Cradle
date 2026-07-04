import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';

class HealthHistoryPage extends StatefulWidget {
  const HealthHistoryPage({Key? key}) : super(key: key);

  @override
  State<HealthHistoryPage> createState() => _HealthHistoryPageState();
}

class _HealthHistoryPageState extends State<HealthHistoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<dynamic> _symptomLogs = [];
  List<dynamic> _assessments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistoryData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final symptomRes = await ApiService.getSymptomsHistory();
      final assessRes = await ApiService.getAiAssessmentHistory();
      
      setState(() {
        _symptomLogs = symptomRes['success'] == true ? symptomRes['data'] : [];
        _assessments = assessRes['success'] == true ? assessRes['data'] : [];
      });
    } catch (_) {
      // Keep empty lists or fallbacks
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'HIGH':
        return Colors.orange;
      case 'MEDIUM':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health History'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: theme.primaryColor,
          unselectedLabelColor: theme.hintColor,
          indicatorColor: theme.primaryColor,
          tabs: const [
            Tab(text: 'Symptom Logs', icon: Icon(Icons.add_alert_rounded)),
            Tab(text: 'AI Assessments', icon: Icon(Icons.analytics_rounded)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildSymptomsTab(),
                _buildAssessmentsTab(),
              ],
            ),
    );
  }

  Widget _buildSymptomsTab() {
    if (_symptomLogs.isEmpty) {
      return const Center(child: Text('No logged symptoms found.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _symptomLogs.length,
      itemBuilder: (context, index) {
        final log = _symptomLogs[index];
        final DateTime loggedAt = DateTime.tryParse(log['loggedAt'] ?? '') ?? DateTime.now();
        final symptomsList = log['symptomsList'] as List? ?? [];
        final notes = log['notes'] ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(loggedAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 18),
                  ],
                ),
                const Divider(height: 20),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: symptomsList.map((symptom) {
                    return Chip(
                      label: Text('${symptom['name']} (Lvl ${symptom['severity']})'),
                      backgroundColor: Colors.teal.shade50.withOpacity(0.5),
                      side: BorderSide.none,
                    );
                  }).toList(),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Notes: $notes',
                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssessmentsTab() {
    if (_assessments.isEmpty) {
      return const Center(child: Text('No assessments calculated yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _assessments.length,
      itemBuilder: (context, index) {
        final assessment = _assessments[index];
        final DateTime assessedAt = DateTime.tryParse(assessment['assessedAt'] ?? '') ?? DateTime.now();
        final riskLevel = assessment['riskLevel'] ?? 'LOW';
        final confidence = (assessment['confidenceScore'] ?? 0.95) * 100;
        final recommendations = assessment['recommendations'] as List? ?? [];

        final color = _getRiskColor(riskLevel);

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(assessedAt),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        riskLevel,
                        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'AI confidence level: ${confidence.toStringAsFixed(0)}%',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                ),
                if (recommendations.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text('Recommendations:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  ...recommendations.map((rec) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text('• $rec', style: const TextStyle(fontSize: 13)),
                      )),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}


