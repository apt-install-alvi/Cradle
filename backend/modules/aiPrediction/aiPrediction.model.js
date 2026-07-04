const mongoose = require('mongoose');

const aiPredictionSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  symptomLogId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Symptom'
  },
  riskLevel: {
    type: String,
    enum: ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'],
    required: true
  },
  confidenceScore: {
    type: Number,
    required: true
  },
  recommendations: [String],
  assessedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

module.exports = mongoose.model('AiPrediction', aiPredictionSchema);
