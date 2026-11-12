const express = require('express');
const router = express.Router();
const WaterController = require('./water.controller');
const { protect } = require('../../common/middlewares/authMiddleware');

router.post('/log', protect, WaterController.logWater);
router.get('/stats', protect, WaterController.getStats);

module.exports = router;
