const express = require('express');
const router = express.Router();
const AppointmentsController = require('./appointments.controller');
const { protect } = require('../../common/middlewares/authMiddleware');
const validateRequest = require('../../common/middlewares/validateRequest');
const { validateCreateAppointment, validateCreateReminder } = require('./appointments.validation');

router.post('/', protect, validateRequest(validateCreateAppointment), AppointmentsController.createAppointment);
router.get('/', protect, AppointmentsController.getAppointments);

router.post('/reminders', protect, validateRequest(validateCreateReminder), AppointmentsController.createReminder);
router.get('/reminders', protect, AppointmentsController.getReminders);
router.patch('/reminders/:id', protect, AppointmentsController.updateReminder);
router.delete('/reminders/:id', protect, AppointmentsController.deleteReminder);

router.post('/log-dose', protect, AppointmentsController.logDose);
router.post('/unlog-dose', protect, AppointmentsController.unlogDose);
router.get('/adherence', protect, AppointmentsController.getAdherence);

module.exports = router;
