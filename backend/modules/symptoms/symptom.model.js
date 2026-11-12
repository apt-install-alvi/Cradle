const mongoose = require('mongoose');

const symptomSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  session_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SymptomSession',
    required: true
  },
  type: {
    type: String,
    required: true
  },
  value: {
    type: String
  },
  unit: {
    type: String
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

module.exports = mongoose.model('Symptom', symptomSchema);
