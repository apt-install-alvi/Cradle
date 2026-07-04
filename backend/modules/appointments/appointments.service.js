const Appointment = require('./appointment.model');
const MedicationReminder = require('./medicationReminder.model');
const mongoose = require('mongoose');

// In-memory fallback
const mockAppointments = [];
const mockReminders = [];

class AppointmentsService {
  static async createAppointment(userId, data) {
    if (mongoose.connection.readyState !== 1) {
      const appt = {
        _id: 'mock-appt-' + Math.random().toString(36).substring(2, 11),
        userId: userId.toString(),
        doctorName: data.doctorName,
        clinicName: data.clinicName || '',
        dateTime: new Date(data.dateTime),
        purpose: data.purpose || '',
        notes: data.notes || '',
        status: 'SCHEDULED',
        createdAt: new Date()
      };
      mockAppointments.push(appt);
      return appt;
    }
    return await Appointment.create({ userId, ...data });
  }

  static async getAppointments(userId) {
    if (mongoose.connection.readyState !== 1) {
      const appts = mockAppointments.filter(a => a.userId === userId.toString());
      if (appts.length === 0) {
        return [
          {
            _id: 'mock-appt-seed-1',
            userId: userId.toString(),
            doctorName: 'Dr. Sarah Connor',
            clinicName: 'Grace Maternity Clinic',
            dateTime: new Date(Date.now() + 2 * 24 * 60 * 60 * 1000), 
            purpose: 'Routine Prenatal Anatomy Scan',
            notes: 'Remember to drink water before the scan.',
            status: 'SCHEDULED'
          }
        ];
      }
      return appts;
    }
    return await Appointment.find({ userId }).sort({ dateTime: 1 });
  }

  static async createMedicationReminder(userId, data) {
    if (mongoose.connection.readyState !== 1) {
      const reminder = {
        _id: 'mock-rem-' + Math.random().toString(36).substring(2, 11),
        userId: userId.toString(),
        medicationName: data.medicationName,
        dosage: data.dosage || '',
        timeOfDay: data.timeOfDay,
        startDate: data.startDate ? new Date(data.startDate) : new Date(),
        endDate: data.endDate ? new Date(data.endDate) : null,
        isActive: true,
        createdAt: new Date()
      };
      mockReminders.push(reminder);
      return reminder;
    }
    return await MedicationReminder.create({ userId, ...data });
  }

  static async getMedicationReminders(userId) {
    if (mongoose.connection.readyState !== 1) {
      const rems = mockReminders.filter(r => r.userId === userId.toString());
      if (rems.length === 0) {
        return [
          {
            _id: 'mock-rem-seed-1',
            userId: userId.toString(),
            medicationName: 'Prenatal Multivitamins',
            dosage: '1 Capsule',
            timeOfDay: ['08:00'],
            startDate: new Date(),
            isActive: true
          },
          {
            _id: 'mock-rem-seed-2',
            userId: userId.toString(),
            medicationName: 'Calcium Carbonate',
            dosage: '500mg',
            timeOfDay: ['12:00', '20:00'],
            startDate: new Date(),
            isActive: true
          }
        ];
      }
      return rems;
    }
    return await MedicationReminder.find({ userId, isActive: true });
  }
}

module.exports = AppointmentsService;
