import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
import '../../providers/notification_provider.dart';
import '../health_monitor/widgets/health_top_bar.dart';

const _brand = DashboardBottomNav.primaryPink;
const _brandSofter = Color(0xFFFCEEF5);
const _brandUnread = Color.fromARGB(255, 255, 239, 245);
const _ink = Color(0xFF3A2C33);
const _muted = Color(0xFF8A7680);

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;
    final provider = context.watch<NotificationProvider?>();

    if (provider == null) {
      return const GradientScaffold(
        bottomNavigationBar: DashboardBottomNav(),
        child: Center(child: Text("Please log in to see notifications")),
      );
    }

    final notifications = provider.notifications;
    final unreadCount = provider.unreadCount;

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          HealthTopBar(
            title: isBangla ? 'নোটিফিকেশন' : 'Notifications',
            subtitle: provider.isLoading
                ? (isBangla ? 'লোড হচ্ছে...' : 'Loading...')
                : unreadCount == 0
                    ? (isBangla ? 'সব নোটিফিকেশন পড়া হয়েছে' : 'All notifications are read')
                    : (isBangla
                        ? '${_toBanglaNumber(unreadCount)}টি অপঠিত নোটিফিকেশন'
                        : '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}'),
          ),

          const SizedBox(height: 14),

          if (unreadCount > 0)
           Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: provider.markAllAsRead,
              style: TextButton.styleFrom(
                foregroundColor: _brand,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: _brand.withValues(alpha: 0.20)),
                ),
              ),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text(
                isBangla ? 'সব পঠিত হিসেবে চিহ্নিত করুন' : 'Mark all as read',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: RefreshIndicator(
              onRefresh: provider.fetchNotifications,
              child: notifications.isEmpty && !provider.isLoading
                ? Center(
                    child: Text(
                      isBangla ? "কোনো নোটিফিকেশন নেই" : "No notifications yet",
                      style: const TextStyle(color: _muted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 180),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return _NotificationCard(
                        notification: notification,
                        isBangla: isBangla,
                        onMarkRead: () => provider.markAsRead(notification.id),
                      );
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _toBanglaNumber(int number) {
    const english = '0123456789';
    const bangla = '০১২৩৪৫৬৭৮৯';
    return number.toString().split('').map((char) {
      final index = english.indexOf(char);
      return index == -1 ? char : bangla[index];
    }).join();
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isBangla,
    required this.onMarkRead,
  });

  final NotificationModel notification;
  final bool isBangla;
  final VoidCallback onMarkRead;

  IconData _getIcon() {
    switch (notification.type) {
      case 'WATER_REMINDER':
        return Icons.water_drop_outlined;
      case 'OUTBREAK_WARNING':
        return Icons.warning_amber_rounded;
      case 'MEDICATION':
        return Icons.medication_outlined;
      case 'APPOINTMENT':
        return Icons.calendar_month_outlined;
      case 'HEALTH_LOG':
        return Icons.health_and_safety_sharp;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _getTitle() {
    if (!isBangla) {
      return notification.title;
    }

    switch (notification.type) {
      case 'WATER_REMINDER':
        return 'পানি পান করার অনুস্মারক';

      case 'OUTBREAK_WARNING':
        return 'রোগের প্রাদুর্ভাবের সতর্কতা';

      case 'MEDICATION':
        return 'ওষুধের অনুস্মারক';

      case 'APPOINTMENT':
        return 'অ্যাপয়েন্টমেন্টের অনুস্মারক';
        
      case 'HEALTH_LOG':
        return 'স্বাস্থ্য পর্যবেক্ষণ করার সময় হয়েছে';
      default:
        return notification.title;
    }
  }

  String _getMessage() {
    if (!isBangla) {
      return notification.message;
    }

    switch (notification.type) {
      case 'WATER_REMINDER':
        return 'আপনার শরীরকে হাইড্রেটেড রাখতে পানি পান করতে ভুলবেন না।';

      case 'OUTBREAK_WARNING':
        return 'আপনার এলাকায় রোগের প্রাদুর্ভাবের খবর পাওয়া গেছে। সতর্ক থাকুন এবং প্রয়োজনীয় স্বাস্থ্যবিধি মেনে চলুন।';

      case 'MEDICATION':
        return 'আপনার নির্ধারিত ওষুধ খাওয়ার সময় হয়েছে।';

      case 'APPOINTMENT':
        return 'আপনার একটি নির্ধারিত অ্যাপয়েন্টমেন্ট রয়েছে। সময়মতো উপস্থিত হতে ভুলবেন না।';

      case 'HEALTH_LOG':
        return 'আপনার স্বাস্থ্য পর্যবেক্ষণের রিডিং নেওয়ার সময় হয়েছে।';
      default:
        return notification.message;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: !notification.isRead ? _brandUnread : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: !notification.isRead
              ? _brand.withValues(alpha: .18)
              : Colors.white,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x29C87896),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: !notification.isRead
                  ? Colors.white
                  : _brandSofter,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getIcon(),
              color: _brand,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _getTitle(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                    ),

                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(
                          left: 8,
                          top: 5,
                        ),
                        decoration: const BoxDecoration(
                          color: _brand,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  _getMessage(),
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.4,
                    color: _muted,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Text(
                      timeago.format(
                        notification.createdAt,
                        locale: isBangla ? 'bn' : 'en',
                      ),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),

                    const Spacer(),

                    if (!notification.isRead)
                      TextButton(
                        onPressed: onMarkRead,
                        style: TextButton.styleFrom(
                          foregroundColor: _brand,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          tapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          isBangla
                              ? 'পঠিত হিসেবে চিহ্নিত করুন'
                              : 'Mark as read',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

