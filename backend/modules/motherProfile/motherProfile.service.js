const MotherProfile = require('./motherProfile.model');
const User = require('../auth/user.model');

class MotherProfileService {
  /**
   * Retrieves a mother's profile. If it doesn't exist, returns a skeleton
   * containing the name from the main User document.
   */
  static async getProfileByUserId(userId) {
    let profile = await MotherProfile.findOne({ user_id: userId });

    // If no profile exists yet, fetch the name from the User account to pre-fill
    if (!profile) {
      const user = await User.findById(userId);
      return {
        user_id: userId,
        full_name: user?.full_name || '',
        phone: user?.phone || '',
        isNew: true
      };
    }

    // Merge in the latest name from the User document
    const user = await User.findById(userId);
    const result = profile.toObject();
    result.full_name = user?.full_name || '';
    result.phone = user?.phone || '';

    return result;
  }

  /**
   * Creates or updates a mother's profile and synchronizes the user's full name.
   */
  static async createOrUpdateProfile(userId, profileData) {
    const { full_name, ...otherData } = profileData;

    // 1. Sync name with User document if provided
    if (full_name !== undefined) {
      await User.findByIdAndUpdate(userId, {
        full_name: full_name,
        isProfileCompleted: true
      });
    }

    // 2. Update or Create the MotherProfile document
    let profile = await MotherProfile.findOneAndUpdate(
      { user_id: userId },
      { $set: otherData },
      { new: true, upsert: true }
    );

    return profile;
  }
}

module.exports = MotherProfileService;
