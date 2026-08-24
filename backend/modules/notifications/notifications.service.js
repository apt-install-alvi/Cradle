const supabase = require('../../config/supabase');

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

  static async getNotifications(userId) {
    // 1. Get real notifications from DB
    const { data: dbNotifs, error } = await supabase
      .from('notifications')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;

    // 2. Generate dynamic System Notifications (Water & Outbreaks)
    // In a real app, these would come from a background job or a specific outbreaks table.
    const systemNotifs = [
      {
        id: 'water-1',
        title: 'Stay Hydrated!',
        message: 'It has been 2 hours since your last water log. Drink a glass of water now.',
        type: 'WATER_REMINDER',
        created_at: new Date().toISOString(),
        is_read: false
      },
      {
        id: 'outbreak-1',
        title: 'Health Alert: Dengue Outbreak',
        message: 'There is a reported increase in Dengue cases in your area. Please use mosquito nets and repellents.',
        type: 'OUTBREAK_WARNING',
        created_at: new Date(Date.now() - 3600000).toISOString(), // 1 hour ago
        is_read: false
      }
    ];

    return [...systemNotifs, ...dbNotifs];
  }

  static async markAsRead(userId, notifId) {
    if (notifId.startsWith('water-') || notifId.startsWith('outbreak-')) {
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
}

module.exports = NotificationsService;
