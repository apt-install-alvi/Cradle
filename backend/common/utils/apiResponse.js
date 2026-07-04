const httpStatusCodes = require('../constants/httpStatusCodes');

class ApiResponse {
  static success(res, message, data = {}, statusCode = httpStatusCodes.OK) {
    return res.status(statusCode).json({
      success: true,
      message,
      data
    });
  }

  static error(res, message, statusCode = httpStatusCodes.INTERNAL_SERVER_ERROR, errors = null) {
    return res.status(statusCode).json({
      success: false,
      message,
      errors
    });
  }
}

module.exports = ApiResponse;
