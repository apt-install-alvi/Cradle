const supabase = require('../../config/supabase');

class SymptomsService {
  static async logSymptom(userId, symptomData) {
    // 1. Create a session in Supabase
    const { data: session, error: sessionError } = await supabase
      .from('symptom_sessions')
      .insert([{ user_id: userId, status: 'IN_PROGRESS' }])
      .select()
      .single();

    if (sessionError) throw sessionError;

    // 2. Insert symptoms if provided
    let symptoms = [];
    if (symptomData.symptomsList && symptomData.symptomsList.length > 0) {
      const symptomsToInsert = symptomData.symptomsList.map(s => ({
        user_id: userId,
        session_id: session.id,
        type: s.name,
        value: s.severity ? s.severity.toString() : '1',
        unit: 'scale_1_10'
      }));

      const { data: insertedSymptoms, error: symptomError } = await supabase
        .from('symptoms')
        .insert(symptomsToInsert)
        .select();

      if (symptomError) throw symptomError;
      symptoms = insertedSymptoms;
    }

    // 3. Insert required diagnosis vitals if provided
    let diagnosisVitals = [];
    if (symptomData.diagnosisVitals && symptomData.diagnosisVitals.length > 0) {
      const vitalsToInsert = symptomData.diagnosisVitals.map(v => ({
        user_id: userId,
        session_id: session.id,
        symptom_type: v.symptom_type,
        vital_name: v.vital_name,
        value: v.value,
        unit: v.unit || ''
      }));

      const { data: insertedVitals, error: vitalError } = await supabase
        .from('diagnosis_vitals')
        .insert(vitalsToInsert)
        .select();

      if (vitalError) {
        console.error('[SymptomsService] Error inserting diagnosis_vitals:', vitalError.message);
        // Note: If the diagnosis_vitals table doesn't exist yet in Supabase,
        // please make sure to create it in your Supabase SQL editor.
        throw vitalError;
      }
      diagnosisVitals = insertedVitals;
    }

    return { session, symptoms, diagnosis_vitals: diagnosisVitals };
  }

  static async getSymptomsHistory(userId) {
    // Fetch sessions
    const { data: sessions, error: sessionError } = await supabase
      .from('symptom_sessions')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (sessionError) throw sessionError;

    // Fetch symptoms and diagnosis vitals for each session
    const history = await Promise.all((sessions || []).map(async (session) => {
      const { data: symptoms } = await supabase
        .from('symptoms')
        .select('*')
        .eq('session_id', session.id);

      const { data: diagnosisVitals } = await supabase
        .from('diagnosis_vitals')
        .select('*')
        .eq('session_id', session.id);

      return {
        ...session,
        symptoms: symptoms || [],
        diagnosis_vitals: diagnosisVitals || []
      };
    }));

    return history;
  }
}

module.exports = SymptomsService;
