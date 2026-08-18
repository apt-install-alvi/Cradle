const jwt = require('jsonwebtoken');
const env = require('../../config/env');
const ApiResponse = require('../utils/apiResponse');
const httpStatusCodes = require('../constants/httpStatusCodes');
const User = require('../../modules/auth/user.model');

const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, env.JWT_SECRET);

      const user = await User.findById(decoded.id).select('-otp');
      if (!user) {
        return ApiResponse.error(res, 'User not found', httpStatusCodes.UNAUTHORIZED);
      }
      
      req.user = user;
      next();
    } catch (error) {
      console.error('[Auth Middleware] Error:', error.message);
      return ApiResponse.error(res, 'Not authorized, token validation failed', httpStatusCodes.UNAUTHORIZED);
    }
  }

  if (!token) {
    return ApiResponse.error(res, 'Not authorized, no token header provided', httpStatusCodes.UNAUTHORIZED);
  }
};

module.exports = { protect };
