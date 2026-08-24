const express = require('express');
const router = express.Router();
const SettingsController = require('./settings.controller');
const { protect } = require('../../common/middlewares/authMiddleware');

router.get('/', protect, SettingsController.getSettings);
router.patch('/', protect, SettingsController.updateSettings);

module.exports = router;
