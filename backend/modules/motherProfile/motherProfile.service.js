const MotherProfile = require('./motherProfile.model');
const User = require('../auth/user.model');
const mongoose = require('mongoose');

// In-memory fallback database
const mockProfiles = new Map();

class MotherProfileService {
  static async getProfileByUserId(userId) {
    if (mongoose.connection.readyState !== 1) {
      const profile = mockProfiles.get(userId.toString());
      if (!profile) {
        // Return a default mock profile if requested but not initialized
        return {
          userId: userId.toString(),
          fullName: 'Jane Doe',
          age: 28,
          dueDate: new Date(Date.now() + 180 * 24 * 60 * 60 * 1000), // 6 months from now
          bloodGroup: 'O+',
          medicalHistory: ['No known allergies'],
          emergencyContacts: [{ name: 'John Doe', relation: 'Husband', phone: '+1234567890' }]
        };
      }
      return profile;
    }
    const profile = await MotherProfile.findOne({ userId });
    if (!profile) throw new Error('Profile not found');
    return profile;
  }

  static async createOrUpdateProfile(userId, profileData) {
    if (mongoose.connection.readyState !== 1) {
      const profile = {
        _id: 'mock-pid-' + Math.random().toString(36).substring(2, 11),
        userId: userId.toString(),
        fullName: profileData.fullName,
        age: profileData.age,
        dueDate: new Date(profileData.dueDate),
        bloodGroup: profileData.bloodGroup || '',
        medicalHistory: profileData.medicalHistory || [],
        emergencyContacts: profileData.emergencyContacts || [],
        createdAt: new Date(),
        updatedAt: new Date()
      };
      mockProfiles.set(userId.toString(), profile);
      console.log(`[MOCK DB] Mother profile created/updated for user: ${userId}`);
      return profile;
    }

    let profile = await MotherProfile.findOne({ userId });
    if (profile) {
      Object.assign(profile, profileData);
      await profile.save();
    } else {
      profile = new MotherProfile({ userId, ...profileData });
      await profile.save();
      await User.findByIdAndUpdate(userId, { isProfileCompleted: true });
    }
    return profile;
  }
}

module.exports = MotherProfileService;
