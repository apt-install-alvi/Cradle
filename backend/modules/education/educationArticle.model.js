const mongoose = require('mongoose');

const educationArticleSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    trim: true
  },
  content: {
    type: String,
    required: true
  },
  category: {
    type: String,
    enum: ['NUTRITION', 'EXERCISE', 'SYMPTOMS', 'LABOR', 'NEWBORN', 'GENERAL'],
    default: 'GENERAL'
  },
  trimester: {
    type: Number,
    enum: [1, 2, 3, 0], // 0 for general or applicable to all
    default: 0
  },
  imageUrl: String,
  readingTimeMinutes: Number
}, { timestamps: true });

module.exports = mongoose.model('EducationArticle', educationArticleSchema);
