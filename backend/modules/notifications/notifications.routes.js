const express = require('express');
const router = express.Router();
const NotificationsController = require('./notifications.controller');
const { protect } = require('../../common/middlewares/authMiddleware');

router.get('/', protect, NotificationsController.getNotifications);
router.patch('/:id/read', protect, NotificationsController.markAsRead);

module.exports = router;
