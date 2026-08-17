# Implementation Plan - Direct MongoDB Integration with Fixed OTP

This plan configures the authentication flow to store all user data in MongoDB Atlas, while using a hardcoded OTP (`123456`) for the verification step.

## User Review Required

> [!IMPORTANT]
> - **MongoDB**: All user data will now be stored directly in your MongoDB Atlas cluster. No mock data will be used.
> - **OTP**: The verification screen will remain, but the backend will accept `123456` as the only valid code for now.

## Proposed Changes

### Backend Refinement

#### [MODIFY] [Auth Service](file:///D:/code/Cradle/backend/modules/auth/auth.service.js)
- Remove all mock database logic (`mockUsers`, connection checks).
- Hardcode OTP code to `123456` in both `register` and `login` methods.
- Save user records (including the fixed OTP) directly to MongoDB.

#### [MODIFY] [Database Config](file:///D:/code/Cradle/backend/config/db.js)
- Make the database connection strict (throw error if it fails) to ensure data persistence.

### Frontend (Flutter) Integration

#### [MODIFY] [Login Page](file:///D:/code/Cradle/frontend/cradle_app/lib/pages/auth/login_page.dart)
- Ensure the app navigates to the `OtpVerificationPage` upon successful submission.

#### [MODIFY] [OTP Verification Page](file:///D:/code/Cradle/frontend/cradle_app/lib/pages/otp_verification/otp_verification_page.dart)
- Ensure the page calls `authProvider.verifyOtp` to confirm the code with the backend.

## Verification Plan

### Manual Verification
1. Start the backend and verify the MongoDB Atlas connection.
2. Register a new user in the app.
3. On the OTP screen, enter `123456`.
4. Verify that the app navigates to the Dashboard.
5. Check your MongoDB Atlas Dashboard > Collections to confirm the new user is saved.
