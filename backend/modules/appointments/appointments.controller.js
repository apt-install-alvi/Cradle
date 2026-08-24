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
      const { localDate } = req.query;
      const reminders = await AppointmentsService.getMedicationReminders(req.user.id || req.user._id);
      const logs = await AppointmentsService.getTodayLogs(req.user.id || req.user._id, localDate);
      return ApiResponse.success(res, 'Medication reminders retrieved successfully.', { reminders, logs });
    } catch (error) {
      next(error);
    }
  }

  static async updateReminder(req, res, next) {
    try {
      const reminder = await AppointmentsService.updateMedicationReminder(req.user.id || req.user._id, req.params.id, req.body);
      return ApiResponse.success(res, 'Medication reminder updated successfully.', reminder);
    } catch (error) {
      next(error);
    }
  }

  static async deleteReminder(req, res, next) {
    try {
      await AppointmentsService.deleteMedicationReminder(req.user.id || req.user._id, req.params.id);
      return ApiResponse.success(res, 'Medication reminder deleted successfully.');
    } catch (error) {
      next(error);
    }
  }

  static async logDose(req, res, next) {
    try {
      const { reminderId, scheduledTime, localDate } = req.body;
      const log = await AppointmentsService.logMedicationDose(req.user.id || req.user._id, reminderId, scheduledTime, localDate);
      return ApiResponse.success(res, 'Medication dose logged successfully.', log, httpStatusCodes.CREATED);
    } catch (error) {
      next(error);
    }
  }

  static async unlogDose(req, res, next) {
    try {
      const { reminderId, scheduledTime, localDate } = req.body;
      await AppointmentsService.unlogMedicationDose(req.user.id || req.user._id, reminderId, scheduledTime, localDate);
      return ApiResponse.success(res, 'Medication dose unlogged successfully.');
    } catch (error) {
      next(error);
    }
  }

  static async getAdherence(req, res, next) {
    try {
      const { localDate } = req.query;
      const data = await AppointmentsService.getAdherence(req.user.id || req.user._id, localDate);
      return ApiResponse.success(res, 'Medication adherence retrieved successfully.', data);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = AppointmentsController;
