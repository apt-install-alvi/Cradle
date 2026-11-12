const AuthService = require('./auth.service');
const ApiResponse = require('../../common/utils/apiResponse');
const httpStatusCodes = require('../../common/constants/httpStatusCodes');
const generateToken = require('../../common/utils/generateToken');

class AuthController {
  static async register(req, res, next) {
    try {
      const { phone, full_name, age } = req.body;
      await AuthService.register(phone, full_name, age);
      return ApiResponse.success(res, 'Verification OTP code sent.', {
        phone
      }, httpStatusCodes.CREATED);
    } catch (error) {
      next(error);
    }
  }

  static async login(req, res, next) {
    try {
      const { phone } = req.body;
      await AuthService.login(phone);
      return ApiResponse.success(res, 'Verification OTP code sent.', {
        phone
      });
    } catch (error) {
      next(error);
    }
  }

  static async verifyOtp(req, res, next) {
    try {
      const { phone, code } = req.body;
      const user = await AuthService.verifyOtp(phone, code);

      // Generate our custom JWT token
      const token = generateToken(user.id);

      return ApiResponse.success(res, 'OTP verification successful.', {
        token,
        user: {
          id: user.id,
          phone: user.phone,
          full_name: user.full_name,
          isProfileCompleted: user.is_profile_completed
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
