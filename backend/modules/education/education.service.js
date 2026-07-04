const EducationArticle = require('./educationArticle.model');
const mongoose = require('mongoose');

// Seed dummy articles for local testing
const mockArticles = [
  {
    _id: 'art-1',
    title: 'Managing Morning Sickness: Diet and Tips',
    content: 'Morning sickness is common in the first trimester. Focus on small, frequent meals containing ginger, peppermint, and light crackers. Avoid greasy food and drink plenty of clear fluids between meals.',
    category: 'NUTRITION',
    trimester: 1,
    imageUrl: 'https://images.unsplash.com/photo-1511556532299-8f662fc26c06',
    readingTimeMinutes: 4
  },
  {
    _id: 'art-2',
    title: 'Safe Physical Exercises for Second Trimester',
    content: 'During the second trimester, gentle exercises like prenatal yoga, swimming, and stationary cycling are highly beneficial. Always listen to your body, avoid lying flat on your back, and stay well hydrated.',
    category: 'EXERCISE',
    trimester: 2,
    imageUrl: 'https://images.unsplash.com/photo-1518611012118-696072aa579a',
    readingTimeMinutes: 5
  },
  {
    _id: 'art-3',
    title: 'Recognizing Early Signs of Labor',
    content: 'Signs of labor include regular contractions that get closer together, pain in the lower back/abdomen, and water breaking. Keep your doctor\'s number on speed dial and prepare your hospital bag early.',
    category: 'LABOR',
    trimester: 3,
    imageUrl: 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528',
    readingTimeMinutes: 6
  }
];

class EducationService {
  static async getArticles(trimester) {
    if (mongoose.connection.readyState !== 1) {
      if (trimester) {
        return mockArticles.filter(a => a.trimester === parseInt(trimester, 10) || a.trimester === 0);
      }
      return mockArticles;
    }
    const filter = {};
    if (trimester) {
      filter.trimester = { $in: [parseInt(trimester, 10), 0] };
    }
    return await EducationArticle.find(filter);
  }

  static async getArticleById(id) {
    if (mongoose.connection.readyState !== 1) {
      const art = mockArticles.find(a => a._id === id);
      if (!art) throw new Error('Article not found');
      return art;
    }
    return await EducationArticle.findById(id);
  }
}

module.exports = EducationService;
