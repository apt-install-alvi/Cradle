const VitalsService = require('./vitals.service');
const ApiResponse = require('../../common/utils/apiResponse');

class VitalsController {
  static async getVitals(req, res, next) {
    try {
      const { type } = req.query;
      const list = await VitalsService.getVitals(req.user.id || req.user._id, type);
      return ApiResponse.success(res, 'Vitals retrieved successfully.', list);
    } catch (error) {
      next(error);
    }
  }

  static async logVital(req, res, next) {
    try {
      const vital = await VitalsService.logVital(req.user.id || req.user._id, req.body);
      return ApiResponse.success(res, 'Vital logged successfully.', vital);
    } catch (error) {
      next(error);
    }
  }

  static async updateVital(req, res, next) {
    try {
      const vital = await VitalsService.updateVital(req.user.id || req.user._id, req.params.id, req.body);
      if (!vital) return ApiResponse.error(res, 'Vital log not found.', 404);
      return ApiResponse.success(res, 'Vital updated successfully.', vital);
    } catch (error) {
      next(error);
    }
  }

  static async deleteVital(req, res, next) {
    try {
      await VitalsService.deleteVital(req.user.id || req.user._id, req.params.id);
      return ApiResponse.success(res, 'Vital deleted successfully.');
    } catch (error) {
      next(error);
    }
  }

  static async getSettings(req, res, next) {
    try {
      const settings = await VitalsService.getSettings(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Vital settings retrieved successfully.', settings);
    } catch (error) {
      next(error);
    }
  }

  static async updateSettings(req, res, next) {
    try {
      console.log('[VitalsController] Incoming updateSettings body:', JSON.stringify(req.body));
      const { vitalKey, settings } = req.body;
      const data = await VitalsService.updateSettings(req.user.id || req.user._id, vitalKey, settings);
      return ApiResponse.success(res, 'Vital settings updated successfully.', data);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = VitalsController;
