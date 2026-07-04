const rateLimit = require('express-rate-limit');
const ApiResponse = require('../utils/apiResponse');
const httpStatusCodes = require('../constants/httpStatusCodes');

const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req, res) => {
    return ApiResponse.error(
      res,
      'Too many requests from this IP, please try again after 15 minutes',
      httpStatusCodes.TOO_MANY_REQUESTS
    );
  }
});

module.exports = apiLimiter;
