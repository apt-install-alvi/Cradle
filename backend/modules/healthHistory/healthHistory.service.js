const SymptomsService = require('../symptoms/symptoms.service');
const AiPredictionService = require('../aiPrediction/aiPrediction.service');

class HealthHistoryService {
  static async getIntegratedHistory(userId) {
    const [symptoms, predictions] = await Promise.all([
      SymptomsService.getSymptomsHistory(userId),
      AiPredictionService.getHistory(userId)
    ]);

    return {
      symptomsLogCount: symptoms.length,
      assessmentsCount: predictions.length,
      recentSymptomLog: symptoms[0] || null,
      recentAssessment: predictions[0] || null,
      symptomsTimeline: symptoms,
      assessmentsTimeline: predictions
    };
  }
}

module.exports = HealthHistoryService;
