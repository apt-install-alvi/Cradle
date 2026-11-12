const supabase = require('../../config/supabase');
const { getLocalDateString } = require('../../common/utils/dateHelpers');

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

  static async updateMedicationReminder(userId, reminderId, data) {
    const { data: reminder, error } = await supabase
      .from('medication_reminders')
      .update({
        medication_name: data.medicationName,
        dosage: data.dosage,
        time_of_day: data.timeOfDay,
        is_active: data.isActive !== undefined ? data.isActive : true
      })
      .eq('id', reminderId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return reminder;
  }

  static async deleteMedicationReminder(userId, reminderId) {
    const { error } = await supabase
      .from('medication_reminders')
      .delete()
      .eq('id', reminderId)
      .eq('user_id', userId);

    if (error) throw error;
    return true;
  }

  static async logMedicationDose(userId, reminderId, scheduledTime, localDate) {
    const date = localDate || getLocalDateString();
    const { data, error } = await supabase
      .from('medication_logs')
      .upsert([
        {
          user_id: userId,
          reminder_id: reminderId,
          scheduled_time: scheduledTime,
          log_date: date,
          taken_at: new Date().toISOString(),
          status: 'TAKEN'
        }
      ], { onConflict: 'reminder_id,scheduled_time,log_date' })
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async unlogMedicationDose(userId, reminderId, scheduledTime, localDate) {
    const date = localDate || getLocalDateString();
    const { error } = await supabase
      .from('medication_logs')
      .delete()
      .match({
        user_id: userId,
        reminder_id: reminderId,
        scheduled_time: scheduledTime,
        log_date: date
      });

    if (error) throw error;
    return true;
  }

  static async getAdherence(userId, localDate) {
    // Get all reminders to know the denominator
    const { data: reminders } = await supabase
      .from('medication_reminders')
      .select('id, time_of_day')
      .eq('user_id', userId)
      .eq('is_active', true);

    // Get logs for the last 30 days
    const endDate = localDate ? new Date(localDate) : new Date();
    const thirtyDaysAgo = new Date(endDate);
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const { data: logs, error } = await supabase
      .from('medication_logs')
      .select('log_date, reminder_id')
      .eq('user_id', userId)
      .gte('log_date', getLocalDateString(thirtyDaysAgo));

    if (error) throw error;

    // Calculate adherence percentage per day
    // This is a simplified calculation
    const logsPerDay = {};
    logs.forEach(log => {
      logsPerDay[log.log_date] = (logsPerDay[log.log_date] || 0) + 1;
    });

    const totalDosesPerDay = reminders.reduce((acc, r) => acc + (r.time_of_day?.length || 0), 0);

    const adherence = {};
    Object.keys(logsPerDay).forEach(date => {
      adherence[date] = totalDosesPerDay > 0
        ? Math.round((logsPerDay[date] / totalDosesPerDay) * 100)
        : 0;
    });

    return adherence;
  }

  static async getTodayLogs(userId, localDate) {
    const date = localDate || getLocalDateString();
    const { data, error } = await supabase
      .from('medication_logs')
      .select('reminder_id, scheduled_time')
      .eq('user_id', userId)
      .eq('log_date', date);

    if (error) throw error;
    return data;
  }
}

module.exports = AppointmentsService;
