const supabase = require('../../config/supabase');

class SettingsService {
  static async getSettings(userId) {
    let { data, error } = await supabase
      .from('user_settings')
      .select('*')
      .eq('user_id', userId)
      .single();

    if (error && error.code === 'PGRST116') {
      // Create default settings if not exists
      const { data: newSettings, error: insertError } = await supabase
        .from('user_settings')
        .insert([{ user_id: userId }])
        .select()
        .single();

      if (insertError) throw insertError;
      return newSettings;
    }

    if (error) throw error;
    return data;
  }

  static async updateSettings(userId, updateData) {
    const { data, error } = await supabase
      .from('user_settings')
      .update(updateData)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }
}

module.exports = SettingsService;
