const addMinutes = (date, minutes) => {
  return new Date(date.getTime() + minutes * 60000);
};

const isExpired = (expiryDate) => {
  return new Date() > expiryDate;
};

module.exports = {
  addMinutes,
  isExpired
};
