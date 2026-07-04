const axios = require('axios');
const env = require('../../config/env');
const riskLevels = require('../../common/constants/riskLevels');

class AiClient {
  static async predictRisk(symptomsList) {
    try {
      const response = await axios.post(
        `${env.ML_SERVICE_URL}/predict`, 
        { symptoms: symptomsList }, 
        { timeout: 3000 }
      );
      return response.data;
    } catch (error) {
      console.warn(`[AI Client Warning] Failed to connect to ml-service at ${env.ML_SERVICE_URL}: ${error.message}. Running rule-based fallback evaluation.`);
      return this.fallbackRuleEngine(symptomsList);
    }
  }

  static fallbackRuleEngine(symptomsList) {
    let maxSeverity = 0;
    for (const symptom of symptomsList) {
      if (symptom.severity > maxSeverity) {
        maxSeverity = symptom.severity;
      }
    }

    let riskLevel = riskLevels.LOW;
    let confidenceScore = 0.95;
    let recommendations = [
      'Continue drinking water and tracking your daily symptoms.',
      'Maintain adequate sleep and regular light physical movement.'
    ];

    if (maxSeverity >= 8) {
      riskLevel = riskLevels.CRITICAL;
      confidenceScore = 0.92;
      recommendations = [
        'WARNING: Critical symptoms reported! Please contact your healthcare provider or emergency contacts immediately.',
        'Go to the nearest emergency ward if you experience bleeding or severe abdominal pain.'
      ];
    } else if (maxSeverity >= 6) {
      riskLevel = riskLevels.HIGH;
      confidenceScore = 0.88;
      recommendations = [
        'Schedule a routine check-up with your primary physician as soon as possible.',
        'Rest in a quiet, dark room, and monitor closely for changes in severity.'
      ];
    } else if (maxSeverity >= 4) {
      riskLevel = riskLevels.MEDIUM;
      confidenceScore = 0.85;
      recommendations = [
        'Ensure you are getting enough rest and monitoring your stress levels.',
        'Consult with a physician if this symptom persists for more than 48 hours.'
      ];
    }

    return {
      success: true,
      riskLevel,
      confidenceScore,
      recommendations
    };
  }
}

module.exports = AiClient;
