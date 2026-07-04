const express = require('express');
const router = express.Router();
const MotherProfileController = require('./motherProfile.controller');
const { protect } = require('../../common/middlewares/authMiddleware');
const validateRequest = require('../../common/middlewares/validateRequest');
const { validateCreateProfile } = require('./motherProfile.validation');

router.get('/', protect, MotherProfileController.getProfile);
router.post('/', protect, validateRequest(validateCreateProfile), MotherProfileController.updateProfile);

module.exports = router;
