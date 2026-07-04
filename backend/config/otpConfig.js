const env = require('./env');

module.exports = {
  length: 6,
  expiresInMinutes: env.OTP_EXPIRES_IN_MINUTES,
  otpTemplate: (otp) => `Your Cradle verification code is ${otp}. It will expire in ${env.OTP_EXPIRES_IN_MINUTES} minutes. Do not share this code.`
};
