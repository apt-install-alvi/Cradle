import 'package:flutter/material.dart';
import '../core/services/api_service.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'GENERAL',
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  final String? token;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider(this.token) {
    if (token != null) fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final localDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final localTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      final response = await ApiService.get(
        '/notifications?localDate=$localDate&localTime=$localTime',
        token: token
      );
      final List data = response['data'] ?? [];
      _notifications = data.map((n) => NotificationModel.fromJson(n)).toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
        // Backend expects PATCH /notifications/:id/read
        await ApiService.patch('/notifications/$id/read', {}, token: token);
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (var n in _notifications) {
        n.isRead = true;
      }
      notifyListeners();
      await ApiService.patch('/notifications/read-all', {}, token: token);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
