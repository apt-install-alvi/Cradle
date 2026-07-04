const AuthService = require('./auth.service');
const generateToken = require('../../common/utils/generateToken');
const ApiResponse = require('../../common/utils/apiResponse');
const httpStatusCodes = require('../../common/constants/httpStatusCodes');

class AuthController {
  static async register(req, res, next) {
    try {
      const { phone, password } = req.body;
      const user = await AuthService.register(phone, password);
      return ApiResponse.success(res, 'Registration successful, verification OTP code sent.', {
        userId: user._id,
        phone: user.phone
      }, httpStatusCodes.CREATED);
    } catch (error) {
      next(error);
    }
  }

  static async login(req, res, next) {
    try {
      const { phone, password } = req.body;
      const user = await AuthService.login(phone, password);
      return ApiResponse.success(res, 'Verification OTP code sent.', {
        userId: user._id,
        phone: user.phone
      });
    } catch (error) {
      next(error);
    }
  }

  static async verifyOtp(req, res, next) {
    try {
      const { phone, code } = req.body;
      const user = await AuthService.verifyOtp(phone, code);
      const token = generateToken(user._id);
      return ApiResponse.success(res, 'OTP verification successful.', {
        token,
        isProfileCompleted: user.isProfileCompleted,
        userId: user._id
      });
    } catch (error) {
      next(error);
    }
  }

  static async resendOtp(req, res, next) {
    try {
      const { phone } = req.body;
      await AuthService.resendOtp(phone);
      return ApiResponse.success(res, 'OTP verification code resent successfully.');
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AuthController;
