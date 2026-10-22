# OTP Login Flow - Quick Test Guide

## Quick Start Testing

### 1. Fix Applied ✓
The "Personal access client not found" error has been **FIXED** by running:
```bash
php83 artisan passport:client --personal --name="CarboWeb Personal Access Client"
```

### 2. Test the Flow

#### Step 1: Send OTP
```bash
POST http://192.168.1.211:8000/api/v1/otp/send
Content-Type: application/json

{
  "mobile_code": "+20",
  "mobile": "1099613699"
}
```

#### Step 2: Verify OTP (Creates Account if New)
```bash
POST http://192.168.1.211:8000/api/v1/otp/verify
Content-Type: application/json

{
  "mobile_code": "+20",
  "mobile": "1099613699",
  "otp_code": "123456"
}
```

**Expected Response:**
```json
{
  "message": ["Account created successfully. Please complete your profile."],
  "data": {
    "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "next_action": "complete_profile",
    "profile_complete": false,
    "kyc_status": 0
  }
}
```

#### Step 3: Complete Profile
```bash
POST http://192.168.1.211:8000/api/v1/user/profile/complete
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json

{
  "firstname": "Ahmed",
  "lastname": "Hassan",
  "email": "ahmed.hassan@example.com"
}
```

**Expected Response:**
```json
{
  "message": ["Profile completed successfully. Please submit your KYC documents."],
  "data": {
    "next_action": "submit_kyc",
    "profile_complete": true,
    "kyc_status": 0
  }
}
```

#### Step 4: Get KYC Fields
```bash
GET http://192.168.1.211:8000/api/v1/user/kyc/fields
Authorization: Bearer YOUR_TOKEN_HERE
```

#### Step 5: Submit KYC
```bash
POST http://192.168.1.211:8000/api/v1/user/kyc/submit
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: multipart/form-data

[Include dynamic fields from step 4]
```

**Expected Response:**
```json
{
  "message": ["KYC information successfully submitted"],
  "data": {
    "kyc_status": 2,
    "next_action": "none"
  }
}
```

## All New Endpoints

### Profile Completion
- `POST /api/v1/user/profile/complete` - Complete basic profile
- `GET /api/v1/user/profile/status` - Get profile status

### KYC
- `GET /api/v1/user/kyc/fields` - Get KYC form fields
- `POST /api/v1/user/kyc/submit` - Submit KYC documents
- `GET /api/v1/user/kyc/status` - Get KYC status

## Next Action Values

| Value | Meaning | What to Do |
|-------|---------|------------|
| `complete_profile` | Profile incomplete | Show profile form (firstname, lastname, email) |
| `submit_kyc` | KYC not submitted | Show KYC document upload form |
| `none` | Everything complete | Navigate to app home |

## KYC Status Values

| Value | Meaning | Color |
|-------|---------|-------|
| `0` | Unverified (not submitted) | Red |
| `1` | Approved (verified) | Green |
| `2` | Pending (under review) | Yellow |
| `3` | Rejected (can resubmit) | Red |

## Files Modified/Created

### Created
- `app/Http/Controllers/Api/V1/User/ProfileCompletionController.php`
- `app/Http/Controllers/Api/V1/User/KycController.php`
- `docs/OTP_LOGIN_PROFILE_KYC_FLOW.md`
- `docs/OTP_LOGIN_QUICK_TEST.md` (this file)

### Modified
- `app/Models/User.php` - Added `isProfileComplete()`, `needsKycSubmission()`, `getNextAction()`
- `app/Models/Admin/SetupKyc.php` - Added `userKyc()` scope
- `app/Http/Controllers/Api/V1/User/Auth/OtpLoginController.php` - Enhanced response with `next_action`
- `routes/api/v1/user.php` - Added profile completion and KYC routes
- `lang/en.json` - Added new translation keys
- `lang/es.json` - Added Spanish translations
- `lang/fr.json` - Added French translations
- `lang/ar.json` - Added Arabic translations

## Verify Routes

```bash
php83 artisan route:list --path=api/v1/user/profile
php83 artisan route:list --path=api/v1/user/kyc
```

## Clear Caches After Changes

```bash
php83 artisan config:clear
php83 artisan route:clear
php83 artisan cache:clear
```

## Common Errors & Solutions

### Error: "Personal access client not found"
**Solution:** Already fixed! Client ID 1 has been created.

### Error: "Please complete your profile before submitting KYC"
**Solution:** User must call `/profile/complete` endpoint first.

### Error: "You are already KYC Verified User"
**Solution:** User already has approved KYC (status = 1).

### Error: "User KYC section is under maintenance"
**Solution:** Admin needs to configure KYC fields in admin panel at `/admin/setup-kyc`.

## Smart Flow Summary

```
New User Login Flow:
1. Send OTP → 2. Verify OTP (auto-creates account)
   ↓
3. next_action = "complete_profile"
   ↓
4. Complete Profile (firstname, lastname, email)
   ↓
5. next_action = "submit_kyc"
   ↓
6. Get KYC Fields → 7. Submit KYC
   ↓
8. next_action = "none" (kyc_status = 2: Pending)
   ↓
9. Admin approves → kyc_status = 1 (Approved)
   ↓
10. User can now book cars! 🚗
```

## Testing Checklist

- [x] OTP send works
- [x] OTP verify creates new user
- [x] OTP verify returns `next_action`
- [x] Profile complete works
- [x] Profile status returns correct data
- [x] KYC fields endpoint works
- [x] KYC submit works
- [x] KYC status returns correct data
- [x] Translations in 4 languages
- [x] All routes registered
- [x] No PHP errors

## Production Deployment

1. Run migrations (already done):
   ```bash
   php83 artisan migrate
   ```

2. Create Passport client (already done):
   ```bash
   php83 artisan passport:client --personal
   ```

3. Configure KYC fields in admin panel

4. Clear all caches:
   ```bash
   php83 artisan optimize:clear
   ```

5. Test the complete flow with a real mobile number

## Support

For full documentation, see `docs/OTP_LOGIN_PROFILE_KYC_FLOW.md`
