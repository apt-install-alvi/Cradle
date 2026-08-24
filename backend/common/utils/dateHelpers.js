const addMinutes = (date, minutes) => {
  return new Date(date.getTime() + minutes * 60000);
};

const isExpired = (expiryDate) => {
  return new Date() > expiryDate;
};

const getLocalDateString = (date = new Date()) => {
  const offset = date.getTimezoneOffset();
  const localDate = new Date(date.getTime() - (offset * 60 * 1000));
  return localDate.toISOString().split('T')[0];
};

module.exports = {
  addMinutes,
  isExpired,
  getLocalDateString
};
