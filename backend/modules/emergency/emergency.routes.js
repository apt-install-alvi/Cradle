const express = require('express');
const router = express.Router();
const EmergencyController = require('./emergency.controller');
const { protect } = require('../../common/middlewares/authMiddleware');

router.post('/sos', protect, EmergencyController.triggerSOS);
router.get('/alerts', protect, EmergencyController.getAlerts);

module.exports = router;
