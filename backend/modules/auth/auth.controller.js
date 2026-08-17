const AuthService = require('./auth.service');
const generateToken = require('../../common/utils/generateToken');
const ApiResponse = require('../../common/utils/apiResponse');
const httpStatusCodes = require('../../common/constants/httpStatusCodes');

class AuthController {
  static async register(req, res, next) {
    try {
      const { phone, full_name } = req.body;
      const user = await AuthService.register(phone, full_name);
      return ApiResponse.success(res, 'Verification OTP code sent.', {
        userId: user._id,
        phone: user.phone,
        full_name: user.full_name
      }, httpStatusCodes.CREATED);
    } catch (error) {
      next(error);
    }
  }

  static async login(req, res, next) {
    try {
      const { phone } = req.body;
      const user = await AuthService.login(phone);
      return ApiResponse.success(res, 'Verification OTP code sent.', {
        userId: user._id,
        phone: user.phone,
        full_name: user.full_name
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
        user: {
          id: user._id,
          phone: user.phone,
          full_name: user.full_name,
          preferred_language: user.preferred_language,
          isProfileCompleted: user.isProfileCompleted
        }
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
