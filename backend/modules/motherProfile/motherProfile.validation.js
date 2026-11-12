const validateCreateProfile = (body) => {
  // Most fields are optional to allow partial updates.

  if (
    body.age !== undefined &&
    (typeof body.age !== 'number' || body.age < 0)
  ) {
    return { error: new Error('Invalid age') };
  }

  if (
    body.weight !== undefined &&
    typeof body.weight !== 'number'
  ) {
    return { error: new Error('Invalid weight') };
  }

  if (
    body.height !== undefined &&
    typeof body.height !== 'number'
  ) {
    return { error: new Error('Invalid height') };
  }

  if (body.emergency_contact !== undefined) {
    if (!Array.isArray(body.emergency_contact)) {
      return {
        error: new Error('Emergency contacts must be an array'),
      };
    }

    if (
      !body.emergency_contact.every(
        (contact) =>
          typeof contact === 'string' &&
          contact.trim().length > 0
      )
    ) {
      return {
        error: new Error(
          'Each emergency contact must be a non-empty string'
        ),
      };
    }
  }

  return { value: body };
};

module.exports = {
  validateCreateProfile,
};