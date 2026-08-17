# Implementation Plan - Mother Profile Persistence

This plan outlines the implementation of profile persistence for the mother's health data, including image support and synchronization with the User account.

## User Review Required

> [!IMPORTANT]
> - **Image Storage**: As requested to store everything in MongoDB, I will store the profile image as a **Base64 string**. For very large images, this might impact performance, so I will implement a basic compression/scaling on the Flutter side before upload.
> - **Name Sync**: Changing the name in the Mother Profile will automatically update the `full_name` in the main User account.
> - **LMP and Dates**: The backend will store `conception_date` (which corresponds to LMP in the UI) and `expected_due_date`.

## Proposed Changes

### 1. Backend Updates

#### [MODIFY] [motherProfile.model.js](file:///D:/code/Cradle/backend/modules/motherProfile/motherProfile.model.js)
- Add `profile_image` field (String, for Base64 data).

#### [MODIFY] [motherProfile.service.js](file:///D:/code/Cradle/backend/modules/motherProfile/motherProfile.service.js)
- Remove all mock database logic.
- Implement `getProfileByUserId`: If no profile exists, return a skeleton object with the user's `full_name` from the `User` collection.
- Implement `createOrUpdateProfile`: Save profile data. If `full_name` is changed, update the corresponding `User` document.

#### [MODIFY] [motherProfile.validation.js](file:///D:/code/Cradle/backend/modules/motherProfile/motherProfile.validation.js)
- Update validation to reflect the current schema fields.

---

### 2. Frontend Updates

#### [MODIFY] [auth_provider.dart](file:///D:/code/Cradle/frontend/cradle_app/lib/providers/auth_provider.dart)
- Add `fetchProfile()`: Retrieves the profile from `/api/profile`.
- Add `updateProfile(Map<String, dynamic> data)`: Sends profile updates to `/api/profile`.
- Automatically call `fetchProfile()` after a successful login/OTP verification.

#### [MODIFY] [personal_info_page.dart](file:///D:/code/Cradle/frontend/cradle_app/lib/pages/personal_info/personal_info_page.dart)
- On `initState`, call `authProvider.fetchProfile()` and populate all controllers/state variables.
- Update `_pickImage` to read the file bytes and convert to Base64.
- Update `saveProfile` to call `authProvider.updateProfile()` with all field values.

## Verification Plan

### Automated Tests
- Backend: Verify that updating the profile name correctly updates the `User` collection.
- Backend: Verify that fetching a profile for a new user returns the name entered during registration.

### Manual Verification
1. Register a new user with name "Jane".
2. Go to Personal Info page; verify "Jane" is pre-filled.
3. Change name to "Jane Smith", add a photo, and fill health details.
4. Save and restart the app.
5. Verify all data (including photo) persists and is displayed correctly.
