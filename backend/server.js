const app = require('./app');
const env = require('./config/env');
const logger = require('./common/utils/logger');

const startServer = async () => {
  // Start Listening
  const server = app.listen(env.PORT, () => {
    logger.info(`Cradle API Server running in ${env.NODE_ENV} mode on http://localhost:${env.PORT}`);
  });

  // Handle unhandled promise rejections
  process.on('unhandledRejection', (err) => {
    logger.error(`Unhandled Promise Rejection: ${err.message}`);
    server.close(() => process.exit(1));
  });
};

startServer();
