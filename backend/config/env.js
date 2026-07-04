const dotenv = require('dotenv');
dotenv.config();

const requiredEnv = ['JWT_SECRET'];

for (const env of requiredEnv) {
  if (!process.env[env]) {
    console.error(`Error: Critical environment variable ${env} is missing.`);
    process.exit(1);
  }
}

module.exports = {
  PORT: process.env.PORT || 5000,
  MONGO_URI: process.env.MONGO_URI || 'mongodb://localhost:27017/cradle',
  JWT_SECRET: process.env.JWT_SECRET,
  JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
  OTP_EXPIRES_IN_MINUTES: parseInt(process.env.OTP_EXPIRES_IN_MINUTES || '5', 10),
  ML_SERVICE_URL: process.env.ML_SERVICE_URL || 'http://localhost:5001',
  NODE_ENV: process.env.NODE_ENV || 'development'
};
