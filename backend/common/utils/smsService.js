const axios = require('axios');

/**
 * Service to send SMS via SMS8.io gateway.
 */
class SmsService {
  /**
   * Sends an OTP via SMS8.io
   */
  static async sendOtp(phone, otp) {
    try {
      const url = 'https://app.sms8.io/ajax/otp-send.php';
      const token = process.env.SMS8_API_KEY;

      console.log(`[SMS8] Sending OTP ${otp} to ${phone}...`);

      const params = new URLSearchParams();
      params.append('phone', phone);
      params.append('otp', otp);

      const response = await axios.post(url, params, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      });

      console.log(`[SMS8] Send Response:`, response.data);
      return response.data;
    } catch (error) {
      console.error('[SMS8] Error sending SMS:', error.response?.data || error.message);
      throw new Error('Failed to send SMS via SMS8');
    }
  }

  /**
   * Verifies an OTP via SMS8.io
   */
  static async verifyOtp(phone, otp) {
    try {
      const url = 'https://app.sms8.io/ajax/otp-verify.php';
      const token = process.env.SMS8_API_KEY;

      console.log(`[SMS8] Verifying OTP ${otp} for ${phone}...`);

      const params = new URLSearchParams();
      params.append('phone', phone);
      params.append('code', otp); // Changed from 'otp' to 'code' based on API error message

      const response = await axios.post(url, params, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/x-www-form-urlencoded'
        }
      });

      console.log(`[SMS8] Verify Response:`, response.data);
      return response.data;
    } catch (error) {
      console.error('[SMS8] Error verifying SMS:', error.response?.data || error.message);
      throw new Error('Failed to verify SMS via SMS8');
    }
  }
}

module.exports = SmsService;
