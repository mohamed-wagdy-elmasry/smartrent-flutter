# OTP Login Flow - Visual Guide

## The Smart Flow You Requested

Based on your requirement: *"when user login, if exists login, if not exists verify and create one then login, then let response json user must enter first name and last name and email and enter kyc"*

Here's the **best smart flow** implemented:

## Mobile App User Journey

```
┌──────────────────────────────────────────────────────────────────┐
│                    USER OPENS APP                                │
│                    Enters Mobile Number                          │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│  STEP 1: SEND OTP                                                │
│  POST /api/v1/otp/send                                           │
│  { mobile_code: "+20", mobile: "1099613699" }                    │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│  ✓ OTP sent to WhatsApp                                          │
│  "Check your WhatsApp for the code"                              │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│  STEP 2: VERIFY OTP                                              │
│  POST /api/v1/otp/verify                                         │
│  { mobile_code: "+20", mobile: "1099613699", otp_code: "123456" }│
└────────────────────┬─────────────────────────────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
    NEW USER                EXISTING USER
         │                       │
         ▼                       ▼
┌─────────────────┐     ┌──────────────────┐
│ AUTO-CREATE     │     │ LOAD PROFILE     │
│ firstname: User │     │ Check if         │
│ lastname: 10996 │     │ profile_complete │
│ email: mobile@  │     │ Check kyc_status │
│     app.local   │     │                  │
└────────┬────────┘     └────────┬─────────┘
         │                       │
         └───────────┬───────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│  ✓ TOKEN GENERATED & RETURNED                                    │
│  Response includes:                                              │
│  - token: "eyJ0eXAiOiJKV1Qi..."                                 │
│  - next_action: "complete_profile" | "submit_kyc" | "none"      │
│  - profile_complete: true | false                               │
│  - kyc_status: 0 | 1 | 2 | 3                                    │
└────────────────────┬─────────────────────────────────────────────┘
                     │
         ┌───────────┴──────────┬────────────────┐
         │                      │                │
    next_action:          next_action:      next_action:
  "complete_profile"      "submit_kyc"        "none"
         │                      │                │
         ▼                      │                │
┌─────────────────────────┐    │                │
│ SHOW PROFILE FORM       │    │                │
│ - First Name (required) │    │                │
│ - Last Name (required)  │    │                │
│ - Email (required)      │    │                │
└────────┬────────────────┘    │                │
         │                      │                │
         ▼                      │                │
┌──────────────────────────────────────────────┐│
│ STEP 3: COMPLETE PROFILE                     ││
│ POST /api/v1/user/profile/complete           ││
│ {                                             ││
│   firstname: "Ahmed",                         ││
│   lastname: "Hassan",                         ││
│   email: "ahmed@example.com"                  ││
│ }                                             ││
└────────┬─────────────────────────────────────┘│
         │                                       │
         └───────────┬───────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│  ✓ PROFILE UPDATED                                               │
│  Response: next_action = "submit_kyc"                            │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│ SHOW KYC DOCUMENT UPLOAD SCREEN                                 │
│ First, get the required fields                                  │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│ STEP 4: GET KYC FIELDS                                           │
│ GET /api/v1/user/kyc/fields                                      │
│                                                                  │
│ Response: List of required documents/fields                     │
│ - National ID (file)                                            │
│ - ID Number (text)                                              │
│ - etc...                                                        │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│ USER FILLS KYC FORM & UPLOADS DOCUMENTS                          │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│ STEP 5: SUBMIT KYC                                               │
│ POST /api/v1/user/kyc/submit                                     │
│ (multipart/form-data with files)                                │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│  ✓ KYC SUBMITTED                                                 │
│  kyc_status = 2 (Pending)                                        │
│  next_action = "none"                                            │
└────────────────────┬─────────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────────┐
│  🎉 COMPLETE! USER CAN NOW USE THE APP                           │
│  Navigate to Home/Dashboard                                     │
│                                                                  │
│  Note: KYC is pending admin approval                            │
│  User will be notified when approved                            │
└──────────────────────────────────────────────────────────────────┘
```

## Decision Tree (What the App Shows)

```
                    User opens app
                         │
                         ▼
                 Send OTP & Verify
                         │
                         ▼
            ┌────── next_action ──────┐
            │                          │
    ┌───────┴────────┐      ┌─────────┴────────┐
    │ complete_profile│      │   submit_kyc     │
    └───────┬────────┘      └─────────┬────────┘
            │                          │
            ▼                          ▼
    ┌──────────────┐          ┌──────────────────┐
    │ Show Profile │          │ Show KYC Upload  │
    │    Form      │          │     Screen       │
    └──────┬───────┘          └──────┬───────────┘
           │                         │
           │   After submission      │
           └───────┬─────────────────┘
                   │
                   ▼
              next_action
                   │
            ┌──────┴────────┐
            │   submit_kyc  │
            └──────┬────────┘
                   │
                   ▼
          ┌────────────────┐
          │  Show KYC Form │
          └────────┬───────┘
                   │
                   │  After submission
                   ▼
              next_action
                   │
            ┌──────┴────────┐
            │     none      │
            └──────┬────────┘
                   │
                   ▼
          ┌────────────────┐
          │  Navigate to   │
          │   Home Screen  │
          └────────────────┘
```

## Why This Is The Best Smart Flow

### 1. **Instant Access**
- User can login immediately with just mobile number
- No barriers to entry
- Fast onboarding

### 2. **Progressive Profiling**
- Profile completion happens AFTER user has token
- User can explore app first (if needed)
- Less friction in signup

### 3. **Guided Experience**
- App always knows what to show via `next_action`
- No confusion about "what do I do next?"
- Clear step-by-step process

### 4. **Flexible**
- If user exists: check their status and guide accordingly
- If new user: auto-create and guide through setup
- If returning user: skip completed steps

### 5. **Single Source of Truth**
- Backend tells frontend what to do
- All logic centralized in API
- Easy to modify flow without app updates

## Example JSON Responses at Each Step

### New User (First Time Login)
```json
{
  "next_action": "complete_profile",
  "profile_complete": false,
  "kyc_status": 0
}
→ App shows: Profile Form
```

### After Profile Completion
```json
{
  "next_action": "submit_kyc",
  "profile_complete": true,
  "kyc_status": 0
}
→ App shows: KYC Upload Screen
```

### After KYC Submission
```json
{
  "next_action": "none",
  "profile_complete": true,
  "kyc_status": 2
}
→ App shows: Home/Dashboard
```

### Returning Verified User
```json
{
  "next_action": "none",
  "profile_complete": true,
  "kyc_status": 1
}
→ App shows: Home/Dashboard
```

## Mobile App Pseudocode

```dart
Future<void> handleOtpVerify(String mobile, String code) async {
  // 1. Verify OTP
  final response = await api.verifyOtp(mobile, code);
  
  // 2. Save token
  await storage.saveToken(response.data.token);
  
  // 3. Check next action
  final nextAction = response.data.next_action;
  
  // 4. Navigate based on next_action
  if (nextAction == 'complete_profile') {
    // Show profile form with firstname, lastname, email
    Navigator.pushReplacement(
      context, 
      ProfileCompletionScreen()
    );
  } 
  else if (nextAction == 'submit_kyc') {
    // Show KYC document upload
    Navigator.pushReplacement(
      context, 
      KycSubmissionScreen()
    );
  } 
  else {
    // User is all set, go to home
    Navigator.pushReplacement(
      context, 
      HomeScreen()
    );
  }
}

Future<void> handleProfileComplete() async {
  // After user fills profile form
  final response = await api.completeProfile(
    firstname, lastname, email
  );
  
  // Check next action again
  final nextAction = response.data.next_action;
  
  if (nextAction == 'submit_kyc') {
    Navigator.pushReplacement(
      context, 
      KycSubmissionScreen()
    );
  } else {
    Navigator.pushReplacement(
      context, 
      HomeScreen()
    );
  }
}

Future<void> handleKycSubmit() async {
  // After user uploads KYC documents
  final response = await api.submitKyc(kycData);
  
  // Should always be 'none' after KYC
  // But we check to be safe
  final nextAction = response.data.next_action;
  
  if (nextAction == 'none') {
    // Show success message
    showSuccessDialog(
      "KYC submitted! Admin will review soon."
    );
    
    Navigator.pushReplacement(
      context, 
      HomeScreen()
    );
  }
}
```

## Summary

This flow is **smart** because:
1. ✅ Auto-creates account on first OTP verify
2. ✅ Returns clear `next_action` to guide the app
3. ✅ Allows progressive profile completion
4. ✅ Tracks KYC status automatically
5. ✅ Works for both new and returning users
6. ✅ No manual "check if user exists" logic needed in app
7. ✅ Backend fully controls the flow

The mobile app just needs to:
- Send OTP
- Verify OTP
- **Follow the `next_action` field**

It's that simple! 🎯
