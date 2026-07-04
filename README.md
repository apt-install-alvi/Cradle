# Cradle
A mobile app which offers suggested diagnosis of pregnancy-related symptoms to pregnant mothers through Artificial Intelligence and Machine Learning.

## System Architecture Layout
- **[frontend/cradle_app](file:///c:/Users/User/Desktop/Cradle/frontend/cradle_app)**: Mobile Client application (Flutter)
- **[backend](file:///c:/Users/User/Desktop/Cradle/backend)**: REST API backend gateway (Express.js)
- **[ml-service](file:///c:/Users/User/Desktop/Cradle/ml-service)**: AI prediction microservice (Python / Flask)
- **[docs](file:///c:/Users/User/Desktop/Cradle/docs)**: SDP2 System Design project report

---

## Getting Started & Execution

### 1. Launching the Backend Gateway
1. Navigate to the `backend/` directory.
2. Verify dependencies are installed:
   ```bash
   npm install
   ```
3. Run the development server:
   ```bash
   npm run dev
   ```
   *Note: If MongoDB is offline, the backend dynamically initializes fallback mocks for all controllers so you can debug the client without database hassles.*

### 2. Launching the ML Microservice
1. Navigate to the `ml-service/` directory.
2. Install Python packages:
   ```bash
   pip install -r requirements.txt
   ```
3. Generate the Random Forest classifier pickle model file:
   ```bash
   python generate_dummy_model.py
   ```
4. Start the Flask service:
   ```bash
   python app.py
   ```
   *Note: If Flask or the PKL model file is not present, the Node.js backend operates a rule-based heuristics fallback to evaluate logged symptoms.*

### 3. Launching the Mobile Client
1. Navigate to `frontend/cradle_app/`.
2. Fetch package dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```
