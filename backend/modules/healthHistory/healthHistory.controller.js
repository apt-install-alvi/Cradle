const HealthHistoryService = require('./healthHistory.service');
const ApiResponse = require('../../common/utils/apiResponse');

class HealthHistoryController {
  static async getHistory(req, res, next) {
    try {
      const history = await HealthHistoryService.getIntegratedHistory(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Integrated health history retrieved successfully.', history);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = HealthHistoryController;
