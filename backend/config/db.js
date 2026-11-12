const mongoose = require('mongoose');
const env = require('./env');

const connectDB = async () => {
  try {
    // Simplified connection for better stability on Windows/Atlas
    const conn = await mongoose.connect(env.MONGO_URI);

    console.log(`MongoDB Connected: ${conn.connection.host}`);

    // Verify connection with a ping
    await mongoose.connection.db.admin().command({ ping: 1 });
    console.log("Ping successful. Database is ready for operations.");

    return true;
  } catch (error) {
    console.error(`MongoDB Connection Error: ${error.message}`);
    throw error;
  }
};

module.exports = connectDB;
