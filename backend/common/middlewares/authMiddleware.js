const jwt = require('jsonwebtoken');
const env = require('../../config/env');
const supabase = require('../../config/supabase');
const ApiResponse = require('../utils/apiResponse');
const httpStatusCodes = require('../constants/httpStatusCodes');

const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];

      // Verify our custom JWT
      const decoded = jwt.verify(token, env.JWT_SECRET);

      // Fetch the user from public.users
      const { data: user, error } = await supabase
        .from('users')
        .select('*')
        .eq('id', decoded.id)
        .single();

      if (error || !user) {
        return ApiResponse.error(res, 'User not found or token invalid', httpStatusCodes.UNAUTHORIZED);
      }
      
      req.user = user;
      next();
    } catch (error) {
      console.error('[Auth Middleware] JWT Error:', error.message);
      return ApiResponse.error(res, 'Not authorized, token validation failed', httpStatusCodes.UNAUTHORIZED);
    }
  }

  if (!token) {
    return ApiResponse.error(res, 'Not authorized, no token header provided', httpStatusCodes.UNAUTHORIZED);
  }
};

module.exports = { protect };
