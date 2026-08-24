const validateRegister = (body) => {
  const { phone, full_name, age } = body;
  if (!phone || typeof phone !== 'string' || phone.trim().length < 8) {
    return { error: new Error('Valid phone number is required') };
  }
  if (!full_name || typeof full_name !== 'string' || full_name.trim().length < 2) {
    return { error: new Error('Full name is required') };
  }
  if (!age) {
    return { error: new Error('Age is required') };
  }
  return { value: { phone: phone.trim(), full_name: full_name.trim(), age } };
};

const validateLogin = (body) => {
  const { phone } = body;
  if (!phone || typeof phone !== 'string' || phone.trim().length < 8) {
    return { error: new Error('Valid phone number is required') };
  }
  return { value: { phone: phone.trim() } };
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
  validateRegister,
  validateLogin,
  validateVerifyOtp,
  validateResendOtp
};
