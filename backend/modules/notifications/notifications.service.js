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
    const { data, error } = await supabase
      .from('notifications')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', { ascending: false });

    if (error) throw error;
    return data;
  }

  static async markAsRead(userId, notifId) {
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
