const express = require('express');
const router = express.Router();
const AiPredictionController = require('./aiPrediction.controller');
const { protect } = require('../../common/middlewares/authMiddleware');

router.post('/assess', protect, AiPredictionController.assess);
router.get('/history', protect, AiPredictionController.getHistory);

module.exports = router;
