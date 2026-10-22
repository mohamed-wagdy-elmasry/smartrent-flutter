# OTP Login System - Flutter Integration Guide

## Overview

This document provides comprehensive integration guidelines for implementing passwordless OTP login using WhatsApp for both **Users** and **Vendors** in your Flutter application.

## Authentication Flow

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│   Flutter   │         │   Backend   │         │   Twilio    │
│     App     │         │     API     │         │  WhatsApp   │
└──────┬──────┘         └──────┬──────┘         └──────┬──────┘
       │                       │                       │
       │  1. Send OTP Request  │                       │
       ├──────────────────────>│                       │
       │   (mobile_code +      │                       │
       │     mobile)           │                       │
       │                       │  2. Generate OTP      │
       │                       │     & Send WhatsApp   │
       │                       ├──────────────────────>│
       │                       │                       │
       │  3. OTP Sent Success  │                       │
       │<──────────────────────┤                       │
       │                       │                       │
       │  4. User Enters OTP   │                       │
       │                       │                       │
       │  5. Verify OTP        │                       │
       ├──────────────────────>│                       │
       │   (mobile_code +      │                       │
       │    mobile + otp_code) │                       │
       │                       │  6. Validate OTP      │
       │                       │                       │
       │  7. Return JWT Token  │                       │
       │<──────────────────────┤                       │
       │                       │                       │
```

---

## API Base URL

```
Production: https://your-domain.com/api/v1
Development: http://localhost:8000/api/v1
```

---

## API Endpoints

### 1. User OTP Login

#### 1.1 Send OTP to User

**Endpoint:** `POST /otp/send`

**Headers:**

```json
{
    "Content-Type": "application/json",
    "Accept": "application/json"
}
```

**Request Body:**

```json
{
    "mobile_code": "+1",
    "mobile": "1234567890"
}
```

**Success Response (200):**

```json
{
    "message": {
        "success": ["OTP sent successfully to your WhatsApp"]
    },
    "data": {
        "mobile": "1234567890",
        "mobile_code": "+1",
        "expires_in_minutes": 10
    }
}
```

**Error Responses:**

_User Not Found (404):_

```json
{
    "message": {
        "error": [
            "No user found with this phone number. Please register first."
        ]
    },
    "data": []
}
```

_Account Banned (403):_

```json
{
    "message": {
        "error": [
            "Your account is temporarily banned. Please contact system admin."
        ]
    },
    "data": []
}
```

_Rate Limited (500):_

```json
{
    "message": {
        "error": ["Please wait 120 seconds before requesting a new OTP."]
    },
    "data": []
}
```

_Twilio Configuration Error (500):_

```json
{
    "message": {
        "error": [
            "Twilio configuration is not set. Please configure Twilio credentials in .env file."
        ]
    },
    "data": []
}
```

---

#### 1.2 Verify OTP and Login User

**Endpoint:** `POST /otp/verify`

**Headers:**

```json
{
    "Content-Type": "application/json",
    "Accept": "application/json"
}
```

**Request Body:**

```json
{
    "mobile_code": "+1",
    "mobile": "1234567890",
    "otp_code": "123456"
}
```

**Success Response (200):**

```json
{
    "message": {
        "success": ["Login Successful"]
    },
    "data": {
        "user_info": {
            "id": 1,
            "firstname": "John",
            "lastname": "Doe",
            "username": "johndoe",
            "email": "john@example.com",
            "mobile_code": "+1",
            "mobile": "1234567890",
            "full_mobile": "+11234567890",
            "status": 1,
            "email_verified": 1,
            "sms_verified": 1,
            "kyc_verified": 0,
            "two_factor_status": 0,
            "created_at": "2025-10-30T12:00:00.000000Z",
            "updated_at": "2025-10-30T12:00:00.000000Z"
        },
        "token_type": "Bearer",
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9..."
    }
}
```

**Error Responses:**

_Invalid OTP (400):_

```json
{
    "message": {
        "error": ["Invalid OTP code. You have 2 attempts remaining."]
    },
    "data": []
}
```

_OTP Expired (400):_

```json
{
    "message": {
        "error": ["OTP has expired. Please request a new OTP."]
    },
    "data": []
}
```

_Max Attempts Reached (400):_

```json
{
    "message": {
        "error": [
            "Maximum verification attempts reached. Please request a new OTP."
        ]
    },
    "data": []
}
```

_No Active OTP (400):_

```json
{
    "message": {
        "error": ["No active OTP found. Please request a new OTP."]
    },
    "data": []
}
```

---

### 2. Vendor OTP Login

#### 2.1 Send OTP to Vendor

**Endpoint:** `POST /vendor/otp/send`

**Headers:**

```json
{
    "Content-Type": "application/json",
    "Accept": "application/json"
}
```

**Request Body:**

```json
{
    "mobile_code": "+1",
    "mobile": "9876543210"
}
```

**Success Response (200):**

```json
{
    "message": {
        "success": ["OTP sent successfully to your WhatsApp"]
    },
    "data": {
        "mobile": "9876543210",
        "mobile_code": "+1",
        "expires_in_minutes": 10
    }
}
```

**Error Responses:** _(Same as User endpoints, but with "vendor" instead of "user")_

---

#### 2.2 Verify OTP and Login Vendor

**Endpoint:** `POST /vendor/otp/verify`

**Headers:**

```json
{
    "Content-Type": "application/json",
    "Accept": "application/json"
}
```

**Request Body:**

```json
{
    "mobile_code": "+1",
    "mobile": "9876543210",
    "otp_code": "654321"
}
```

**Success Response (200):**

```json
{
    "message": {
        "success": ["Login Successful"]
    },
    "data": {
        "vendor_info": {
            "id": 1,
            "firstname": "Jane",
            "lastname": "Smith",
            "username": "janesmith",
            "email": "jane@example.com",
            "mobile_code": "+1",
            "mobile": "9876543210",
            "full_mobile": "+19876543210",
            "status": 1,
            "email_verified": 1,
            "sms_verified": 1,
            "kyc_verified": 0,
            "two_factor_status": 0,
            "created_at": "2025-10-30T12:00:00.000000Z",
            "updated_at": "2025-10-30T12:00:00.000000Z"
        },
        "token_type": "Bearer",
        "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9..."
    }
}
```

**Error Responses:** _(Same as User endpoints)_

---

## Flutter Implementation Example

### 1. Setup HTTP Client

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiClient {
  static const String baseUrl = 'https://your-domain.com/api/v1';

  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

### 2. OTP Service Class

```dart
class OtpService {
  // Send OTP to User
  Future<Map<String, dynamic>> sendUserOtp(String mobileCode, String mobile) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/otp/send'),
        headers: ApiClient.getHeaders(),
        body: jsonEncode({
          'mobile_code': mobileCode,
          'mobile': mobile,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message']['success'][0],
        };
      } else {
        return {
          'success': false,
          'message': data['message']['error'][0],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify OTP for User
  Future<Map<String, dynamic>> verifyUserOtp(
    String mobileCode,
    String mobile,
    String otpCode
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/otp/verify'),
        headers: ApiClient.getHeaders(),
        body: jsonEncode({
          'mobile_code': mobileCode,
          'mobile': mobile,
          'otp_code': otpCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': data['data']['user_info'],
          'token': data['data']['token'],
          'message': data['message']['success'][0],
        };
      } else {
        return {
          'success': false,
          'message': data['message']['error'][0],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Send OTP to Vendor
  Future<Map<String, dynamic>> sendVendorOtp(String mobileCode, String mobile) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/vendor/otp/send'),
        headers: ApiClient.getHeaders(),
        body: jsonEncode({
          'mobile_code': mobileCode,
          'mobile': mobile,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': data['data'],
          'message': data['message']['success'][0],
        };
      } else {
        return {
          'success': false,
          'message': data['message']['error'][0],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Verify OTP for Vendor
  Future<Map<String, dynamic>> verifyVendorOtp(
    String mobileCode,
    String mobile,
    String otpCode
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiClient.baseUrl}/vendor/otp/verify'),
        headers: ApiClient.getHeaders(),
        body: jsonEncode({
          'mobile_code': mobileCode,
          'mobile': mobile,
          'otp_code': otpCode,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'vendor': data['data']['vendor_info'],
          'token': data['data']['token'],
          'message': data['message']['success'][0],
        };
      } else {
        return {
          'success': false,
          'message': data['message']['error'][0],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }
}
```

### 3. UI Implementation Example

```dart
class OtpLoginScreen extends StatefulWidget {
  final bool isVendor; // true for vendor, false for user

  const OtpLoginScreen({Key? key, this.isVendor = false}) : super(key: key);

  @override
  _OtpLoginScreenState createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _otpService = OtpService();
  final _mobileController = TextEditingController();
  final _otpController = TextEditingController();

  String _selectedCountryCode = '+1';
  bool _isOtpSent = false;
  bool _isLoading = false;
  int _expiresInMinutes = 10;

  Future<void> _sendOtp() async {
    if (_mobileController.text.isEmpty) {
      _showError('Please enter mobile number');
      return;
    }

    setState(() => _isLoading = true);

    final result = widget.isVendor
        ? await _otpService.sendVendorOtp(_selectedCountryCode, _mobileController.text)
        : await _otpService.sendUserOtp(_selectedCountryCode, _mobileController.text);

    setState(() => _isLoading = false);

    if (result['success']) {
      setState(() {
        _isOtpSent = true;
        _expiresInMinutes = result['data']['expires_in_minutes'];
      });
      _showSuccess(result['message']);
    } else {
      _showError(result['message']);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      _showError('Please enter valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    final result = widget.isVendor
        ? await _otpService.verifyVendorOtp(
            _selectedCountryCode,
            _mobileController.text,
            _otpController.text
          )
        : await _otpService.verifyUserOtp(
            _selectedCountryCode,
            _mobileController.text,
            _otpController.text
          );

    setState(() => _isLoading = false);

    if (result['success']) {
      // Save token and user data
      await _saveAuthData(result['token'], result[widget.isVendor ? 'vendor' : 'user']);

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showError(result['message']);
    }
  }

  Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    // Implement your local storage logic here
    // Example using shared_preferences:
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('auth_token', token);
    // await prefs.setString('user_data', jsonEncode(userData));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.isVendor ? 'Vendor' : 'User'} OTP Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isOtpSent) ...[
              // Country code and mobile number input
              Row(
                children: [
                  // Country code dropdown
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedCountryCode,
                      underline: SizedBox(),
                      items: ['+1', '+44', '+91', '+234']
                          .map((code) => DropdownMenuItem(
                                value: code,
                                child: Text(code),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedCountryCode = value!);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  // Mobile number field
                  Expanded(
                    child: TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _sendOtp,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Send OTP'),
              ),
            ] else ...[
              Text(
                'OTP sent to WhatsApp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Expires in $_expiresInMinutes minutes'),
              SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'Enter OTP',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _verifyOtp,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Verify OTP'),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isOtpSent = false;
                    _otpController.clear();
                  });
                },
                child: Text('Resend OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## Important Notes

### Rate Limiting

-   Users must wait **2 minutes** between OTP requests to prevent spam
-   Maximum **3 verification attempts** per OTP
-   OTP expires after **10 minutes**

### Security Best Practices

1. Always use HTTPS in production
2. Store JWT tokens securely (use flutter_secure_storage)
3. Clear OTP input after maximum attempts
4. Implement token refresh mechanism
5. Validate phone numbers before sending OTP

### Error Handling

Always handle these scenarios:

-   Network connectivity issues
-   Invalid phone number format
-   User/Vendor not found
-   Account banned/suspended
-   OTP expired
-   Maximum attempts reached
-   Twilio service unavailable

### Token Management

After successful login:

1. Store the JWT token securely
2. Include token in Authorization header for authenticated requests:
    ```dart
    'Authorization': 'Bearer YOUR_TOKEN_HERE'
    ```
3. Handle token expiration and refresh

### Testing

For testing purposes, you can:

1. Check OTP codes in the database table `otp_verifications`
2. Monitor Twilio dashboard for message delivery status
3. Test with Twilio test credentials (won't send actual WhatsApp messages)

---

## Configuration Requirements

### Backend Configuration

Ensure the following environment variables are set in the backend `.env` file:

```env
TWILIO_ACCOUNT_SID=your_account_sid_here
TWILIO_AUTH_TOKEN=your_auth_token_here
TWILIO_WHATSAPP_FROM=+14155238886
```

### Database Migration

Run the following command to create the OTP table:

```bash
php artisan migrate
```

---

## Support

For any issues or questions:

1. Check the backend logs at `storage/logs/laravel.log`
2. Verify Twilio credentials are correctly configured
3. Ensure the phone number is registered with the user/vendor account
4. Contact backend team for API-specific issues

---

## Changelog

### Version 1.0.0 (2025-10-30)

-   Initial implementation of OTP login system
-   WhatsApp-based OTP delivery via Twilio
-   Separate endpoints for User and Vendor authentication
-   Rate limiting and security measures implemented
