const supabase = require('../../config/supabase');

class SymptomsService {
  static async logSymptom(userId, symptomData) {
    // 1. Create a session if one isn't provided or we want a fresh one
    const { data: session, error: sessionError } = await supabase
      .from('symptom_sessions')
      .insert([{ user_id: userId, status: 'IN_PROGRESS' }])
      .select()
      .single();

    if (sessionError) throw sessionError;

    // 2. Insert symptoms
    const symptomsToInsert = symptomData.symptomsList.map(s => ({
      user_id: userId,
      session_id: session.id,
      type: s.name,
      value: s.severity.toString(),
      unit: 'scale_1_10'
    }));

    const { data: symptoms, error: symptomError } = await supabase
      .from('symptoms')
      .insert(symptomsToInsert)
      .select();

    if (symptomError) throw symptomError;

    return { session, symptoms };
  }

  static async getSymptomsHistory(userId) {
    const { data, error } = await supabase
      .from('symptom_sessions')
      .select('*, symptoms(*)')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }
}

module.exports = SymptomsService;
