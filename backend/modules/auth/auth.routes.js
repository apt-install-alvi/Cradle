const express = require('express');
const router = express.Router();
const AuthController = require('./auth.controller');
const validateRequest = require('../../common/middlewares/validateRequest');
const {
  validateRegister,
  validateLogin,
  validateVerifyOtp,
  validateResendOtp
} = require('./auth.validation');

router.post('/register', validateRequest(validateRegister), AuthController.register);
router.post('/login', validateRequest(validateLogin), AuthController.login);
router.post('/verify-otp', validateRequest(validateVerifyOtp), AuthController.verifyOtp);
router.post('/resend-otp', validateRequest(validateResendOtp), AuthController.resendOtp);

module.exports = router;
