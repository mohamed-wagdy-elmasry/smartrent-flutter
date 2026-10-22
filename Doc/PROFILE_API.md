# Profile API Reference

This document describes the REST API endpoints for fetching and updating user and vendor profiles, including optional document uploads (national ID and driving license).

## Authentication

-   User endpoints: Bearer token via `auth:api` (Laravel Passport)
-   Vendor endpoints: Bearer token via `auth:vendor_api`

---

## Common Rules for Document Images

-   Allowed MIME types: `jpg`, `jpeg`, `png`
-   Max size: 5 MB per document
-   Fields are optional; validated only when provided
-   Upload flow reuses repository helpers: `upload_file()`, `upload_files_from_path_dynamic()`, `delete_file()`

---

## Endpoints

### GET /api/v1/user/profile/info

-   Auth: `auth:api`
-   Description: Fetch authenticated user's profile and document image URLs
-   Response 200 (abridged):

```json
{
    "success": true,
    "message": ["Profile info fetch successfully!"],
    "data": {
        "user_info": {
            "id": 1,
            "firstname": "John",
            "lastname": "Doe",
            "username": "jdoe",
            "email": "john@example.com",
            "mobile_code": "966",
            "mobile": "501234567",
            "image": "avatar.jpg",
            "national_id_image": "nid_123.jpg",
            "driving_license_image": "dl_456.jpg",
            "nationalIdImageUrl": "https://yourdomain.com/frontend/user/nid_123.jpg",
            "drivingLicenseImageUrl": "https://yourdomain.com/frontend/user/dl_456.jpg",
            "kyc_verified": 0
        },
        "image_paths": {
            "base_url": "https://yourdomain.com",
            "path_location": "frontend/user",
            "default_image": "profile-default"
        },
        "countries": []
    }
}
```

Errors:

-   401 Unauthorized if token missing/invalid

---

### POST /api/v1/user/profile/info/update

-   Auth: `auth:api`
-   Content-Type: `multipart/form-data`
-   Description: Update profile fields; upload/replace profile and document images. Old images cleaned up automatically when replaced.

Request fields (all optional via FormRequest validation):

-   `firstname` (nullable|string|max:60)
-   `lastname` (nullable|string|max:60)
-   `country` (nullable|string|max:50)
-   `state` (nullable|string|max:50)
-   `city` (nullable|string|max:50)
-   `zip_code` (nullable|string|max:20)
-   `address` (nullable|string|max:250)
-   `image` (nullable|image|mimes:jpg,jpeg,png|max:5120) — Profile avatar
-   `national_id_image` (nullable|image|mimes:jpg,jpeg,png|max:5120) — National ID document
-   `driving_license_image` (nullable|image|mimes:jpg,jpeg,png|max:5120) — Driving license document

Note: Controller also has inline validation requiring `firstname`, `lastname`, `country`, `mobile_code`, and `mobile`; however, FormRequest validates fields as nullable. The controller's Validator::make enforces required fields after FormRequest passes.

Response 200:

```json
{ "success": true, "message": ["Profile successfully updated!"], "data": [] }
```

Validation errors:

-   422 Unprocessable Entity with array of validation messages (from FormRequest)
-   400 Bad Request used in controller for business checks (e.g., phone already exists)

Common validation error messages:

-   "The profile image must be a file of type: jpg, jpeg, png."
-   "The profile image must not exceed 5MB."
-   "The national ID image must be a valid image file."
-   "The driving license image must not exceed 5MB."

Example curl:

```bash
curl -X POST https://yourdomain.com/api/v1/user/profile/info/update \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "firstname=John" \
  -F "lastname=Doe" \
  -F "country=SA" \
  -F "state=Riyadh" \
  -F "city=Riyadh" \
  -F "zip_code=12345" \
  -F "address=123 Main St" \
  -F "national_id_image=@/path/to/nid.jpg" \
  -F "driving_license_image=@/path/to/dl.jpg"
```

Security:

-   Only authenticated user may update their own profile (guard enforced)
-   File validations enforced via `ProfileUpdateRequest` FormRequest

---

### GET /api/v1/vendor/profile/info

-   Auth: `auth:vendor_api`
-   Same response structure as user but returns vendor data

### POST /api/v1/vendor/profile/info/update

-   Auth: `auth:vendor_api`
-   Same fields, validations, and behavior as user update endpoint
-   Use vendor token and `vendor_api` guard

---

## Models & Requests

-   `app/Models/User.php` - now includes `national_id_image` and `driving_license_image` casts and accessors: `nationalIdImageUrl`, `drivingLicenseImageUrl`
-   `app/Models/Vendor/Vendor.php` - same changes for vendor
-   `app/Http/Requests/Api/V1/User/ProfileUpdateRequest.php` - validates image fields (5MB max)
-   `app/Http/Requests/Api/V1/Vendor/ProfileUpdateRequest.php` - vendor equivalent

---

## Storage

-   Current location: `public/frontend/user/`
-   Access URLs: `https://yourdomain.com/frontend/user/{filename}`
-   Consider moving sensitive documents to a private disk (`storage/app/private/...`) with an authenticated download endpoint for improved privacy

---

## KYC Control (Notes)

KYC enforcement is currently optional. To re-enable full KYC enforcement:

1. Set `basic_settings.kyc_verification` and `basic_settings.vendor_kyc_verification` to `1` in database
2. Re-apply `kyc.verification.guard` middleware to protected route groups in route files

---

## Errors & Edge Cases

-   401 Unauthorized: missing or invalid token
-   422 Validation errors: file type or size violations, missing required fields
-   400 Business rules (e.g., duplicate phone number)
-   500 Internal Server Error: unexpected exceptions

---

## Frontend Notes

-   Upload images as multipart form-data
-   Use accessor URLs from profile-info response to display images
-   Allow uploading one or both documents independently

---

## Changelog

-   Date: 2026-01-11
-   Added document upload support for `national_id_image` and `driving_license_image` for both users and vendors

---

For any further output formats (OpenAPI/Swagger or Postman collection), say which you prefer and I will generate it.
