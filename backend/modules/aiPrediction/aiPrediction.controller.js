const AiPredictionService = require('./aiPrediction.service');
const ApiResponse = require('../../common/utils/apiResponse');
const httpStatusCodes = require('../../common/constants/httpStatusCodes');

class AiPredictionController {
  static async assess(req, res, next) {
    try {
      const { symptomLogId, symptoms } = req.body;
      if (!symptoms || !Array.isArray(symptoms)) {
        return ApiResponse.error(res, 'Symptoms list is required.', httpStatusCodes.BAD_REQUEST);
      }
      const assessment = await AiPredictionService.assessRisk(
        req.user.id || req.user._id, 
        symptomLogId, 
        symptoms
      );
      return ApiResponse.success(res, 'AI assessment calculated successfully.', assessment);
    } catch (error) {
      next(error);
    }
  }

  static async getHistory(req, res, next) {
    try {
      const history = await AiPredictionService.getHistory(req.user.id || req.user._id);
      return ApiResponse.success(res, 'AI assessment history retrieved successfully.', history);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AiPredictionController;
