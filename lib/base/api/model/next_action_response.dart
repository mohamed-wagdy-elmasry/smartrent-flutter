enum NextAction {
  completeProfile('complete_profile'),
  submitKyc('submit_kyc'),
  none('none');

  final String value;
  const NextAction(this.value);

  static NextAction fromString(String value) {
    switch (value) {
      case 'complete_profile':
        return NextAction.completeProfile;
      case 'submit_kyc':
        return NextAction.submitKyc;
      case 'none':
        return NextAction.none;
      default:
        return NextAction.none;
    }
  }
}

class OtpVerifyResponseModel {
  final bool success;
  final String message;
  final OtpVerifyData? data;

  OtpVerifyResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory OtpVerifyResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpVerifyResponseModel(
      success: json['success'] ?? true,
      message: (json['message'] is List)
          ? (json['message'] as List).join(', ')
          : json['message']?.toString() ?? '',
      data: json['data'] != null ? OtpVerifyData.fromJson(json['data']) : null,
    );
  }
}

class OtpVerifyData {
  final String token;
  final NextAction nextAction;
  final bool profileComplete;
  final int kycStatus;
  final UserInfo? userInfo;

  OtpVerifyData({
    required this.token,
    required this.nextAction,
    required this.profileComplete,
    required this.kycStatus,
    this.userInfo,
  });

  factory OtpVerifyData.fromJson(Map<String, dynamic> json) {
    return OtpVerifyData(
      token: json['token']?.toString() ?? '',
      nextAction: NextAction.fromString(json['next_action']?.toString() ?? 'none'),
      profileComplete: json['profile_complete'] == true,
      kycStatus: int.tryParse(json['kyc_status']?.toString() ?? '0') ?? 0,
      userInfo: json['user_info'] != null ? UserInfo.fromJson(json['user_info']) : null,
    );
  }
}

class UserInfo {
  final int id;
  final String firstname;
  final String lastname;
  final String username;
  final String email;
  final String mobileCode;
  final String mobile;
  final String fullMobile;
  final int status;
  final bool smsVerified;
  final bool emailVerified;
  final bool kycVerified;
  final bool twoFactorVerified;
  final bool twoFactorStatus;

  UserInfo({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
    required this.mobileCode,
    required this.mobile,
    required this.fullMobile,
    required this.status,
    required this.smsVerified,
    required this.emailVerified,
    required this.kycVerified,
    required this.twoFactorVerified,
    required this.twoFactorStatus,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      firstname: json['firstname']?.toString() ?? '',
      lastname: json['lastname']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      mobileCode: json['mobile_code']?.toString() ?? '',
      mobile: json['mobile']?.toString() ?? '',
      fullMobile: json['full_mobile']?.toString() ?? '',
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      smsVerified: json['sms_verified'] == true || json['sms_verified'] == 1,
      emailVerified: json['email_verified'] == true || json['email_verified'] == 1,
      kycVerified: json['kyc_verified'] == true || json['kyc_verified'] == 1,
      twoFactorVerified: json['two_factor_verified'] == true || json['two_factor_verified'] == 1,
      twoFactorStatus: json['two_factor_status'] == true || json['two_factor_status'] == 1,
    );
  }
}

class ProfileStatusModel {
  final bool success;
  final String message;
  final ProfileStatusData? data;

  ProfileStatusModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileStatusModel.fromJson(Map<String, dynamic> json) {
    return ProfileStatusModel(
      success: json['success'] ?? true,
      message: (json['message'] is List)
          ? (json['message'] as List).join(', ')
          : json['message']?.toString() ?? '',
      data: json['data'] != null ? ProfileStatusData.fromJson(json['data']) : null,
    );
  }
}

class ProfileStatusData {
  final NextAction nextAction;
  final bool profileComplete;
  final int kycStatus;

  ProfileStatusData({
    required this.nextAction,
    required this.profileComplete,
    required this.kycStatus,
  });

  factory ProfileStatusData.fromJson(Map<String, dynamic> json) {
    return ProfileStatusData(
      nextAction: NextAction.fromString(json['next_action']?.toString() ?? 'none'),
      profileComplete: json['profile_complete'] == true,
      kycStatus: int.tryParse(json['kyc_status']?.toString() ?? '0') ?? 0,
    );
  }
}

class ProfileCompleteResponseModel {
  final bool success;
  final String message;
  final ProfileCompleteData? data;

  ProfileCompleteResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProfileCompleteResponseModel.fromJson(Map<String, dynamic> json) {
    return ProfileCompleteResponseModel(
      success: json['success'] ?? true,
      message: (json['message'] is List)
          ? (json['message'] as List).join(', ')
          : json['message']?.toString() ?? '',
      data: json['data'] != null ? ProfileCompleteData.fromJson(json['data']) : null,
    );
  }
}

class ProfileCompleteData {
  final NextAction nextAction;
  final bool profileComplete;
  final int kycStatus;

  ProfileCompleteData({
    required this.nextAction,
    required this.profileComplete,
    required this.kycStatus,
  });

  factory ProfileCompleteData.fromJson(Map<String, dynamic> json) {
    return ProfileCompleteData(
      nextAction: NextAction.fromString(json['next_action']?.toString() ?? 'none'),
      profileComplete: json['profile_complete'] == true,
      kycStatus: int.tryParse(json['kyc_status']?.toString() ?? '0') ?? 0,
    );
  }
}
