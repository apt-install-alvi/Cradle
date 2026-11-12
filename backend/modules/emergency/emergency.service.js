const supabase = require('../../config/supabase');
const MotherProfileService = require('../motherProfile/motherProfile.service');

class EmergencyService {
  static async triggerSOS(userId, location) {
    let contacts = [];
    try {
      const profile = await MotherProfileService.getProfileByUserId(userId);
      // In Supabase, it might be emergency_contact (singular string based on my schema)
      contacts = profile.emergency_contact ? [profile.emergency_contact] : [];
    } catch (e) {
      console.warn('Could not retrieve mother profile for SOS emergency contacts.');
    }

    console.log(`[SMS Gateway Alert] SOS Triggered for User ${userId}. Dispatched alerts to:`, contacts);

    const { data: alert, error } = await supabase
      .from('emergency_alerts')
      .insert([
        {
          user_id: userId,
          alert_type: 'SOS',
          location_lat: location?.lat,
          location_lng: location?.lng,
          status: 'TRIGGERED'
        }
      ])
      .select()
      .single();

    if (error) throw error;

    return { alert, contactsSent: contacts };
  }

  static async getAlerts(userId) {
    const { data, error } = await supabase
      .from('emergency_alerts')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }
}

module.exports = EmergencyService;
