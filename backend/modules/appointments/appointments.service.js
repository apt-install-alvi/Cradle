const supabase = require('../../config/supabase');

class AppointmentsService {
  static async createAppointment(userId, data) {
    const { data: appt, error } = await supabase
      .from('appointments')
      .insert([
        {
          user_id: userId,
          doctor_name: data.doctorName,
          clinic_name: data.clinicName,
          date_time: data.dateTime,
          purpose: data.purpose,
          notes: data.notes,
          status: 'SCHEDULED'
        }
      ])
      .select()
      .single();

    if (error) throw error;
    return appt;
  }

  static async getAppointments(userId) {
    const { data, error } = await supabase
      .from('appointments')
      .select('*')
      .eq('user_id', userId)
      .order('date_time', { ascending: true });

    if (error) throw error;
    return data;
  }

  static async createMedicationReminder(userId, data) {
    const { data: reminder, error } = await supabase
      .from('medication_reminders')
      .insert([
        {
          user_id: userId,
          medication_name: data.medicationName,
          dosage: data.dosage,
          time_of_day: data.timeOfDay,
          is_active: true
        }
      ])
      .select()
      .single();

    if (error) throw error;
    return reminder;
  }

  static async getMedicationReminders(userId) {
    const { data, error } = await supabase
      .from('medication_reminders')
      .select('*')
      .eq('user_id', userId)
      .eq('is_active', true);

    if (error) throw error;
    return data;
  }
}

module.exports = AppointmentsService;
