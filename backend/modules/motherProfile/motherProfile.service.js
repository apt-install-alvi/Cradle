const supabase = require('../../config/supabase');

class MotherProfileService {
  /**
   * Retrieves a mother's profile. If it doesn't exist, returns a skeleton
   * containing the name from the main User document.
   */
  static async getProfileByUserId(userId) {
    const { data: profile, error } = await supabase
      .from('mother_profiles')
      .select('*, users(full_name, phone)')
      .eq('user_id', userId)
      .maybeSingle();

    if (!profile) {
      const { data: user, error: userError } = await supabase
        .from('users')
        .select('full_name, phone')
        .eq('id', userId)
        .single();

      return {
        user_id: userId,
        full_name: user?.full_name || '',
        phone: user?.phone || '',
        isNew: true
      };
    }

    // Flatten the result to match expected format
    const result = {
      ...profile,
      full_name: profile.users?.full_name || '',
      phone: profile.users?.phone || ''
    };
    delete result.users;

    return result;
  }

  /**
   * Creates or updates a mother's profile and synchronizes the user's full name.
   */
  static async createOrUpdateProfile(userId, profileData) {
    const { full_name, ...otherData } = profileData;

    // 1. Sync name with User document if provided
    if (full_name !== undefined) {
      await supabase
        .from('users')
        .update({
          full_name: full_name,
          is_profile_completed: true
        })
        .eq('id', userId);
    }

    // 2. Update or Create the MotherProfile document (Upsert)
    const { data: profile, error: upsertError } = await supabase
      .from('mother_profiles')
      .upsert({ user_id: userId, ...otherData }, { onConflict: 'user_id' })
      .select()
      .single();

    if (upsertError) throw upsertError;

    return profile;
  }
}

module.exports = MotherProfileService;
