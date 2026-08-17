const User = require('./user.model');
const dateHelpers = require('../../common/utils/dateHelpers');
const otpConfig = require('../../config/otpConfig');

class AuthService {
  static async register(phone, password) {
    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      throw new Error('User already exists');
    }

    const otpCode = '123456'; // Fixed for development
    const otpExpires = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes);

    const user = new User({
      phone,
      password,
      otp: { code: otpCode, expiresAt: otpExpires }
    });

    await user.save();
    console.log(`[AUTH] User registered: ${phone}. OTP: ${otpCode}`);
    return user;
  }

  static async login(phone, password) {
    const user = await User.findOne({ phone });
    if (!user) throw new Error('Invalid credentials');

    const isMatch = await user.comparePassword(password);
    if (!isMatch) throw new Error('Invalid credentials');

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
    user.isProfileCompleted = true; // Assuming verification completes basic auth profile
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
