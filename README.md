# Cradle - Maternal Health Companion

Cradle is an AI-powered mobile application designed to support pregnant mothers by offering suggested diagnoses of pregnancy-related symptoms through Machine Learning and providing comprehensive health tracking.

## 🚀 System Architecture
- **[frontend/cradle_app](./frontend/cradle_app)**: Mobile Client application built with **Flutter**.
- **[backend](./backend)**: REST API gateway built with **Node.js & Express**, connected to **MongoDB Atlas**.
- **[ml-service](./ml-service)**: AI prediction microservice built with **Python & Flask**.

---

## 🛠️ Getting Started

### 1. Backend Gateway (Node.js)
The backend manages authentication, data persistence, and coordinates with the ML service.

1. Navigate to the `backend/` directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. **Configure Environment**: Create a `.env` file in the `backend/` root (refer to `.env.example`):
   ```env
   PORT=5000
   MONGO_URI=your_mongodb_atlas_uri
   JWT_SECRET=your_jwt_secret
   ```
4. **Database Access**: Ensure your Public IP is whitelisted in your **MongoDB Atlas > Network Access** dashboard.
5. Run the development server:
   ```bash
   npm run dev
   ```

### 2. ML Microservice (Python)
The ML service provides risk assessments based on maternal health parameters.

1. Navigate to the `ml-service/` directory:
   ```bash
   cd ml-service
   ```
2. Install Python packages:
   ```bash
   pip install -r requirements.txt
   ```
3. Start the Flask service:
   ```bash
   python app.py
   ```

### 3. Mobile Client (Flutter)
1. Navigate to `frontend/cradle_app/`:
   ```bash
   cd frontend/cradle_app
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

---

## 🔑 Authentication (Dev Mode)
- **Registration/Login**: Use your phone number and any password.
- **OTP Verification**: For development, use the hardcoded OTP: **`123456`**.
- **Persistence**: Sessions are stored locally using `shared_preferences`.

## 📊 Database Schema
The project uses a structured MongoDB schema based on a comprehensive ER diagram covering:
- User Profiles & Settings
- Mother Health Records
- Symptom Logging Sessions
- AI Risk Predictions
- System Notifications

---
© 2026 Cradle Team
