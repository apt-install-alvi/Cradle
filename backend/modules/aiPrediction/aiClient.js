const axios = require('axios');
const env = require('../../config/env');
const riskLevels = require('../../common/constants/riskLevels');

class AiClient {
  static async predictRisk(symptomsList, features) {
    try {
      const response = await axios.post(
        `${env.ML_SERVICE_URL}/predict`, 
        { symptoms: symptomsList, features: features }, 
        { timeout: 3000 }
      );
      return response.data;
    } catch (error) {
      console.warn(`[AI Client Warning] Failed to connect to ml-service at ${env.ML_SERVICE_URL}: ${error.message}. Running rule-based fallback evaluation.`);
      return this.fallbackRuleEngine(symptomsList, features);
    }
  }

  static fallbackRuleEngine(symptomsList, features) {
    if (features) {
      const age = parseFloat(features.age ?? 25.0);
      const temp = parseFloat(features.body_temp ?? 98.6);
      const hr = parseFloat(features.heart_rate ?? 75.0);
      const sys = parseFloat(features.systolic_bp ?? 120.0);
      const dia = parseFloat(features.diastolic_bp ?? 80.0);
      const bmi = parseFloat(features.bmi ?? 22.0);
      const hba1c = parseFloat(features.hba1c ?? 5.4);
      const fasting = parseFloat(features.fasting_glucose ?? 85.0);

      let riskLevel = riskLevels.LOW;
      let reasons = [];

      // 1. Blood Pressure / Preeclampsia
      if (sys >= 160 || dia >= 110) {
        riskLevel = riskLevels.CRITICAL;
        reasons.push("Severe hypertension (BP >= 160/110 mmHg)");
      } else if (sys >= 140 || dia >= 90) {
        if (riskLevel !== riskLevels.CRITICAL) riskLevel = riskLevels.HIGH;
        reasons.push("High Blood Pressure (BP >= 140/90 mmHg)");
      } else if (sys >= 130 || dia >= 85) {
        if (riskLevel !== riskLevels.CRITICAL && riskLevel !== riskLevels.HIGH) riskLevel = riskLevels.MEDIUM;
        reasons.push("Elevated Blood Pressure (BP >= 130/85 mmHg)");
      }

      // 2. Temperature (Fever/Infection)
      if (temp >= 103.0) {
        riskLevel = riskLevels.CRITICAL;
        reasons.push("Very high fever (Temp >= 103°F)");
      } else if (temp >= 100.4) {
        if (riskLevel !== riskLevels.CRITICAL) riskLevel = riskLevels.HIGH;
        reasons.push("Fever (Temp >= 100.4°F)");
      }

      // 3. Heart Rate
      if (hr >= 120 || hr < 50) {
        if (riskLevel !== riskLevels.CRITICAL) riskLevel = riskLevels.HIGH;
        reasons.push("Abnormal Heart Rate");
      } else if (hr >= 100 || hr < 60) {
        if (riskLevel !== riskLevels.CRITICAL && riskLevel !== riskLevels.HIGH) riskLevel = riskLevels.MEDIUM;
        reasons.push("Mildly abnormal Heart Rate");
      }

      // 4. Blood Glucose (Gestational Diabetes)
      if (hba1c >= 6.5 || fasting >= 126.0) {
        if (riskLevel !== riskLevels.CRITICAL) riskLevel = riskLevels.HIGH;
        reasons.push("High Blood Glucose in diabetic range");
      } else if (hba1c >= 5.7 || fasting >= 95.0) {
        if (riskLevel !== riskLevels.CRITICAL && riskLevel !== riskLevels.HIGH) riskLevel = riskLevels.MEDIUM;
        reasons.push("Elevated Blood Glucose in pre-diabetic range");
      }

      // 5. BMI
      if (bmi >= 35.0 || bmi < 18.5) {
        if (riskLevel !== riskLevels.CRITICAL && riskLevel !== riskLevels.HIGH) riskLevel = riskLevels.MEDIUM;
        reasons.push(`Abnormal BMI: ${bmi.toFixed(1)} kg/m²`);
      }

      // 6. Age
      if (age >= 35 || age < 18) {
        if (riskLevel !== riskLevels.CRITICAL && riskLevel !== riskLevels.HIGH) riskLevel = riskLevels.MEDIUM;
        reasons.push(`Age risk factor (Age: ${Math.round(age)})`);
      }

      let confidenceScore = 0.95;
      if (riskLevel === riskLevels.CRITICAL) confidenceScore = 0.94;
      else if (riskLevel === riskLevels.HIGH) confidenceScore = 0.89;
      else if (riskLevel === riskLevels.MEDIUM) confidenceScore = 0.84;

      const recommendations = [];
      const reasonsStr = reasons.length > 0 ? ` Factors: ${reasons.join(', ')}.` : '';
      if (riskLevel === riskLevels.CRITICAL) {
        recommendations.push(`URGENT ASSISTANCE REQUIRED!${reasonsStr}`);
        recommendations.push("Please go to the nearest emergency ward or call emergency services immediately.");
        recommendations.push("Inform your gynaecologist of these vital levels right away.");
      } else if (riskLevel === riskLevels.HIGH) {
        recommendations.push(`High Pregnancy Risk detected.${reasonsStr}`);
        recommendations.push("Schedule an urgent consultation with your obstetrician / primary physician.");
        recommendations.push("Rest completely, monitor blood pressure, and keep logs of these vitals.");
      } else if (riskLevel === riskLevels.MEDIUM) {
        recommendations.push(`Moderate Risk level.${reasonsStr}`);
        recommendations.push("Notify your healthcare provider of these readings at your next check-up.");
        recommendations.push("Maintain balanced meals, limit sodium intake, and stay hydrated.");
      } else {
        recommendations.push("Low risk level. Your pregnancy health metrics look stable.");
        recommendations.push("Continue regular checkups, light exercises, and tracking your vitals daily.");
      }

      return {
        success: true,
        riskLevel,
        confidenceScore,
        isRealModel: false,
        recommendations
      };
    }

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
      isRealModel: false,
      recommendations
    };
  }
}

module.exports = AiClient;
