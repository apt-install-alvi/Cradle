const validateCreateProfile = (body) => {
  // We make most fields optional to allow partial updates,
  // but validate types where possible.

  if (body.age !== undefined && (typeof body.age !== 'number' || body.age < 0)) {
    return { error: new Error('Invalid age') };
  }

  if (body.weight !== undefined && typeof body.weight !== 'number') {
    return { error: new Error('Invalid weight') };
  }

  if (body.height !== undefined && typeof body.height !== 'number') {
    return { error: new Error('Invalid height') };
  }

  return { value: body };
};

module.exports = {
  validateCreateProfile
};
