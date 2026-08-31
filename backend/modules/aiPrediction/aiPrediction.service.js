const supabase = require('../../config/supabase');
const AiClient = require('./aiClient');

class AiPredictionService {
  static async assessRisk(userId, session_id, symptomsList, features) {
    const aiResult = await AiClient.predictRisk(symptomsList, features);

    const { data: prediction, error } = await supabase
      .from('ai_predictions')
      .insert([
        {
          user_id: userId,
          session_id: session_id,
          prediction_data: aiResult,
          risk_level: aiResult.riskLevel
        }
      ])
      .select()
      .single();

    if (error) throw error;
    return prediction;
  }

  static async getHistory(userId) {
    const { data, error } = await supabase
      .from('ai_predictions')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }
}

module.exports = AiPredictionService;
