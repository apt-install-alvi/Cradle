const crypto = require('crypto');
const otpConfig = require('../../config/otpConfig');

const generateOTP = () => {
  const digits = '0123456789';
  let otp = '';
  for (let i = 0; i < otpConfig.length; i++) {
    const randomIndex = crypto.randomInt(0, digits.length);
    otp += digits[randomIndex];
  }
  return otp;
};

module.exports = generateOTP;
