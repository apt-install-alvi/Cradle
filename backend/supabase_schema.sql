-- Supabase Schema for Cradle Project

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone TEXT UNIQUE NOT NULL,
  full_name TEXT,
  preferred_language TEXT DEFAULT 'en',
  is_profile_completed BOOLEAN DEFAULT false,
  otp_code TEXT,
  otp_expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Mother Profiles Table
CREATE TABLE IF NOT EXISTS mother_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  blood_group TEXT,
  age INTEGER,
  weight DOUBLE PRECISION,
  height DOUBLE PRECISION,
  conception_date DATE,
  expected_due_date DATE,
  pregnancy_week INTEGER,
  allergies TEXT,
  long_term_diseases TEXT,
  emergency_contact TEXT,
  profile_image TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Education Articles Table
CREATE TABLE IF NOT EXISTS education_articles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  category TEXT DEFAULT 'GENERAL',
  trimester INTEGER DEFAULT 0,
  image_url TEXT,
  reading_time_minutes INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Symptom Sessions Table
CREATE TABLE IF NOT EXISTS symptom_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'IN_PROGRESS',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Symptoms Table
CREATE TABLE IF NOT EXISTS symptoms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES symptom_sessions(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  value TEXT,
  unit TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 6. Appointments Table
CREATE TABLE IF NOT EXISTS appointments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  doctor_name TEXT NOT NULL,
  clinic_name TEXT,
  date_time TIMESTAMPTZ NOT NULL,
  purpose TEXT,
  notes TEXT,
  status TEXT DEFAULT 'SCHEDULED',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Medication Reminders Table
CREATE TABLE IF NOT EXISTS medication_reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  medication_name TEXT NOT NULL,
  dosage TEXT,
  time_of_day TEXT[], -- Array of strings for times
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 8. Emergency Alerts Table
CREATE TABLE IF NOT EXISTS emergency_alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  alert_type TEXT NOT NULL,
  location_lat DOUBLE PRECISION,
  location_lng DOUBLE PRECISION,
  status TEXT DEFAULT 'PENDING',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 9. Daily Health Status Table
CREATE TABLE IF NOT EXISTS daily_health_status (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  mood TEXT,
  energy_level INTEGER,
  sleep_hours DOUBLE PRECISION,
  weight DOUBLE PRECISION,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 10. Notifications Table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 11. AI Predictions Table
CREATE TABLE IF NOT EXISTS ai_predictions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  session_id UUID NOT NULL REFERENCES symptom_sessions(id) ON DELETE CASCADE,
  prediction_data JSONB,
  risk_level TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 12. Medication Logs Table
CREATE TABLE IF NOT EXISTS medication_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  reminder_id UUID NOT NULL REFERENCES medication_reminders(id) ON DELETE CASCADE,
  scheduled_time TEXT, -- e.g., "08:00"
  log_date DATE DEFAULT CURRENT_DATE,
  taken_at TIMESTAMPTZ DEFAULT NOW(),
  status TEXT DEFAULT 'TAKEN',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(reminder_id, scheduled_time, log_date)
);

-- Disable RLS (Row Level Security) for all tables
-- This allows the backend to perform operations without specific policies


-- Function to handle updated_at
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at triggers to all tables that have it
CREATE TRIGGER update_users_modtime BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_mother_profiles_modtime BEFORE UPDATE ON mother_profiles FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_education_articles_modtime BEFORE UPDATE ON education_articles FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_symptom_sessions_modtime BEFORE UPDATE ON symptom_sessions FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_symptoms_modtime BEFORE UPDATE ON symptoms FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_appointments_modtime BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_medication_reminders_modtime BEFORE UPDATE ON medication_reminders FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_emergency_alerts_modtime BEFORE UPDATE ON emergency_alerts FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
CREATE TRIGGER update_daily_health_status_modtime BEFORE UPDATE ON daily_health_status FOR EACH ROW EXECUTE PROCEDURE update_modified_column();
