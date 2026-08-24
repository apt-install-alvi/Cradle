const supabase = require('../../config/supabase');

class VitalsService {
  static async getVitals(userId, type) {
    let query = supabase
      .from('vitals')
      .select('*')
      .eq('user_id', userId)
      .order('logged_at', { ascending: false });

    if (type) {
      query = query.eq('type', type);
    }

    const { data, error } = await query;
    if (error) throw error;
    return data;
  }

  static async logVital(userId, data) {
    const { data: vital, error } = await supabase
      .from('vitals')
      .insert([
        {
          user_id: userId,
          type: data.type,
          value: data.value,
          systolic: data.systolic,
          diastolic: data.diastolic,
          context: data.context,
          note: data.note,
          logged_at: data.loggedAt || new Date().toISOString()
        }
      ])
      .select()
      .single();

    if (error) throw error;
    return vital;
  }

  static async updateVital(userId, logId, data) {
    const { data: vital, error } = await supabase
      .from('vitals')
      .update({
        value: data.value,
        systolic: data.systolic,
        diastolic: data.diastolic,
        context: data.context,
        note: data.note,
        logged_at: data.loggedAt
      })
      .eq('id', logId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return vital;
  }

  static async deleteVital(userId, logId) {
    const { error } = await supabase
      .from('vitals')
      .delete()
      .eq('id', logId)
      .eq('user_id', userId);

    if (error) throw error;
    return true;
  }

  static async getSettings(userId) {
    const { data, error } = await supabase
      .from('vital_settings')
      .select('*')
      .eq('user_id', userId);

    if (error) throw error;
    return data;
  }

  static async updateSettings(userId, vitalKey, settings = {}) {
    console.log(`[VitalsService] Updating settings for user ${userId}, key ${vitalKey}:`, JSON.stringify(settings));

    const upsertData = {
      user_id: userId,
      vital_key: vitalKey,
      frequency: settings.frequency || 1,
      times: settings.times || ['08:00'],
      days: settings.days || [true, true, true, true, true, true, true],
      is_tracking: settings.isTracking ?? false
    };

    const { data, error } = await supabase
      .from('vital_settings')
      .upsert(upsertData, { onConflict: 'user_id,vital_key' })
      .select();

    if (error) {
      console.error(`[VitalsService] Error in updateSettings:`, error.message, error.details);
      throw error;
    }

    console.log(`[VitalsService] Settings updated successfully:`, data);
    return data && data.length > 0 ? data[0] : null;
  }
}

module.exports = VitalsService;
