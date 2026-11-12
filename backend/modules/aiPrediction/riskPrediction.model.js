const mongoose = require('mongoose');

const riskPredictionSchema = new mongoose.Schema({
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
  risk_level: {
    type: String,
    required: true
  },
  confidence_score: {
    type: Number
  },
  recommendation: {
    type: String
  },
  risk_factors: {
    type: String
  },
  predicted_conditions: {
    type: String
  },
  emergency_contact_notify: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

module.exports = mongoose.model('RiskPrediction', riskPredictionSchema);
