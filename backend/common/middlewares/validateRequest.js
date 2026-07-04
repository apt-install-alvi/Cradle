const ApiResponse = require('../utils/apiResponse');
const httpStatusCodes = require('../constants/httpStatusCodes');

const validateRequest = (schemaCallback) => {
  return (req, res, next) => {
    const { error, value } = schemaCallback(req.body);
    if (error) {
      return ApiResponse.error(
        res, 
        error.message || 'Validation error', 
        httpStatusCodes.BAD_REQUEST, 
        error.details || error
      );
    }
    req.validatedBody = value;
    next();
  };
};

module.exports = validateRequest;
