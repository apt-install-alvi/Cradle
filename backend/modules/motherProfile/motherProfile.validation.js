const validateCreateProfile = (body) => {
  const { fullName, age, dueDate } = body;
  if (!fullName || typeof fullName !== 'string' || fullName.trim().length === 0) {
    return { error: new Error('Full name is required') };
  }
  if (age === undefined || typeof age !== 'number' || age <= 0) {
    return { error: new Error('Valid age is required') };
  }
  if (!dueDate || isNaN(Date.parse(dueDate))) {
    return { error: new Error('Valid due date is required') };
  }
  return { value: body };
};

module.exports = {
  validateCreateProfile
};
