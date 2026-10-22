# Login Via OTP Feature

## Overview
A separate standalone screen for logging in using OTP (One-Time Password) that directly uses the `login-via-otp` endpoint without requiring a password.

## Implementation

### Files Created

1. **Controller**: `lib/views/auth/login_via_otp/controller/login_via_otp_controller.dart`
   - Manages mobile number validation
   - Sends OTP to user's mobile
   - Handles login via OTP using single endpoint
   - Provides resend OTP functionality

2. **Screen**: `lib/views/auth/login_via_otp/screen/login_via_otp_screen.dart`
   - Main screen with responsive layout (mobile/tablet)
   - Mobile screen: `login_via_otp_mobile_screen.dart`
   - Tablet screen: `login_via_otp_tablet_screen.dart`

3. **Widgets**:
   - `brand_logo.dart` - Displays app logo
   - `heading_widget.dart` - Screen title and description
   - `input_widget.dart` - Mobile number input with country code dropdown and OTP input field
   - `login_via_otp_button.dart` - Login button (visible after OTP is sent)
   - `have_password_widget.dart` - Link to password-based login

4. **Binding**: `lib/bindings/login_via_otp_binding.dart`
   - Dependency injection for LoginViaOtpController

5. **Route**: Added to `lib/routes/routes.dart`
   - Route name: `loginViaOtpScreen`
   - Path: `/loginViaOtpScreen`

## API Endpoint Used

- **Send OTP**: `POST /otp/send-otp`
  - Sends OTP to user's mobile number
  - Purpose: 'login'

- **Login Via OTP**: `POST /otp/login-via-otp`
  - Single-call endpoint that verifies OTP and logs in user
  - Returns authentication token on success

## User Flow

1. User enters mobile number with country code
2. User clicks "Send OTP" button
3. OTP is sent to user's mobile
4. OTP input field appears
5. User enters 6-digit OTP
6. User clicks "Login" button
7. App verifies OTP and logs in user (single API call)
8. User is redirected to dashboard/home screen

## Features

- **Phone Number Validation**: Real-time validation using `phone_numbers_parser`
- **Country Code Selection**: Dropdown with Gulf countries (+966, +971, +965, +974, +968, +973)
- **Resend OTP**: Allows user to request a new OTP
- **Form Validation**: Ensures mobile number and OTP are valid before submission
- **Loading States**: Shows loading indicators during API calls
- **Error Handling**: Displays user-friendly error messages
- **Navigation**: Easy switch between OTP login and password login

## How to Navigate to the Screen

```dart
Get.toNamed(Routes.loginViaOtpScreen);
```

Or from the regular login screen, users can use the link that says "Login with Password" which navigates back to the password-based login.

## Differences from Existing OTP Flow

The existing login flow has:
- Login screen with toggle between password and OTP mode
- OTP mode sends OTP, then navigates to a separate OTP verification screen
- After OTP verification, returns to login controller to complete login

The new standalone screen:
- Dedicated screen specifically for OTP login
- Single-page flow: enter mobile → send OTP → enter OTP → login
- Uses `loginViaOtpService` which combines OTP verification and login in one API call
- Cleaner, more focused user experience

## Code Quality

- ✅ No compilation errors
- ✅ Follows project structure and patterns
- ✅ Uses GetX for state management
- ✅ Responsive design (mobile/tablet)
- ✅ Proper validation and error handling
- ✅ Formatted with `dart format`
