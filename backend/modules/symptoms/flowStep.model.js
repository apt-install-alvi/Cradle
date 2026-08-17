const mongoose = require('mongoose');

const symptomFlowStepSchema = new mongoose.Schema({
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
  step_order: {
    type: Number,
    required: true
  },
  selected_option: {
    type: String
  },
  user_input: {
    type: String
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

module.exports = mongoose.model('SymptomFlowStep', symptomFlowStepSchema);
