const WaterService = require('./water.service');
const ApiResponse = require('../../common/utils/apiResponse');

class WaterController {
  static async logWater(req, res, next) {
    try {
      const { amountMl } = req.body;
      const log = await WaterService.logWater(req.user.id || req.user._id, amountMl);
      return ApiResponse.success(res, 'Water logged successfully.', log);
    } catch (error) {
      next(error);
    }
  }

  static async getStats(req, res, next) {
    try {
      const userId = req.user.id || req.user._id;
      const { localDate } = req.query;
      const [latest, dailyTotal] = await Promise.all([
        WaterService.getLatestLog(userId),
        WaterService.getDailyTotal(userId, localDate)
      ]);
      return ApiResponse.success(res, 'Water stats retrieved successfully.', { latest, dailyTotal });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = WaterController;
