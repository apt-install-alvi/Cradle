const NotificationsService = require('./notifications.service');
const ApiResponse = require('../../common/utils/apiResponse');

class NotificationsController {
  static async getNotifications(req, res, next) {
    try {
      const list = await NotificationsService.getNotifications(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Notifications retrieved successfully.', list);
    } catch (error) {
      next(error);
    }
  }

  static async markAsRead(req, res, next) {
    try {
      const notif = await NotificationsService.markAsRead(req.user.id || req.user._id, req.params.id);
      if (!notif) {
        return ApiResponse.error(res, 'Notification not found or access denied.', 404);
      }
      return ApiResponse.success(res, 'Notification marked as read successfully.', notif);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = NotificationsController;
