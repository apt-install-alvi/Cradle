const validateRegisterLogin = (body) => {
  const { phone, password } = body;
  if (!phone || typeof phone !== 'string' || phone.trim().length < 8) {
    return { error: new Error('Valid phone number is required (at least 8 characters)') };
  }
  if (!password || typeof password !== 'string' || password.length < 6) {
    return { error: new Error('Password must be at least 6 characters long') };
  }
  return { value: { phone: phone.trim(), password } };
};

const validateVerifyOtp = (body) => {
  const { phone, code } = body;
  if (!phone || typeof phone !== 'string') {
    return { error: new Error('Phone is required') };
  }
  if (!code || typeof code !== 'string' || code.trim().length !== 6) {
    return { error: new Error('OTP code must be exactly 6 digits') };
  }
  return { value: { phone: phone.trim(), code: code.trim() } };
};

const validateResendOtp = (body) => {
  const { phone } = body;
  if (!phone || typeof phone !== 'string') {
    return { error: new Error('Phone is required') };
  }
  return { value: { phone: phone.trim() } };
};

module.exports = {
  validateRegisterLogin,
  validateVerifyOtp,
  validateResendOtp
};
