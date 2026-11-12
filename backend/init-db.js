const mongoose = require('mongoose');
require('dotenv').config();

// Import all models
const User = require('./modules/auth/user.model');
const MotherProfile = require('./modules/motherProfile/motherProfile.model');
const DailyHealthStatus = require('./modules/healthHistory/dailyHealthStatus.model');
const SymptomSession = require('./modules/symptoms/session.model');
const Symptom = require('./modules/symptoms/symptom.model');
const SymptomFlowStep = require('./modules/symptoms/flowStep.model');
const RiskPrediction = require('./modules/aiPrediction/riskPrediction.model');
const Notification = require('./modules/notifications/notification.model');
const Settings = require('./modules/settings/settings.model');

async function initialize() {
  try {
    console.log('Connecting to MongoDB Atlas...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected!');

    console.log('Initializing collections with dummy data...');

    // 1. Create a dummy user
    const dummyUser = await User.findOneAndUpdate(
      { phone: '00000000000' },
      { password: 'init_password', full_name: 'System Init' },
      { upsert: true, new: true }
    );
    console.log('✔ Users collection created');

    // 2. Create other collections by inserting/updating dummy records
    await MotherProfile.findOneAndUpdate({ user_id: dummyUser._id }, { age: 0 }, { upsert: true });
    console.log('✔ MotherProfiles collection created');

    await DailyHealthStatus.findOneAndUpdate({ user_id: dummyUser._id }, { mood: 'init' }, { upsert: true });
    console.log('✔ DailyHealthStatus collection created');

    const session = await SymptomSession.findOneAndUpdate({ user_id: dummyUser._id }, { is_active: false }, { upsert: true, new: true });
    console.log('✔ SymptomSessions collection created');

    await Symptom.findOneAndUpdate({ user_id: dummyUser._id, session_id: session._id }, { type: 'init' }, { upsert: true });
    console.log('✔ Symptoms collection created');

    await SymptomFlowStep.findOneAndUpdate({ user_id: dummyUser._id, session_id: session._id }, { step_order: 0 }, { upsert: true });
    console.log('✔ SymptomFlowSteps collection created');

    await RiskPrediction.findOneAndUpdate({ user_id: dummyUser._id, session_id: session._id }, { risk_level: 'init' }, { upsert: true });
    console.log('✔ RiskPredictions collection created');

    await Notification.findOneAndUpdate({ user_id: dummyUser._id }, { type: 'init', title: 'init', message: 'init' }, { upsert: true });
    console.log('✔ Notifications collection created');

    await Settings.findOneAndUpdate({ user_id: dummyUser._id }, { language: 'en' }, { upsert: true });
    console.log('✔ Settings collection created');

    console.log('\nSUCCESS: All collections are now visible in MongoDB Atlas!');
    console.log('You can now delete the user with phone "00000000000" from the Atlas UI if you wish.');

  } catch (error) {
    console.error('Initialization failed:', error);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

initialize();
