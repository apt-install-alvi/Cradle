const supabase = require('../../config/supabase');
const { getLocalDateString } = require('../../common/utils/dateHelpers');

class WaterService {
  static async logWater(userId, amountMl = 250) {
    const { data, error } = await supabase
      .from('water_logs')
      .insert([{ user_id: userId, amount_ml: amountMl }])
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async getLatestLog(userId) {
    const { data, error } = await supabase
      .from('water_logs')
      .select('*')
      .eq('user_id', userId)
      .order('logged_at', { ascending: false })
      .limit(1)
      .maybeSingle();

    if (error) throw error;
    return data;
  }

  static async getDailyTotal(userId, localDate) {
    const date = localDate || getLocalDateString();
    const { data, error } = await supabase
      .from('water_logs')
      .select('amount_ml')
      .eq('user_id', userId)
      .gte('logged_at', date);

    if (error) throw error;
    return data.reduce((sum, log) => sum + log.amount_ml, 0);
  }
}

module.exports = WaterService;
