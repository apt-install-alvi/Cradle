const MotherProfileService = require('./motherProfile.service');
const ApiResponse = require('../../common/utils/apiResponse');

class MotherProfileController {
  static async getProfile(req, res, next) {
    try {
      const profile = await MotherProfileService.getProfileByUserId(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Profile retrieved successfully.', profile);
    } catch (error) {
      next(error);
    }
  }

  static async updateProfile(req, res, next) {
    try {
      const profile = await MotherProfileService.createOrUpdateProfile(req.user.id || req.user._id, req.body);
      return ApiResponse.success(res, 'Profile updated successfully.', profile);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = MotherProfileController;
