import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/services/api_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool _isLoading = true;
  List<dynamic> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ApiService.getNotifications(); // attempt to load from server
      // Fallback seed notifications if API isn't fully integrated yet
      setState(() {
        _notifications = [
          {
            '_id': 'n1',
            'title': 'Welcome to Cradle!',
            'body': 'Your account is setup successfully. Start tracking your symptoms today.',
            'type': 'GENERAL',
            'isRead': false,
            'sentAt': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String()
          },
          {
            '_id': 'n2',
            'title': 'Upcoming Appointment',
            'body': 'Friendly reminder of your checkup with Dr. Sarah Connor in 2 days.',
            'type': 'APPOINTMENT',
            'isRead': false,
            'sentAt': DateTime.now().toIso8601String()
          }
        ];
      });
    } catch (_) {}

    setState(() {
      _isLoading = false;
    });
  }

  IconData _getIcon(String type) {
    switch (type.toUpperCase()) {
      case 'APPOINTMENT':
        return Icons.calendar_today_rounded;
      case 'MEDICATION':
        return Icons.medication_rounded;
      case 'RISK_ALERT':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColor(String type) {
    switch (type.toUpperCase()) {
      case 'APPOINTMENT':
        return Colors.indigo;
      case 'MEDICATION':
        return Colors.teal;
      case 'RISK_ALERT':
        return Colors.pink;
      default:
        return Colors.blueGrey;
    }
  }

  void _markRead(int index) {
    setState(() {
      _notifications[index]['isRead'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _notifications.isEmpty
                ? const Center(child: Text('You have no notifications.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final n = _notifications[index];
                      final title = n['title'] ?? '';
                      final body = n['body'] ?? '';
                      final type = n['type'] ?? 'GENERAL';
                      final isRead = n['isRead'] ?? false;
                      final sentAt = DateTime.tryParse(n['sentAt'] ?? '') ?? DateTime.now();

                      final iconColor = _getColor(type);
                      final icon = _getIcon(type);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: isRead ? null : iconColor.withOpacity(0.03),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isRead 
                              ? BorderSide.none 
                              : BorderSide(color: iconColor.withOpacity(0.2), width: 1),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          leading: CircleAvatar(
                            backgroundColor: iconColor.withOpacity(0.1),
                            foregroundColor: iconColor,
                            child: Icon(icon, size: 20),
                          ),
                          title: Text(
                            title,
                            style: TextStyle(
                              fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(body, style: const TextStyle(fontSize: 13)),
                              const SizedBox(height: 6),
                              Text(
                                DateFormat('MMM dd, hh:mm a').format(sentAt),
                                style: TextStyle(color: theme.hintColor, fontSize: 11),
                              ),
                            ],
                          ),
                          trailing: isRead
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.mark_chat_read_outlined, size: 20),
                                  onPressed: () => _markRead(index),
                                ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}


