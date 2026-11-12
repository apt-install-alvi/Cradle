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
    const { data: predictions, error } = await supabase
      .from('ai_predictions')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    const historyWithDetails = await Promise.all((predictions || []).map(async (pred) => {
      let symptoms = [];
      let diagnosisVitals = [];

      if (pred.session_id) {
        const { data: syms } = await supabase
          .from('symptoms')
          .select('*')
          .eq('session_id', pred.session_id);
        symptoms = syms || [];

        const { data: vitals } = await supabase
          .from('diagnosis_vitals')
          .select('*')
          .eq('session_id', pred.session_id);
        diagnosisVitals = vitals || [];
      }

      return {
        ...pred,
        symptoms,
        diagnosis_vitals: diagnosisVitals
      };
    }));

    return historyWithDetails;
  }
}

module.exports = AiPredictionService;
