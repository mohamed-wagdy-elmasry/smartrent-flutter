import 'dart:convert';

LogInModel logInModelFromJson(String str) =>
    LogInModel.fromJson(json.decode(str));

String logInModelToJson(LogInModel data) => json.encode(data.toJson());

class LogInModel {
  Message message;
  Data data;
  String type;

  LogInModel({required this.message, required this.data, required this.type});

  factory LogInModel.fromJson(Map<String, dynamic> json) {
    // message can be either an object {"success": [...]} or a list ["..."].
    Message parsedMessage;
    final rawMessage = json["message"];
    if (rawMessage is Map<String, dynamic>) {
      parsedMessage = Message.fromJson(rawMessage);
    } else if (rawMessage is List) {
      parsedMessage = Message(success: List<String>.from(rawMessage.map((e) => e.toString())));
    } else {
      parsedMessage = Message(success: []);
    }

    // type might be under "type" or the response may use "status"
    final parsedType = json["type"] ?? json["status"] ?? '';

    // data should be present as a map
    final rawData = json["data"] as Map<String, dynamic>? ?? {};

    return LogInModel(
      message: parsedMessage,
      data: Data.fromJson(rawData),
      type: parsedType,
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message.toJson(),
    "data": data.toJson(),
    "type": type,
  };
}

class Data {
  String token;
  UserInfo userInfo;
  Authorization authorization;

  Data({
    required this.token,
    required this.userInfo,
    required this.authorization,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"] ?? json["token"].toString(),
    // Support both `user_info` and `user` keys depending on API response
    userInfo: json.containsKey("user_info")
        ? UserInfo.fromJson(json["user_info"])
        : (json.containsKey("user") ? UserInfo.fromJson(json["user"]) : UserInfo.fallback()),
    // authorization can be missing in some responses
    authorization: json.containsKey("authorization")
        ? Authorization.fromJson(json["authorization"])
        : Authorization(status: false, token: ''),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "user_info": userInfo.toJson(),
    "authorization": authorization.toJson(),
  };
}

class Authorization {
  bool status;
  String token;

  Authorization({required this.status, required this.token});

  factory Authorization.fromJson(Map<String, dynamic> json) =>
    Authorization(status: json["status"] ?? false, token: json["token"] ?? '');

  Map<String, dynamic> toJson() => {"status": status, "token": token};
}

class UserInfo {
  int id;
  String? firstname;
  String lastname;
  String fullname;
  String username;
  String email;
  String mobileCode;
  String mobile;
  String fullMobile;
  int emailVerified;
  int kycVerified;
  int twoFactorVerified;
  int twoFactorStatus;
  dynamic twoFactorSecret;

  UserInfo({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.fullname,
    required this.username,
    required this.email,
    required this.mobileCode,
    required this.mobile,
    required this.fullMobile,
    required this.emailVerified,
    required this.kycVerified,
    required this.twoFactorVerified,
    required this.twoFactorStatus,
    required this.twoFactorSecret,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json["id"] ?? 0,
    firstname: json["firstname"] ?? '',
    lastname: json["lastname"] ?? '',
    fullname: json["fullname"] ?? '${json["firstname"] ?? ''} ${json["lastname"] ?? ''}',
    username: json["username"] ?? '',
    email: json["email"] ?? '',
    mobileCode: json["mobile_code"] ?? '',
    mobile: json["mobile"] ?? '',
    fullMobile: json["full_mobile"] ?? (json["full_mobile"] ?? ''),
    emailVerified: json["email_verified"] ?? (json["sms_verified"] == true ? 1 : 0),
    kycVerified: json["kyc_verified"] ?? 0,
    twoFactorVerified: json["two_factor_verified"] ?? 0,
    twoFactorStatus: json["two_factor_status"] ?? 0,
    twoFactorSecret: json["two_factor_secret"],
  );

  // Fallback user when API returns minimal `user` object or none
  factory UserInfo.fallback() => UserInfo(
    id: 0,
    firstname: '',
    lastname: '',
    fullname: '',
    username: '',
    email: '',
    mobileCode: '',
    mobile: '',
    fullMobile: '',
    emailVerified: 0,
    kycVerified: 0,
    twoFactorVerified: 0,
    twoFactorStatus: 0,
    twoFactorSecret: null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "fullname": fullname,
    "username": username,
    "email": email,
    "mobile_code": mobileCode,
    "mobile": mobile,
    "full_mobile": fullMobile,
    "email_verified": emailVerified,
    "kyc_verified": kycVerified,
    "two_factor_verified": twoFactorVerified,
    "two_factor_status": twoFactorStatus,
    "two_factor_secret": twoFactorSecret,
  };
}

class Message {
  List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(success: List<String>.from(json["success"].map((x) => x)));

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(success.map((x) => x)),
  };
}
