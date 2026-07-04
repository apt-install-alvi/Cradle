const AiPrediction = require('./aiPrediction.model');
const AiClient = require('./aiClient');
const mongoose = require('mongoose');

// In-memory store fallback
const mockPredictions = [];

class AiPredictionService {
  static async assessRisk(userId, symptomLogId, symptomsList) {
    const aiResult = await AiClient.predictRisk(symptomsList);

    if (mongoose.connection.readyState !== 1) {
      const assessment = {
        _id: 'mock-pred-' + Math.random().toString(36).substring(2, 11),
        userId: userId.toString(),
        symptomLogId: symptomLogId ? symptomLogId.toString() : null,
        riskLevel: aiResult.riskLevel,
        confidenceScore: aiResult.confidenceScore,
        recommendations: aiResult.recommendations,
        assessedAt: new Date(),
        createdAt: new Date(),
        updatedAt: new Date()
      };
      mockPredictions.push(assessment);
      return assessment;
    }

    const prediction = new AiPrediction({
      userId,
      symptomLogId,
      riskLevel: aiResult.riskLevel,
      confidenceScore: aiResult.confidenceScore,
      recommendations: aiResult.recommendations
    });

    await prediction.save();
    return prediction;
  }

  static async getHistory(userId) {
    if (mongoose.connection.readyState !== 1) {
      const history = mockPredictions.filter(p => p.userId === userId.toString());
      if (history.length === 0) {
        return [
          {
            _id: 'mock-pred-seed-1',
            userId: userId.toString(),
            riskLevel: 'LOW',
            confidenceScore: 0.95,
            recommendations: ['Continue drinking water and tracking your daily symptoms.'],
            assessedAt: new Date(Date.now() - 24 * 60 * 60 * 1000)
          }
        ];
      }
      return history.sort((a, b) => b.assessedAt - a.assessedAt);
    }
    return await AiPrediction.find({ userId }).sort({ assessedAt: -1 });
  }
}

module.exports = AiPredictionService;
