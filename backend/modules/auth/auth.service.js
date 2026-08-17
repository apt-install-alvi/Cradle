const User = require('./user.model');
const SmsService = require('../../common/utils/smsService');
const dateHelpers = require('../../common/utils/dateHelpers');
const otpConfig = require('../../config/otpConfig');

function generateOtpCode() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

class AuthService {
  /**
   * Request OTP for Phone Authentication
   * Check user status based on whether profile setup has been completed (isProfileCompleted).
   */
  static async requestOtp(phone) {
    let user = await User.findOne({ phone });

    // If user doesn't exist or profile is not completed yet, treat as new user flow
    const isNewUser = !user || !user.isProfileCompleted;

    if (!user) {
      user = new User({
        phone,
        isProfileCompleted: false
      });
    }

    const otpCode = generateOtpCode();
    const expiresAt = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes || 5);

    user.otp = { code: otpCode, expiresAt };
    await user.save();

    // Trigger Voice Call OTP
    await SmsService.sendVoiceOtp(phone, otpCode);

    console.log(`[AUTH] Voice OTP requested for ${phone}. OTP: ${otpCode}. Is new user (needs profile setup): ${isNewUser}`);
    return { user, isNewUser };
  }

  static async verifyOtp(phone, code) {
    const user = await User.findOne({ phone });
    if (!user) throw new Error('User not found');

    if (!user.otp || !user.otp.code) {
      throw new Error('No OTP requested for this user');
    }

    // Allow dev bypass code '123456' or compare with stored OTP
    if (user.otp.code !== code && code !== '123456') {
      throw new Error('Invalid OTP code');
    }

    if (dateHelpers.isExpired(user.otp.expiresAt)) {
      throw new Error('OTP code expired');
    }

    // Clear OTP after successful verification
    user.otp = undefined;
    await user.save();

    return user;
  }

  static async resendOtp(phone) {
    let user = await User.findOne({ phone });
    if (!user) {
      user = new User({ phone, isProfileCompleted: false });
    }

    const otpCode = generateOtpCode();
    const expiresAt = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes || 5);

    user.otp = { code: otpCode, expiresAt };
    await user.save();

    // Resend Voice Call OTP
    await SmsService.sendVoiceOtp(phone, otpCode);

    console.log(`[AUTH] Voice OTP resent to ${phone}. OTP: ${otpCode}`);
    return true;
  }
}

module.exports = AuthService;
