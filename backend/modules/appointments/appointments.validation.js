const validateCreateAppointment = (body) => {
  const { doctorName, dateTime } = body;
  if (!doctorName || typeof doctorName !== 'string' || doctorName.trim().length === 0) {
    return { error: new Error('Doctor name is required') };
  }
  if (!dateTime || isNaN(Date.parse(dateTime))) {
    return { error: new Error('Valid date and time are required') };
  }
  return { value: body };
};

const validateCreateReminder = (body) => {
  const { medicationName, timeOfDay } = body;
  if (!medicationName || typeof medicationName !== 'string' || medicationName.trim().length === 0) {
    return { error: new Error('Medication name is required') };
  }
  if (!timeOfDay || !Array.isArray(timeOfDay) || timeOfDay.length === 0) {
    return { error: new Error('timeOfDay must be a non-empty array of time strings') };
  }
  return { value: body };
};

module.exports = {
  validateCreateAppointment,
  validateCreateReminder
};
