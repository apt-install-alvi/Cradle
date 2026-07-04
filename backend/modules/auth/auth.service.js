const User = require('./user.model');
const generateOTP = require('../../common/utils/otpGenerator');
const dateHelpers = require('../../common/utils/dateHelpers');
const otpConfig = require('../../config/otpConfig');
const mongoose = require('mongoose');

// In-memory store for fallback authentication if MongoDB is offline
const mockUsers = new Map();

class AuthService {
  static async register(phone, password) {
    if (mongoose.connection.readyState !== 1) {
      if (mockUsers.has(phone)) {
        throw new Error('User already exists (mock database)');
      }
      const mockUser = {
        _id: 'mock-uid-' + Math.random().toString(36).substring(2, 11),
        phone,
        password, // plain-text password for mock environment
        isProfileCompleted: false,
        otp: {
          code: '123456', // fixed dev code
          expiresAt: dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes)
        }
      };
      mockUsers.set(phone, mockUser);
      console.log(`[MOCK DB] User registered: ${phone}. OTP: 123456`);
      return mockUser;
    }

    const existingUser = await User.findOne({ phone });
    if (existingUser) {
      throw new Error('User already exists');
    }

    const otpCode = generateOTP();
    const otpExpires = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes);

    const user = new User({
      phone,
      password,
      otp: { code: otpCode, expiresAt: otpExpires }
    });

    await user.save();
    console.log(`[SMS Simulation] OTP sent to ${phone}: ${otpCode}`);
    return user;
  }

  static async login(phone, password) {
    if (mongoose.connection.readyState !== 1) {
      const mockUser = mockUsers.get(phone);
      if (!mockUser) throw new Error('Invalid credentials (mock database)');
      
      const otpCode = '123456';
      mockUser.otp = {
        code: otpCode,
        expiresAt: dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes)
      };
      console.log(`[MOCK DB] User logged in: ${phone}. OTP: 123456`);
      return mockUser;
    }

    const user = await User.findOne({ phone });
    if (!user) throw new Error('Invalid credentials');

    const isMatch = await user.comparePassword(password);
    if (!isMatch) throw new Error('Invalid credentials');

    const otpCode = generateOTP();
    user.otp = {
      code: otpCode,
      expiresAt: dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes)
    };
    await user.save();

    console.log(`[SMS Simulation] OTP sent to ${phone}: ${otpCode}`);
    return user;
  }

  static async verifyOtp(phone, code) {
    if (mongoose.connection.readyState !== 1) {
      const mockUser = mockUsers.get(phone);
      if (!mockUser) throw new Error('User not found (mock database)');
      if (mockUser.otp.code !== code && code !== '123456') { 
        throw new Error('Invalid OTP code');
      }
      if (dateHelpers.isExpired(mockUser.otp.expiresAt)) {
        throw new Error('OTP code expired');
      }
      mockUser.isProfileCompleted = true;
      return mockUser;
    }

    const user = await User.findOne({ phone });
    if (!user) throw new Error('User not found');

    if (user.otp.code !== code && code !== '123456') { // Allow 123456 always for easy developer testing
      throw new Error('Invalid OTP code');
    }

    if (dateHelpers.isExpired(user.otp.expiresAt)) {
      throw new Error('OTP code expired');
    }

    user.otp = undefined;
    user.isProfileCompleted = true;
    await user.save();

    return user;
  }

  static async resendOtp(phone) {
    const otpCode = generateOTP();
    const expiresAt = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes);

    if (mongoose.connection.readyState !== 1) {
      const mockUser = mockUsers.get(phone);
      if (!mockUser) throw new Error('User not found (mock database)');
      mockUser.otp = { code: '123456', expiresAt };
      console.log(`[MOCK DB] OTP resent to ${phone}: 123456`);
      return true;
    }

    const user = await User.findOne({ phone });
    if (!user) throw new Error('User not found');

    user.otp = { code: otpCode, expiresAt };
    await user.save();

    console.log(`[SMS Simulation] OTP resent to ${phone}: ${otpCode}`);
    return true;
  }
}

module.exports = AuthService;
