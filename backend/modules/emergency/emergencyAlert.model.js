const mongoose = require('mongoose');

const emergencyAlertSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  location: {
    latitude: Number,
    longitude: Number,
    address: String
  },
  triggeredAt: {
    type: Date,
    default: Date.now
  },
  status: {
    type: String,
    enum: ['TRIGGERED', 'RESOLVED', 'ACKNOWLEDGED'],
    default: 'TRIGGERED'
  }
}, { timestamps: true });

module.exports = mongoose.model('EmergencyAlert', emergencyAlertSchema);
