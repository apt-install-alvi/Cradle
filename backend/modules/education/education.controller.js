const EducationService = require('./education.service');
const ApiResponse = require('../../common/utils/apiResponse');

class EducationController {
  static async getArticles(req, res, next) {
    try {
      const { trimester } = req.query;
      const articles = await EducationService.getArticles(trimester);
      return ApiResponse.success(res, 'Articles retrieved successfully.', articles);
    } catch (error) {
      next(error);
    }
  }

  static async getArticleById(req, res, next) {
    try {
      const article = await EducationService.getArticleById(req.params.id);
      return ApiResponse.success(res, 'Article details retrieved successfully.', article);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = EducationController;
