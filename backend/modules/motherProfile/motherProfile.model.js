const mongoose = require('mongoose');

const motherProfileSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  fullName: {
    type: String,
    required: true,
    trim: true
  },
  age: {
    type: Number,
    required: true
  },
  dueDate: {
    type: Date,
    required: true
  },
  bloodGroup: {
    type: String,
    trim: true
  },
  medicalHistory: [String],
  emergencyContacts: [{
    name: String,
    relation: String,
    phone: String
  }]
}, { timestamps: true });

module.exports = mongoose.model('MotherProfile', motherProfileSchema);
