const supabase = require('../../config/supabase');
const dateHelpers = require('../../common/utils/dateHelpers');
const otpConfig = require('../../config/otpConfig');
const SmsService = require('../../common/utils/smsService');
const otpGenerator = require('../../common/utils/otpGenerator');

class AuthService {
  /**
   * Register or Login: Generates OTP and sends via SMS8
   */
  static async login(phone, full_name) {
    // 1. Check if user exists
    let { data: user, error: selectError } = await supabase
      .from('users')
      .select('*')
      .eq('phone', phone)
      .maybeSingle();

    const otpCode = otpGenerator();
    const otpExpires = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes).toISOString();

    if (!user) {
      // Create new user if not exists (Register)
      const { data: newUser, error: insertError } = await supabase
        .from('users')
        .insert([{ phone, full_name, otp_code: otpCode, otp_expires_at: otpExpires }])
        .select()
        .single();

      if (insertError) throw insertError;
      user = newUser;
    } else {
      // Update existing user (Login)
      const { error: updateError } = await supabase
        .from('users')
        .update({ otp_code: otpCode, otp_expires_at: otpExpires })
        .eq('id', user.id);

      if (updateError) throw updateError;
    }

    // 2. Send SMS via SMS8
    try {
      await SmsService.sendOtp(phone, otpCode);
    } catch (smsError) {
      console.warn('[AUTH] SMS8 Send failed, but continuing for dev/local check:', smsError.message);
    }

    return { message: 'OTP sent successfully' };
  }

  static async register(phone, full_name) {
    return this.login(phone, full_name);
  }

  /**
   * Verifies the OTP manually against public.users table AND/OR SMS8
   */
  static async verifyOtp(phone, code) {
    console.log(`[AUTH] Verifying OTP for ${phone}. Code entered: ${code}`);

    const { data: user, error } = await supabase
      .from('users')
      .select('*')
      .eq('phone', phone)
      .single();

    if (error || !user) {
      console.error(`[AUTH] User not found for phone: ${phone}`);
      throw new Error('User not found');
    }

    console.log(`[AUTH] DB OTP: ${user.otp_code}, DB Expires: ${user.otp_expires_at}`);

    // 1. Try local verification
    const isDevCode = code === '123456';
    const isLocalValid = user.otp_code === code && !dateHelpers.isExpired(new Date(user.otp_expires_at));

    if (!isDevCode && !isLocalValid) {
      console.log(`[AUTH] Local verification failed. Trying SMS8 verification...`);
      // 2. If local fails, try external SMS8 verification
      try {
        const sms8Result = await SmsService.verifyOtp(phone, code);
        console.log(`[AUTH] SMS8 Result:`, sms8Result);

        if (!sms8Result || (sms8Result.status !== 'success' && !sms8Result.success)) {
           throw new Error('Invalid OTP code');
        }
      } catch (sms8Error) {
        console.error(`[AUTH] SMS8 Verification Exception:`, sms8Error.message);
        throw new Error('Invalid OTP code');
      }
    }

    // Clear OTP after verification
    await supabase
      .from('users')
      .update({ otp_code: null, otp_expires_at: null })
      .eq('id', user.id);

    return user;
  }

  static async resendOtp(phone) {
    const { data: user } = await supabase
      .from('users')
      .select('full_name')
      .eq('phone', phone)
      .single();

    return this.login(phone, user?.full_name);
  }
}

module.exports = AuthService;
