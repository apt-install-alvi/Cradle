const supabase = require('../../config/supabase');
const dateHelpers = require('../../common/utils/dateHelpers');
const otpConfig = require('../../config/otpConfig');
const SmsService = require('../../common/utils/smsService');
const otpGenerator = require('../../common/utils/otpGenerator');

class AuthService {
  /**
   * Login: Sends OTP only if user exists
   */
  static async login(phone) {
    // 1. Check if user exists
    let { data: user, error: selectError } = await supabase
      .from('users')
      .select('*')
      .eq('phone', phone)
      .maybeSingle();

    if (!user) {
      throw new Error('User not found. Please register first.');
    }

    const otpCode = otpGenerator();
    const otpExpires = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes).toISOString();

    // Update existing user (Login)
    const { error: updateError } = await supabase
      .from('users')
      .update({ otp_code: otpCode, otp_expires_at: otpExpires })
      .eq('id', user.id);

    if (updateError) throw updateError;

    // 2. Send SMS via SMS8
    try {
      const result = await SmsService.sendOtp(phone, otpCode);
      console.log(`[AUTH] SMS8 Send Success for ${phone}:`, JSON.stringify(result));
    } catch (smsError) {
      console.error(`[AUTH] SMS8 Send FAILED for ${phone}:`, smsError.message);
      // throw smsError; // Uncomment if you want to block login if SMS fails
    }
    console.log(`[AUTH] Internal OTP Log (Dev): ${phone} -> ${otpCode}`);

    return { message: 'OTP sent successfully' };
  }

  /**
   * Register: Creates user and initial profile, then sends OTP
   */
  static async register(phone, full_name, age) {
    // 1. Check if already exists
    let { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('phone', phone)
      .maybeSingle();

    if (existingUser) {
      throw new Error('Phone number already registered. Please login.');
    }

    const otpCode = otpGenerator();
    const otpExpires = dateHelpers.addMinutes(new Date(), otpConfig.expiresInMinutes).toISOString();

    // Create new user
    const { data: user, error: insertError } = await supabase
      .from('users')
      .insert([{ phone, full_name, otp_code: otpCode, otp_expires_at: otpExpires }])
      .select()
      .single();

    if (insertError) throw insertError;

    // Create initial profile with age
    if (age) {
      const { error: profileError } = await supabase
        .from('mother_profiles')
        .insert([{ user_id: user.id, age: parseInt(age, 10) }]);

      if (profileError) console.error('[AUTH] Failed to create initial profile:', profileError.message);
    }

    // 2. Send SMS via SMS8
    try {
      const result = await SmsService.sendOtp(phone, otpCode);
      console.log(`[AUTH] SMS8 Send Success for ${phone}:`, JSON.stringify(result));
    } catch (smsError) {
      console.error(`[AUTH] SMS8 Send FAILED for ${phone}:`, smsError.message);
    }
    console.log(`[AUTH] Internal OTP Log (Dev): ${phone} -> ${otpCode}`);

    return { message: 'OTP sent successfully' };
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
    const isLocalMatch = user.otp_code === code;
    const isNotExpired = !dateHelpers.isExpired(new Date(user.otp_expires_at));

    if (isLocalMatch && isNotExpired) {
      console.log('[AUTH] Local database OTP match successful');
    } else {
      console.log(`[AUTH] Local verification failed. Match: ${isLocalMatch}, Valid Time: ${isNotExpired}. Trying SMS8...`);
      // 2. If local fails, try external SMS8 verification
      try {
        const sms8Result = await SmsService.verifyOtp(phone, code);
        console.log(`[AUTH] SMS8 Result:`, JSON.stringify(sms8Result));

        // CRITICAL FIX: Check if verified is actually true
        if (!sms8Result || !sms8Result.verified) {
           console.error(`[AUTH] SMS8 Verification Failed: ${sms8Result?.reason || 'Invalid code'}`);
           throw new Error('Invalid OTP code');
        }
      } catch (sms8Error) {
        console.error(`[AUTH] SMS8 Verification Exception:`, sms8Error.message);
        throw new Error(sms8Error.message || 'Invalid OTP code');
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

    if (!user) throw new Error('User not found');
    return this.login(phone);
  }
}

module.exports = AuthService;
