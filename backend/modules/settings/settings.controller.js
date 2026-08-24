const SettingsService = require('./settings.service');
const ApiResponse = require('../../common/utils/apiResponse');

class SettingsController {
  static async getSettings(req, res, next) {
    try {
      const settings = await SettingsService.getSettings(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Settings retrieved successfully.', settings);
    } catch (error) {
      next(error);
    }
  }

  static async updateSettings(req, res, next) {
    try {
      const settings = await SettingsService.updateSettings(req.user.id || req.user._id, req.body);
      return ApiResponse.success(res, 'Settings updated successfully.', settings);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = SettingsController;
