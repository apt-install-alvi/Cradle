const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const apiLimiter = require('./common/middlewares/rateLimiter');
const errorHandler = require('./common/middlewares/errorHandler');
const httpStatusCodes = require('./common/constants/httpStatusCodes');
const ApiResponse = require('./common/utils/apiResponse');

// Routes imports
const authRoutes = require('./modules/auth/auth.routes');
const profileRoutes = require('./modules/motherProfile/motherProfile.routes');
const symptomsRoutes = require('./modules/symptoms/symptoms.routes');
const aiPredictionRoutes = require('./modules/aiPrediction/aiPrediction.routes');
const appointmentsRoutes = require('./modules/appointments/appointments.routes');
const healthHistoryRoutes = require('./modules/healthHistory/healthHistory.routes');
const emergencyRoutes = require('./modules/emergency/emergency.routes');
const educationRoutes = require('./modules/education/education.routes');
const notificationsRoutes = require('./modules/notifications/notifications.routes');

const app = express();

// Middlewares
app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use('/api/', apiLimiter);

// Health Check
app.get('/health', (req, res) => {
  return ApiResponse.success(res, 'Cradle API Gateway is healthy.', {
    env: process.env.NODE_ENV,
    uptime: process.uptime()
  });
});

// Bind API Modules
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/symptoms', symptomsRoutes);
app.use('/api/predictions', aiPredictionRoutes);
app.use('/api/appointments', appointmentsRoutes);
app.use('/api/history', healthHistoryRoutes);
app.use('/api/emergency', emergencyRoutes);
app.use('/api/education', educationRoutes);
app.use('/api/notifications', notificationsRoutes);

// Catch 404
app.use((req, res, next) => {
  res.status(httpStatusCodes.NOT_FOUND).json({
    success: false,
    message: `Resource not found: Cannot ${req.method} ${req.originalUrl}`
  });
});

// Global Error Middleware
app.use(errorHandler);

module.exports = app;
