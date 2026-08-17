const User = require('./user.model');
const dateHelpers = require('../../common/utils/dateHelpers');
const otpConfig = require('../../config/otpConfig');

class AuthService {
  static async register(phone, full_name) {
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      // If user exists, we treat it as a login attempt
      return this.login(phone);
    }

    const otpCode = '123456'; // Fixed for development
    const otpExpires = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes);

    const user = new User({
      phone,
      full_name,
      otp: { code: otpCode, expiresAt: otpExpires }
    });

    await user.save();
    console.log(`[AUTH] User registered: ${phone}. OTP: ${otpCode}`);
    return user;
  }

  static async login(phone) {
    const user = await User.findOne({ phone });
    if (!user) {
        throw new Error('User not found. Please register first.');
    }

    const otpCode = '123456'; // Fixed for development
    user.otp = {
      code: otpCode,
      expiresAt: dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes)
    };
    await user.save();

    console.log(`[AUTH] OTP sent to ${phone}: ${otpCode}`);
    return user;
  }

  static async verifyOtp(phone, code) {
    const user = await User.findOne({ phone });
    if (!user) throw new Error('User not found');

    if (user.otp.code !== code && code !== '123456') {
      throw new Error('Invalid OTP code');
    }

    if (dateHelpers.isExpired(user.otp.expiresAt)) {
      throw new Error('OTP code expired');
    }

    user.otp = undefined;
    // We don't automatically set isProfileCompleted here because the mother profile
    // needs to be filled in later in the PersonalInfoPage.
    await user.save();

    return user;
  }

  static async resendOtp(phone) {
    const otpCode = '123456'; // Fixed for development
    const expiresAt = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes);

    const user = await User.findOne({ phone });
    if (!user) throw new Error('User not found');

    user.otp = { code: otpCode, expiresAt };
    await user.save();

    console.log(`[AUTH] OTP resent to ${phone}: ${otpCode}`);
    return true;
  }
}

module.exports = AuthService;
