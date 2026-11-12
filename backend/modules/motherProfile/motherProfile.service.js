const supabase = require('../../config/supabase');

class MotherProfileService {
  /**
   * Retrieves a mother's profile.
   * If it doesn't exist, returns a skeleton containing
   * the name from the main User document.
   */
  static async getProfileByUserId(userId) {
    const { data: profile, error: profileError } = await supabase
      .from('mother_profiles')
      .select('*, users(full_name, phone, is_profile_completed)')
      .eq('user_id', userId)
      .maybeSingle();

    if (profileError) {
      throw profileError;
    }

    if (!profile) {
      const { data: user, error: userError } = await supabase
        .from('users')
        .select('full_name, phone, is_profile_completed')
        .eq('id', userId)
        .single();

      if (userError) {
        throw userError;
      }

      return {
        user_id: userId,
        full_name: user?.full_name || '',
        phone: user?.phone || '',
        is_profile_completed:
          user?.is_profile_completed || false,
        emergency_contact: [],
        isNew: true,
      };
    }

    const result = {
      ...profile,
      full_name: profile.users?.full_name || '',
      phone: profile.users?.phone || '',
      is_profile_completed:
        profile.users?.is_profile_completed || false,

      // Always return an array.
      emergency_contact: Array.isArray(profile.emergency_contact)
        ? profile.emergency_contact
        : [],
    };

    delete result.users;

    return result;
  }

  /**
   * Creates or updates a mother's profile and synchronizes
   * the user's full name.
   */
  static async createOrUpdateProfile(userId, profileData) {
    const { full_name, ...otherData } = profileData;

    // Normalize emergency contacts on the backend too.
    if (otherData.emergency_contact !== undefined) {
      if (!Array.isArray(otherData.emergency_contact)) {
        throw new Error(
          'Emergency contacts must be an array'
        );
      }

      otherData.emergency_contact = otherData.emergency_contact
        .map((contact) => String(contact).trim())
        .filter((contact) => contact.length > 0);
    }

    // Sync name with User document.
    if (full_name !== undefined) {
      const { error: userError } = await supabase
        .from('users')
        .update({
          full_name: full_name,
          is_profile_completed: true,
        })
        .eq('id', userId);

      if (userError) {
        throw userError;
      }
    }

    // Create/update MotherProfile.
    const { data: profile, error: upsertError } = await supabase
      .from('mother_profiles')
      .upsert(
        {
          user_id: userId,
          ...otherData,
        },
        {
          onConflict: 'user_id',
        }
      )
      .select()
      .single();

    if (upsertError) {
      throw upsertError;
    }

    return profile;
  }
}

module.exports = MotherProfileService;