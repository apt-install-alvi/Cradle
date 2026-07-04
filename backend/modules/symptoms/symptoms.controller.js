const SymptomsService = require('./symptoms.service');
const ApiResponse = require('../../common/utils/apiResponse');
const httpStatusCodes = require('../../common/constants/httpStatusCodes');

class SymptomsController {
  static async logSymptom(req, res, next) {
    try {
      const log = await SymptomsService.logSymptom(req.user.id || req.user._id, req.body);
      return ApiResponse.success(res, 'Symptoms logged successfully.', log, httpStatusCodes.CREATED);
    } catch (error) {
      next(error);
    }
  }

  static async getHistory(req, res, next) {
    try {
      const history = await SymptomsService.getSymptomsHistory(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Symptoms history retrieved successfully.', history);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = SymptomsController;
