# Implementation Plan - Fix Notifications and Connect Health Logs

This plan addresses two issues:
1. The user is not receiving any notifications.
2. The Health Monitor (health logs) is currently using mock data and needs to be connected to the backend.

## User Review Required

> [!IMPORTANT]
> The fix for notifications includes adding more robust error handling in the backend. If any database table (like `water_logs` or `medication_reminders`) is missing, the notification service will now skip those specific reminders instead of failing entirely.

> [!NOTE]
> The Health Monitor connection assumes a `vitals` table exists in Supabase with fields: `id`, `user_id`, `type` (bp, temp, etc.), `value`, `systolic`, `diastolic`, `context`, and `logged_at`.

## Proposed Changes

### Backend - Notifications

#### [MODIFY] [notifications.service.js](file:///C:/Users/HP/Cradle/backend/modules/notifications/notifications.service.js)
- Add safety checks for `time_of_day` iteration.
- Wrap `Promise.all` sub-calls in individual try-catch blocks to prevent total failure if one service fails.

---

### Backend - Vitals (Health Logs)

#### [NEW] [vitals.service.js](file:///C:/Users/HP/Cradle/backend/modules/vitals/vitals.service.js)
- Implement `getVitals(userId, type)` to fetch logs from Supabase.
- Implement `logVital(userId, data)` to insert new logs.
- Implement `deleteVital(userId, logId)` to remove logs.

#### [NEW] [vitals.controller.js](file:///C:/Users/HP/Cradle/backend/modules/vitals/vitals.controller.js)
- Handle API requests for vitals and map to `VitalsService`.

#### [NEW] [vitals.routes.js](file:///C:/Users/HP/Cradle/backend/modules/vitals/vitals.routes.js)
- Define endpoints: `GET /vitals/:type`, `POST /vitals`, `DELETE /vitals/:id`.

#### [MODIFY] [app.js](file:///C:/Users/HP/Cradle/backend/app.js)
- Register the new `/api/vitals` route.

---

### Frontend - Health Monitor

#### [MODIFY] [health_tracking_provider.dart](file:///C:/Users/HP/Cradle/frontend/cradle_app/lib/providers/health_tracking_provider.dart)
- Update `addInitialLog`, `updateLog`, and `deleteLog` to use `ApiService`.
- Fetch real history from the backend instead of generating mock data.

## Verification Plan

### Automated Tests
- I will verify the backend logic by reviewing the service code for potential crashes.
- I will check the frontend's `ApiService` calls for correctness.

### Manual Verification
- The user should check if the Dengue alert (hardcoded) appears in the notification list after the fix.
- The user should try logging a vital (e.g., Blood Pressure) and see if it persists after restarting the app.
