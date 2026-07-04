const express = require('express');
const router = express.Router();
const HealthHistoryController = require('./healthHistory.controller');
const { protect } = require('../../common/middlewares/authMiddleware');

router.get('/', protect, HealthHistoryController.getHistory);

module.exports = router;
