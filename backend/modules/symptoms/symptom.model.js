const mongoose = require('mongoose');

const symptomSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  symptomsList: [{
    name: {
      type: String,
      required: true
    },
    severity: {
      type: Number,
      required: true,
      min: 1,
      max: 10
    }
  }],
  notes: String,
  loggedAt: {
    type: Date,
    default: Date.now
  }
}, { timestamps: true });

module.exports = mongoose.model('Symptom', symptomSchema);
