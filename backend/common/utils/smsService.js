const axios = require('axios');
const env = require('../../config/env');

class SmsService {
  /**
   * Send Voice Call OTP using Infobip Voice Text-to-Speech API
   * Calls the user's phone and speaks out the verification code.
   * @param {string} to - Destination phone number (e.g. +8801XXXXXXXXX or 8801XXXXXXXXX)
   * @param {string} code - 6-digit numeric OTP code
   */
  static async sendVoiceOtp(to, code) {
    const formattedTo = to.startsWith('+') ? to.substring(1) : to;

    if (env.INFOBIP_API_KEY && env.INFOBIP_BASE_URL) {
      try {
        let baseUrl = env.INFOBIP_BASE_URL.trim().replace(/\/$/, '');
        if (!baseUrl.startsWith('http://') && !baseUrl.startsWith('https://')) {
          baseUrl = `https://${baseUrl}`;
        }

        const spacedCode = code.split('').join(' ');
        const speechText = `Hello. Your Cradle verification code is ${spacedCode}. I repeat, ${spacedCode}. Thank you.`;

        const response = await axios.post(
          `${baseUrl}/tts/3/advanced`,
          {
            messages: [
              {
                destinations: [{ to: formattedTo }],
                text: speechText,
                language: 'en',
                speechRate: 0.85
              }
            ]
          },
          {
            headers: {
              'Authorization': `App ${env.INFOBIP_API_KEY}`,
              'Content-Type': 'application/json',
              'Accept': 'application/json'
            }
          }
        );

        console.log(`[INFOBIP VOICE] Voice call OTP placed to ${to}. Response:`, response.data);
        return { success: true, data: response.data };
      } catch (err) {
        const errorDetails = err.response ? JSON.stringify(err.response.data) : err.message;
        console.error(`[INFOBIP VOICE ERROR] Failed to place voice call to ${to}:`, errorDetails);
        return { success: false, error: errorDetails };
      }
    }

    console.log(`[INFOBIP MOCK VOICE] Credentials missing. Simulated Voice Call OTP to ${to}: Code ${code}`);
    return { success: true, simulated: true };
  }

  // Alias sendSmsOtp to sendVoiceOtp so auth.service requires no breaking changes
  static async sendSmsOtp(to, code) {
    return this.sendVoiceOtp(to, code);
  }
}

module.exports = SmsService;
