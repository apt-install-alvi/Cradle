const AppointmentsService = require('./appointments.service');
const ApiResponse = require('../../common/utils/apiResponse');
const httpStatusCodes = require('../../common/constants/httpStatusCodes');

class AppointmentsController {
  static async createAppointment(req, res, next) {
    try {
      const appt = await AppointmentsService.createAppointment(req.user.id || req.user._id, req.body);
      return ApiResponse.success(res, 'Appointment created successfully.', appt, httpStatusCodes.CREATED);
    } catch (error) {
      next(error);
    }
  }

  static async getAppointments(req, res, next) {
    try {
      const appts = await AppointmentsService.getAppointments(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Appointments retrieved successfully.', appts);
    } catch (error) {
      next(error);
    }
  }

  static async createReminder(req, res, next) {
    try {
      const reminder = await AppointmentsService.createMedicationReminder(req.user.id || req.user._id, req.body);
      return ApiResponse.success(res, 'Medication reminder created successfully.', reminder, httpStatusCodes.CREATED);
    } catch (error) {
      next(error);
    }
  }

  static async getReminders(req, res, next) {
    try {
      const reminders = await AppointmentsService.getMedicationReminders(req.user.id || req.user._id);
      return ApiResponse.success(res, 'Medication reminders retrieved successfully.', reminders);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AppointmentsController;
