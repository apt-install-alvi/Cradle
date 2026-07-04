const Symptom = require('./symptom.model');
const mongoose = require('mongoose');

// In-memory store fallback
const mockSymptoms = [];

class SymptomsService {
  static async logSymptom(userId, symptomData) {
    if (mongoose.connection.readyState !== 1) {
      const newSymptom = {
        _id: 'mock-sym-' + Math.random().toString(36).substring(2, 11),
        userId: userId.toString(),
        symptomsList: symptomData.symptomsList,
        notes: symptomData.notes || '',
        loggedAt: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      };
      mockSymptoms.push(newSymptom);
      return newSymptom;
    }
    const log = new Symptom({ userId, ...symptomData });
    await log.save();
    return log;
  }

  static async getSymptomsHistory(userId) {
    if (mongoose.connection.readyState !== 1) {
      const history = mockSymptoms.filter(s => s.userId === userId.toString());
      if (history.length === 0) {
        // Return seed mock data so dashboards aren't blank
        return [
          {
            _id: 'mock-seed-1',
            userId: userId.toString(),
            symptomsList: [{ name: 'Nausea', severity: 4 }, { name: 'Headache', severity: 3 }],
            notes: 'Felt slight headache in the morning.',
            loggedAt: new Date(Date.now() - 24 * 60 * 60 * 1000)
          },
          {
            _id: 'mock-seed-2',
            userId: userId.toString(),
            symptomsList: [{ name: 'Fatigue', severity: 6 }],
            notes: 'Tired after a short walk.',
            loggedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000)
          }
        ];
      }
      return history.sort((a, b) => b.loggedAt - a.loggedAt);
    }
    return await Symptom.find({ userId }).sort({ loggedAt: -1 });
  }
}

module.exports = SymptomsService;
