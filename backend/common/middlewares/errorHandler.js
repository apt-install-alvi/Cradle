const ApiResponse = require('../utils/apiResponse');
const httpStatusCodes = require('../constants/httpStatusCodes');

const errorHandler = (err, req, res, next) => {
  console.error(`[Error Handler] ${err.stack || err.message}`);
  
  const statusCode = err.statusCode || httpStatusCodes.INTERNAL_SERVER_ERROR;
  const message = err.message || 'An unexpected error occurred';
  
  return ApiResponse.error(
    res, 
    message, 
    statusCode, 
    process.env.NODE_ENV === 'development' ? err.stack : null
  );
};

module.exports = errorHandler;
