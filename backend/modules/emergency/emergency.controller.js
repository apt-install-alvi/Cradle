const EmergencyService = require('./emergency.service');
const ApiResponse = require('../../common/utils/apiResponse');
const httpStatusCodes = require('../../common/constants/httpStatusCodes');

class EmergencyController {
  static async triggerSOS(req, res, next) {
    try {
      const { location } = req.body;
      const result = await EmergencyService.triggerSOS(req.user.id || req.user._id, location);
      return ApiResponse.success(
        res, 
        'SOS Alert triggered successfully. Family and doctors have been notified.', 
        result, 
        httpStatusCodes.CREATED
      );
    } catch (error) {
      next(error);
    }
  }

  static async getAlerts(req, res, next) {
    try {
      const alerts = await EmergencyService.getAlerts(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Emergency alerts history retrieved successfully.', alerts);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = EmergencyController;
