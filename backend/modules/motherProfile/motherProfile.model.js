const mongoose = require('mongoose');

const motherProfileSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  blood_group: {
    type: String,
    trim: true
  },
  age: {
    type: Number
  },
  weight: {
    type: Number
  },
  height: {
    type: Number
  },
  conception_date: {
    type: Date
  },
  expected_due_date: {
    type: Date
  },
  pregnancy_week: {
    type: Number
  },
  allergies: {
    type: String
  },
  long_term_diseases: {
    type: String
  },
  emergency_contact: {
    type: String
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

module.exports = mongoose.model('MotherProfile', motherProfileSchema);
