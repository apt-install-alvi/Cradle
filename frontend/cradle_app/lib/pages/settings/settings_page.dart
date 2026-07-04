import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../core/widgets/custom_button.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = Provider.of<AuthProvider>(context);
    
    final fullName = auth.profile['fullName'] ?? 'Mother';
    final age = auth.profile['age'] ?? '--';
    final bloodGroup = auth.profile['bloodGroup'] ?? '--';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // User profile card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: theme.primaryColor.withOpacity(0.1),
                      foregroundColor: theme.primaryColor,
                      child: const Icon(Icons.person_rounded, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Age: $age • Blood: $bloodGroup',
                            style: TextStyle(color: theme.hintColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Settings menu
            Text(
              'Account & Profile',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit Personal Information'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.personalInfo),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.emergency_share_outlined),
                    title: const Text('Emergency Contacts'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.emergency),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              'App Settings',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: theme.brightness == Brightness.dark,
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark Mode'),
                    onChanged: (val) {
                      // Handled by system dark mode dynamically in MaterialApp
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('App theme is synchronized with your mobile OS settings.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About Cradle'),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Cradle',
                        applicationVersion: '1.0.0',
                        applicationIcon: const Icon(Icons.child_care_rounded, size: 36, color: Colors.teal),
                        applicationLegalese: '© 2026 Cradle Team. All rights reserved.',
                        children: const [
                          SizedBox(height: 12),
                          Text('Cradle offers AI/ML pregnancy health tracking and risk assessments to keep mothers safe and informed.'),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            
            // Logout
            CustomButton(
              text: 'Logout',
              isSecondary: true,
              onPressed: () {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}


