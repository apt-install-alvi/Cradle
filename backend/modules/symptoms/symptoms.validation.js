const validateSymptomLog = (body) => {
  const { symptomsList } = body;
  if (!symptomsList || !Array.isArray(symptomsList) || symptomsList.length === 0) {
    return { error: new Error('symptomsList must be a non-empty array') };
  }
  for (const s of symptomsList) {
    if (!s.name || typeof s.name !== 'string') {
      return { error: new Error('Symptom name is required') };
    }
    if (s.severity === undefined || typeof s.severity !== 'number' || s.severity < 1 || s.severity > 10) {
      return { error: new Error('Symptom severity must be a number between 1 and 10') };
    }
  }
  return { value: body };
};

module.exports = {
  validateSymptomLog
};
