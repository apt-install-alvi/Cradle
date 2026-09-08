const validateSymptomLog = (body) => {
  const { symptomsList, diagnosisVitals } = body;
  if ((!symptomsList || !Array.isArray(symptomsList) || symptomsList.length === 0) &&
      (!diagnosisVitals || !Array.isArray(diagnosisVitals))) {
    return { error: new Error('symptomsList or diagnosisVitals is required') };
  }

  if (symptomsList && Array.isArray(symptomsList)) {
    for (const s of symptomsList) {
      if (!s.name || typeof s.name !== 'string') {
        return { error: new Error('Symptom name is required') };
      }
    }
  }

  if (diagnosisVitals && Array.isArray(diagnosisVitals)) {
    for (const v of diagnosisVitals) {
      if (!v.symptom_type || !v.vital_name || v.value === undefined) {
        return { error: new Error('Each diagnosis vital must have symptom_type, vital_name, and value') };
      }
    }
  }

  return { value: body };
};

module.exports = {
  validateSymptomLog
};
