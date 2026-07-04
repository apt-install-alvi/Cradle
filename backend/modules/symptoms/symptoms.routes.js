const express = require('express');
const router = express.Router();
const SymptomsController = require('./symptoms.controller');
const { protect } = require('../../common/middlewares/authMiddleware');
const validateRequest = require('../../common/middlewares/validateRequest');
const { validateSymptomLog } = require('./symptoms.validation');

router.post('/', protect, validateRequest(validateSymptomLog), SymptomsController.logSymptom);
router.get('/history', protect, SymptomsController.getHistory);

module.exports = router;
