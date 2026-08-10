import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/gradient_scaffold.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../providers/language_provider.dart';
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
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      id: 1,
      icon: Icons.medication_outlined,
      titleEn: 'Medicine reminder',
      titleBn: 'ওষুধের রিমাইন্ডার',
      messageEn: 'It is time to take your Iron supplement.',
      messageBn: 'আপনার আয়রন সাপ্লিমেন্ট নেওয়ার সময় হয়েছে।',
      timeEn: '10 minutes ago',
      timeBn: '১০ মিনিট আগে',
      unread: true,
    ),
    _NotificationItem(
      id: 2,
      icon: Icons.favorite_outline,
      titleEn: 'Health reminder',
      titleBn: 'স্বাস্থ্য রিমাইন্ডার',
      messageEn: 'Remember to log your blood pressure today.',
      messageBn: 'আজ আপনার রক্তচাপ লগ করতে ভুলবেন না।',
      timeEn: '1 hour ago',
      timeBn: '১ ঘণ্টা আগে',
      unread: true,
    ),
    _NotificationItem(
      id: 3,
      icon: Icons.child_care_outlined,
      titleEn: 'Pregnancy update',
      titleBn: 'গর্ভাবস্থার আপডেট',
      messageEn: 'Your baby is now about the size of a grape.',
      messageBn: 'আপনার শিশুর আকার এখন প্রায় একটি আঙুরের সমান।',
      timeEn: '3 hours ago',
      timeBn: '৩ ঘণ্টা আগে',
      unread: false,
    ),
    _NotificationItem(
      id: 4,
      icon: Icons.calendar_month_outlined,
      titleEn: 'Weekly check-in',
      titleBn: 'সাপ্তাহিক চেক-ইন',
      messageEn: 'Take a moment to update your health information.',
      messageBn: 'আপনার স্বাস্থ্য সংক্রান্ত তথ্য আপডেট করতে কিছু সময় নিন।',
      timeEn: 'Yesterday',
      timeBn: 'গতকাল',
      unread: false,
    ),
    _NotificationItem(
      id: 5,
      icon: Icons.water_drop_outlined,
      titleEn: 'Hydration reminder',
      titleBn: 'পানি পান করার রিমাইন্ডার',
      messageEn: 'Remember to stay hydrated throughout the day.',
      messageBn: 'সারাদিন পর্যাপ্ত পানি পান করতে মনে রাখুন।',
      timeEn: 'Yesterday',
      timeBn: 'গতকাল',
      unread: true,
    ),
  ];

  void _markAsRead(int index) {
    setState(() {
      _notifications[index].unread = false;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.unread = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isBangla = context.watch<LanguageProvider>().isBangla;

    final unreadCount =
        _notifications.where((notification) => notification.unread).length;

    return GradientScaffold(
      bottomNavigationBar: const DashboardBottomNav(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),

          // ------------------------------------------------
          // HEADER
          // ------------------------------------------------

          HealthTopBar(
            title: isBangla ? 'নোটিফিকেশন' : 'Notifications',
            subtitle: unreadCount == 0
                ? (isBangla
                    ? 'সব নোটিফিকেশন পড়া হয়েছে'
                    : 'All notifications are read')
                : (isBangla
                    ? '${_toBanglaNumber(unreadCount)}টি অপঠিত নোটিফিকেশন'
                    : '$unreadCount unread notification${unreadCount == 1 ? '' : 's'}'),
          ),

          const SizedBox(height: 14),

          // ------------------------------------------------
          // MARK ALL AS READ
          // ------------------------------------------------

          if (unreadCount > 0)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _markAllAsRead,
                style: TextButton.styleFrom(
                  foregroundColor: _brand,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: Text(
                  isBangla ? 'সব পড়া হয়েছে' : 'Mark all as read',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 4),

          // ------------------------------------------------
          // NOTIFICATIONS
          // ------------------------------------------------

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 40),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];

                return _NotificationCard(
                  notification: notification,
                  isBangla: isBangla,
                  onMarkRead: () => _markAsRead(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _toBanglaNumber(int number) {
    const english = '0123456789';
    const bangla = '০১২৩৪৫৬৭৮৯';

    return number
        .toString()
        .split('')
        .map((char) {
          final index = english.indexOf(char);
          return index == -1 ? char : bangla[index];
        })
        .join();
  }
}


// ============================================================
// NOTIFICATION CARD
// ============================================================

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.isBangla,
    required this.onMarkRead,
  });

  final _NotificationItem notification;
  final bool isBangla;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: notification.unread
            ? _brandUnread
            : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: notification.unread
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
          // ------------------------------------------------
          // ICON
          // ------------------------------------------------

          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: notification.unread
                  ? Colors.white
                  : _brandSofter,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              notification.icon,
              color: _brand,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          // ------------------------------------------------
          // CONTENT
          // ------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        isBangla
                            ? notification.titleBn
                            : notification.titleEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
                    ),

                    // Unread indicator
                    if (notification.unread)
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
                  isBangla
                      ? notification.messageBn
                      : notification.messageEn,
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
                      isBangla
                          ? notification.timeBn
                          : notification.timeEn,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _muted,
                      ),
                    ),

                    const Spacer(),

                    if (notification.unread)
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
                          isBangla ? 'পড়া হয়েছে' : 'Mark as read',
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


// ============================================================
// NOTIFICATION MODEL
// ============================================================

class _NotificationItem {
  _NotificationItem({
    required this.id,
    required this.icon,
    required this.titleEn,
    required this.titleBn,
    required this.messageEn,
    required this.messageBn,
    required this.timeEn,
    required this.timeBn,
    required this.unread,
  });

  final int id;
  final IconData icon;

  final String titleEn;
  final String titleBn;

  final String messageEn;
  final String messageBn;

  final String timeEn;
  final String timeBn;

  bool unread;
}