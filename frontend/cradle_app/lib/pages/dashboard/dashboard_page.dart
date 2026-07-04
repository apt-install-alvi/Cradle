import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../core/services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isSosLoading = false;
  String _riskLevel = 'Calculating...';
  Color _riskColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.fetchProfile();
    _fetchRecentAssessment();
  }

  Future<void> _fetchRecentAssessment() async {
    try {
      final res = await ApiService.getAiAssessmentHistory();
      if (res['success'] == true && res['data'] != null && (res['data'] as List).isNotEmpty) {
        final assessment = res['data'][0];
        setState(() {
          _riskLevel = assessment['riskLevel'] ?? 'LOW';
          _riskColor = _getRiskColor(_riskLevel);
        });
      } else {
        setState(() {
          _riskLevel = 'LOW';
          _riskColor = Colors.green;
        });
      }
    } catch (_) {
      setState(() {
        _riskLevel = 'LOW';
        _riskColor = Colors.green;
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

  Future<void> _triggerSOS() async {
    setState(() {
      _isSosLoading = true;
    });

    try {
      final res = await ApiService.triggerSos(null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(res['message'] ?? 'SOS Alert Sent Successfully!'),
            backgroundColor: const Color(0xFFBE123C),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to trigger SOS alert. Please call emergency services.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSosLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculatePregnancyTimeline(DateTime? dueDate) {
    if (dueDate == null) {
      return {'weeks': 0, 'days': 0, 'progress': 0.0};
    }
    final now = DateTime.now();
    final conceptionDate = dueDate.subtract(const Duration(days: 280));
    final durationFromConception = now.difference(conceptionDate);
    
    int days = durationFromConception.inDays;
    if (days < 0) days = 0;
    if (days > 280) days = 280;

    final double progress = days / 280;
    final int weeks = days ~/ 7;
    final int remainingDays = days % 7;

    return {
      'weeks': weeks,
      'days': remainingDays,
      'progress': progress,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = Provider.of<AuthProvider>(context);
    
    final fullName = auth.profile['fullName'] ?? 'Mother';
    DateTime? dueDate;
    if (auth.profile['dueDate'] != null) {
      dueDate = DateTime.tryParse(auth.profile['dueDate']);
    }

    final timeline = _calculatePregnancyTimeline(dueDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cradle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              Text(
                'Hello, $fullName 👋',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Here is your health dashboard for today.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              // Pregnancy Progress Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pregnancy Progress',
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${timeline['weeks']} Weeks, ${timeline['days']} Days',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dueDate != null 
                                  ? 'Due ${DateFormat('MMM dd, yyyy').format(dueDate)}' 
                                  : 'Setup Due Date',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: timeline['progress'],
                          minHeight: 12,
                          backgroundColor: isDark ? Colors.white10 : Colors.teal.shade50,
                          valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Conception', style: theme.textTheme.bodySmall),
                          Text(
                            '${(timeline['progress'] * 100).toStringAsFixed(0)}% Completed', 
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)
                          ),
                          Text('Birth', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Risk Assessment & Quick Status Summary
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _riskColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.analytics_outlined, color: _riskColor, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Pregnancy Risk Level',
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _riskLevel,
                              style: TextStyle(
                                color: _riskColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, size: 16, color: theme.hintColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Options Grid
              Text(
                'Quick Actions',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.25,
                children: [
                  _buildActionCard(
                    context,
                    'Log Symptoms',
                    Icons.add_alert_rounded,
                    theme.primaryColor,
                    () => Navigator.pushNamed(context, AppRoutes.symptomInput),
                  ),
                  _buildActionCard(
                    context,
                    'Risk Assessment',
                    Icons.security_rounded,
                    AppTheme.secondaryCoral,
                    () => Navigator.pushNamed(context, AppRoutes.riskAssessment),
                  ),
                  _buildActionCard(
                    context,
                    'Appointments',
                    Icons.calendar_today_rounded,
                    Colors.indigo,
                    () => Navigator.pushNamed(context, AppRoutes.appointments),
                  ),
                  _buildActionCard(
                    context,
                    'Education',
                    Icons.menu_book_rounded,
                    Colors.orange.shade800,
                    () => Navigator.pushNamed(context, AppRoutes.education),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // SOS Trigger Section
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Emergency SOS',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4C0519),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Triggering the SOS immediately alerts your family contacts and clinic with GPS locations.',
                            style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF9F1239),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 50,
                      width: 90,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE123C),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: _isSosLoading ? null : _triggerSOS,
                        child: _isSosLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('SOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


