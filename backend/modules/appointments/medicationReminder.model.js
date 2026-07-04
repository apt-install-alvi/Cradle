const mongoose = require('mongoose');

const medicationReminderSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  medicationName: {
    type: String,
    required: true,
    trim: true
  },
  dosage: String,
  timeOfDay: [String], // e.g. ["08:00", "20:00"]
  startDate: {
    type: Date,
    default: Date.now
  },
  endDate: Date,
  isActive: {
    type: Boolean,
    default: true
  }
}, { timestamps: true });

module.exports = mongoose.model('MedicationReminder', medicationReminderSchema);
