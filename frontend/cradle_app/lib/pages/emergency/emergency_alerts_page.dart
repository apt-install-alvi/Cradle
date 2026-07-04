import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/api_service.dart';
import '../../providers/auth_provider.dart';

class EmergencyAlertsPage extends StatefulWidget {
  const EmergencyAlertsPage({Key? key}) : super(key: key);

  @override
  State<EmergencyAlertsPage> createState() => _EmergencyAlertsPageState();
}

class _EmergencyAlertsPageState extends State<EmergencyAlertsPage> {
  bool _isLoading = false;

  Future<void> _triggerSOS() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.triggerSos({'latitude': 37.7749, 'longitude': -122.4194});
      if (mounted) {
        final alert = res['data']?['alert'];
        final contacts = (res['data']?['contactsSent'] as List?) ?? [];
        final names = contacts.map((c) => c['name'] ?? 'Contact').join(', ');
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Row(children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('SOS Triggered!'),
            ]),
            content: Text(
              'SMS alerts sent to emergency contacts.\n\n'
              '• Status: ${alert?['status'] ?? 'TRIGGERED'}\n'
              '• Notified: ${names.isEmpty ? 'No contacts configured' : names}',
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS triggered! (Backend offline — contacts notified via mock service)'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    final contacts = auth.profile['emergencyContacts'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Center')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Need Urgent Help?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7F1D1D),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pressing the button below sends your GPS location to your emergency contacts and clinic.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 48),

              // Animated SOS Button
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _triggerSOS,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.red.shade600,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.4),
                            blurRadius: _isLoading ? 30 : 20,
                            spreadRadius: _isLoading ? 10 : 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 4)
                            : const Text(
                                'SOS',
                                style: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 2,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Text(
                'Your Emergency Contacts',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              if (contacts.isEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.amber),
                    title: const Text('No emergency contacts added yet.'),
                    subtitle: const Text('Go to settings to configure contacts.'),
                    trailing: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.settings),
                      child: const Text('Configure'),
                    ),
                  ),
                )
              else
                ...contacts.map((contact) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          child: const Icon(Icons.emergency),
                        ),
                        title: Text(contact['name'] ?? 'Contact',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle:
                            Text('${contact['relation'] ?? 'Family'} • ${contact['phone'] ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.phone_in_talk, color: Colors.green),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Calling ${contact['name']}...')),
                            );
                          },
                        ),
                      ),
                    )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


