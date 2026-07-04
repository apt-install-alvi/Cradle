const mongoose = require('mongoose');

const appointmentSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  doctorName: {
    type: String,
    required: true,
    trim: true
  },
  clinicName: String,
  dateTime: {
    type: Date,
    required: true
  },
  purpose: String,
  notes: String,
  status: {
    type: String,
    enum: ['SCHEDULED', 'COMPLETED', 'CANCELLED'],
    default: 'SCHEDULED'
  }
}, { timestamps: true });

module.exports = mongoose.model('Appointment', appointmentSchema);
