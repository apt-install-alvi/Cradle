const mongoose = require('mongoose');

const dailyHealthStatusSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  mood: {
    type: String
  },
  sleep_hours: {
    type: Number
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

module.exports = mongoose.model('DailyHealthStatus', dailyHealthStatusSchema);
