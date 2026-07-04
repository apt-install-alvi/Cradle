const EmergencyAlert = require('./emergencyAlert.model');
const MotherProfileService = require('../motherProfile/motherProfile.service');
const mongoose = require('mongoose');

// In-memory fallback
const mockAlerts = [];

class EmergencyService {
  static async triggerSOS(userId, location) {
    let contacts = [];
    try {
      const profile = await MotherProfileService.getProfileByUserId(userId);
      contacts = profile.emergencyContacts || [];
    } catch (e) {
      console.warn('Could not retrieve mother profile for SOS emergency contacts.');
    }

    // Simulate SMS dispatch to emergency contacts
    console.log(`[SMS Gateway Alert] SOS Triggered for User ${userId}. Dispatched alerts to:`, contacts);

    if (mongoose.connection.readyState !== 1) {
      const alert = {
        _id: 'mock-sos-' + Math.random().toString(36).substring(2, 11),
        userId: userId.toString(),
        location: location || {},
        triggeredAt: new Date(),
        status: 'TRIGGERED',
        createdAt: new Date()
      };
      mockAlerts.push(alert);
      return { alert, contactsSent: contacts };
    }

    const alert = await EmergencyAlert.create({ userId, location });
    return { alert, contactsSent: contacts };
  }

  static async getAlerts(userId) {
    if (mongoose.connection.readyState !== 1) {
      return mockAlerts.filter(a => a.userId === userId.toString());
    }
    return await EmergencyAlert.find({ userId }).sort({ triggeredAt: -1 });
  }
}

module.exports = EmergencyService;
