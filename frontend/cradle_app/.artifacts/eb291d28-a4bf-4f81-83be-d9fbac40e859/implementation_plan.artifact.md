# Implementation Plan - UI Polish and Visibility Fixes

This plan addresses several UI issues where elements are still being obscured by system bars or the navigation bar, and refines the "Diagnosis" button's active state.

## User Review Required

> [!IMPORTANT]
> - I will wrap the bottom action bar of the Medication Sheet in a `SafeArea` to ensure it respects the system navigation bar on all devices.
> - The "Diagnosis" button in the bottom navigation bar will now use a solid light pink color when active, instead of a transparent overlay.

## Proposed Changes

### Bottom Navigation Bar

#### [MODIFY] [bottom_nav.dart](file:///D:/code/Cradle/frontend/cradle_app/lib/core/widgets/bottom_nav.dart)
- Change `_DiagnosisFab` selected color from `primaryPink.withValues(alpha: .2)` to a solid light pink `Color(0xFFFCE0EC)`.
- Change `_NavItem` selected background from `primaryPink.withValues(alpha: 0.12)` to a solid light pink `Color(0xFFFDEAF1)`.

### Screen Adjustments

#### [MODIFY] [dashboard_page.dart](file:///D:/code/Cradle/frontend/cradle_app/lib/pages/dashboard/dashboard_page.dart)
- Increase Emergency Ambulance button `bottom` to `160`.
- Increase scroll bottom padding to `180`.

#### [MODIFY] [medication_tracker_page.dart](file:///D:/code/Cradle/frontend/cradle_app/lib/pages/medication_tracker/medication_tracker_page.dart)
- Increase scroll bottom padding to `180`.

#### [MODIFY] [education_list_page.dart](file:///D:/code/Cradle/frontend/cradle_app/lib/pages/education/education_list_page.dart)
- Increase `ListView` bottom padding to `200`.

### Bottom Sheet Adjustments

#### [MODIFY] [add_medication_sheet.dart](file:///D:/code/Cradle/frontend/cradle_app/lib/pages/medication_tracker/widgets/add_medication_sheet.dart)
- Wrap the bottom action buttons `Container` in a `SafeArea` (specifically for the bottom).
- Adjust vertical padding in that container for better spacing.

## Verification Plan

### Manual Verification
- Verify the "Diagnosis" button looks correct and has no transparency in its active state.
- Check the "Add Medication" sheet on a device with a gesture bar (like a modern Android) to ensure "Save/Cancel" buttons are fully visible.
- Verify that the bottom-most articles in the Guides page are not cut off by the navigation bar.
- Ensure the ambulance button on the home page is at a comfortable floating height.
