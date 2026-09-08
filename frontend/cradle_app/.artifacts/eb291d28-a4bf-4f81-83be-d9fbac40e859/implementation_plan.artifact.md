# Implementation Plan - Connected Diagnosis History UI

This plan implements a fully backend-connected Diagnosis History UI in `HealthHistoryPage`, displaying check-in date/timestamp, symptoms, required health vitals, and risk outputs with colored tags (Green for Low, Yellow for Medium, Red for High).

## User Review Required

> [!IMPORTANT]
> - **Backend API**: We will connect `HealthHistoryPage` to the existing backend predictions & symptoms endpoints (fetching from Supabase `ai_predictions`, `symptom_sessions`, `symptoms`, and `diagnosis_vitals`).
> - **UI & Tags**: Each history card will feature clean maternal-theme cards with color-coded risk tags (Low = Green, Medium = Yellow/Orange, High = Red), timestamps, reported symptoms, and required health vitals.

## Proposed Changes

### Backend Updates

#### [MODIFY] [AiPrediction Controller & Service](file:///D:/code/Cradle/backend/modules/aiPrediction/aiPrediction.service.js)
- Ensure `/api/predictions/history` (or similar history route) returns session details, symptoms, diagnosis vitals, and AI prediction results.

### Frontend Updates

#### [NEW / MODIFY] [Health History Service / Provider](file:///D:/code/Cradle/frontend/cradle_app/lib/providers/)
- Add methods to fetch diagnosis history from the backend API.

#### [MODIFY] [Health History Page & Cards](file:///D:/code/Cradle/frontend/cradle_app/lib/pages/health_history/)
- Replace hardcoded mock entries with real backend data.
- Design clean history cards displaying:
    - Date & Timestamp
    - Color-coded risk level tag (Green, Yellow, Red)
    - Reported symptoms list
    - Required health vitals logged during diagnosis

## Verification Plan

### Manual Verification
- Log a new symptom check-in with required vitals and get an AI risk prediction.
- Navigate to the Health History page and verify that the check-in appears with the correct timestamp, symptoms, required vitals, and colored risk tag.
