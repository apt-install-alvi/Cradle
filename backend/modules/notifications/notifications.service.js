const supabase = require('../../config/supabase');
const SettingsService = require('../settings/settings.service');
const WaterService = require('../water/water.service');
const AppointmentsService = require('../appointments/appointments.service');
const VitalsService = require('../vitals/vitals.service');
const { getLocalDateString } = require('../../common/utils/dateHelpers');

class NotificationsService {
  static async sendNotification(userId, title, message, type = 'GENERAL') {
    const { data: notif, error } = await supabase
      .from('notifications')
      .insert([
        {
          user_id: userId,
          title,
          message,
          type,
          is_read: false
        }
      ])
      .select()
      .single();

    if (error) throw error;
    return notif;
  }

  static async getNotifications(userId, localDate, localTime) {
    // 1. Get real notifications from DB
    const { data: dbNotifs, error } = await supabase
      .from('notifications')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    // 2. Fetch User Settings & Data for Dynamic Reminders with Safety
    let settings, lastWater, reminders = [], todayLogs = [], vitalSettings = [], vitalLogs = [];
    try {
      [settings, lastWater, reminders, todayLogs, vitalSettings, vitalLogs] = await Promise.all([
        SettingsService.getSettings(userId).catch(e => { console.error('Settings error:', e); return null; }),
        WaterService.getLatestLog(userId).catch(e => { console.error('Water log error:', e); return null; }),
        AppointmentsService.getMedicationReminders(userId).catch(e => { console.error('Medication reminders error:', e); return []; }),
        AppointmentsService.getTodayLogs(userId, localDate).catch(e => { console.error('Today logs error:', e); return []; }),
        VitalsService.getSettings(userId).catch(e => { console.error('Vital settings error:', e); return []; }),
        VitalsService.getVitals(userId).catch(e => { console.error('Vital logs error:', e); return []; })
      ]);
    } catch (e) {
      console.error('Dynamic notifications fetch error:', e);
    }

    const systemNotifs = [];

    // --- Dynamic Water Reminder ---
    const now = new Date();
    const lastWaterTime = lastWater ? new Date(lastWater.logged_at) : null;

    // If no water logged today or last log > 2 hours ago
    const twoHoursInMs = 2 * 60 * 60 * 1000;
    if (!lastWaterTime || (now - lastWaterTime) > twoHoursInMs) {
      systemNotifs.push({
        id: 'water-dynamic',
        title: 'Stay Hydrated!',
        message: lastWaterTime
          ? `It's been over 2 hours since your last glass. Drink some water!`
          : 'You haven\'t logged any water today. Stay hydrated!',
        type: 'WATER_REMINDER',
        created_at: now.toISOString(),
        is_read: false
      });
    }

    // --- Dynamic Medication Reminder ---
    const currentTimeStr = localTime || `${String(now.getHours()).padStart(2, '0')}:${String(now.getMinutes()).padStart(2, '0')}`;

    reminders.forEach(reminder => {
      reminder.time_of_day.forEach(scheduledTime => {
        // If the time has passed today
        if (scheduledTime <= currentTimeStr) {
          // Check if it was logged
          const wasTaken = todayLogs.some(log =>
            log.reminder_id === reminder.id && log.scheduled_time === scheduledTime
          );

          if (!wasTaken) {
            systemNotifs.push({
              id: `med-${reminder.id}-${scheduledTime}`,
              title: 'Medication Reminder',
              message: `It's time for your ${reminder.medication_name} (${reminder.dosage}).`,
              type: 'MEDICATION',
              created_at: new Date().toISOString(),
              is_read: false
            });
          }
        }
      });
    });

    // --- Dynamic Vital Reminders ---
    vitalSettings.forEach(vSetting => {
      if (!vSetting.is_tracking) return;

      vSetting.times.forEach(scheduledTime => {
        // If the time has passed today
        if (scheduledTime <= currentTimeStr) {
          // Check if it was logged today around that time (simple check: any log of that type today after scheduled time)
          // Ideally we'd check for a log within a window of the scheduled time.
          const hasLog = vitalLogs.some(log => {
            const logDate = new Date(log.logged_at);
            const logDateStr = getLocalDateString(logDate);
            const logTimeStr = `${String(logDate.getHours()).padStart(2, '0')}:${String(logDate.getMinutes()).padStart(2, '0')}`;
            return log.type === vSetting.vital_key && logDateStr === localDate && logTimeStr >= scheduledTime;
          });

          if (!hasLog) {
            const vitalName = vSetting.vital_key === 'bp' ? 'Blood Pressure' :
                              vSetting.vital_key === 'temp' ? 'Temperature' :
                              vSetting.vital_key === 'glucose' ? 'Blood Glucose' :
                              vSetting.vital_key === 'spo2' ? 'SpO2' :
                              vSetting.vital_key === 'hr' ? 'Heart Rate' : vSetting.vital_key;

            systemNotifs.push({
              id: `vital-${vSetting.vital_key}-${scheduledTime}`,
              title: 'Health Check Reminder',
              message: `It's time to check your ${vitalName}.`,
              type: 'HEALTH_CHECK',
              created_at: new Date().toISOString(),
              is_read: false
            });
          }
        }
      });
    });

    // --- Static / Outbreak Warnings ---
    systemNotifs.push({
      id: 'outbreak-1',
      title: 'Health Alert: Dengue Outbreak',
      message: 'There is a reported increase in Dengue cases in your area. Please use mosquito nets and repellents.',
      type: 'OUTBREAK_WARNING',
      created_at: new Date(Date.now() - 3600000).toISOString(),
      is_read: false
    });

    return [...systemNotifs, ...dbNotifs];
  }

  static async markAsRead(userId, notifId) {
    if (notifId.startsWith('water-') || notifId.startsWith('med-') || notifId.startsWith('outbreak-')) {
        return { id: notifId, is_read: true }; // Virtual mock read
    }

    const { data, error } = await supabase
      .from('notifications')
      .update({ is_read: true })
      .eq('id', notifId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error) throw error;
    return data;
  }

  static async markAllAsRead(userId) {
    const { error } = await supabase
      .from('notifications')
      .update({ is_read: true })
      .eq('user_id', userId)
      .eq('is_read', false);

    if (error) throw error;
    return true;
  }
}

module.exports = NotificationsService;
