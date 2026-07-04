const Notification = require('./notification.model');
const mongoose = require('mongoose');

// In-memory fallback
const mockNotifications = [];

class NotificationsService {
  static async sendNotification(userId, title, body, type = 'GENERAL') {
    if (mongoose.connection.readyState !== 1) {
      const notif = {
        _id: 'mock-notif-' + Math.random().toString(36).substring(2, 11),
        userId: userId.toString(),
        title,
        body,
        type,
        isRead: false,
        sentAt: new Date(),
        createdAt: new Date()
      };
      mockNotifications.push(notif);
      return notif;
    }
    return await Notification.create({ userId, title, body, type });
  }

  static async getNotifications(userId) {
    if (mongoose.connection.readyState !== 1) {
      const list = mockNotifications.filter(n => n.userId === userId.toString());
      if (list.length === 0) {
        return [
          {
            _id: 'mock-notif-seed-1',
            userId: userId.toString(),
            title: 'Welcome to Cradle!',
            body: 'Your account is setup successfully. Start tracking your symptoms today.',
            type: 'GENERAL',
            isRead: false,
            sentAt: new Date(Date.now() - 3600000 * 2) 
          },
          {
            _id: 'mock-notif-seed-2',
            userId: userId.toString(),
            title: 'Upcoming Appointment',
            body: 'Friendly reminder of your checkup with Dr. Sarah Connor in 2 days.',
            type: 'APPOINTMENT',
            isRead: false,
            sentAt: new Date()
          }
        ];
      }
      return list.sort((a, b) => b.sentAt - a.sentAt);
    }
    return await Notification.find({ userId }).sort({ sentAt: -1 });
  }

  static async markAsRead(userId, notifId) {
    if (mongoose.connection.readyState !== 1) {
      const notif = mockNotifications.find(n => n._id === notifId && n.userId === userId.toString());
      if (notif) notif.isRead = true;
      return notif;
    }
    return await Notification.findOneAndUpdate(
      { _id: notifId, userId },
      { isRead: true },
      { new: true }
    );
  }
}

module.exports = NotificationsService;
