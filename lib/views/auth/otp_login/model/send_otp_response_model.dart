import 'dart:convert';

SendOtpResponseModel sendOtpResponseModelFromJson(String str) =>
    SendOtpResponseModel.fromJson(json.decode(str));

String sendOtpResponseModelToJson(SendOtpResponseModel data) =>
    json.encode(data.toJson());

class SendOtpResponseModel {
  final Message message;
  final String type;
  final bool otpDisabled;
  final int expiresInMinutes;

  SendOtpResponseModel({
    required this.message,
    required this.type,
    required this.otpDisabled,
    required this.expiresInMinutes,
  });

  factory SendOtpResponseModel.fromJson(Map<String, dynamic> json) {
    Message parsedMessage;
    final rawMessage = json["message"];
    if (rawMessage is Map<String, dynamic>) {
      parsedMessage = Message.fromJson(rawMessage);
    } else if (rawMessage is List) {
      parsedMessage = Message(
        success: List<String>.from(rawMessage.map((e) => e.toString())),
      );
    } else {
      parsedMessage = Message(success: []);
    }

    return SendOtpResponseModel(
      message: parsedMessage,
      type: json["type"] ?? json["status"] ?? 'success',
      otpDisabled: json["otp_disabled"] == true,
      expiresInMinutes: json["expires_in_minutes"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    "message": message.toJson(),
    "type": type,
    "otp_disabled": otpDisabled,
    "expires_in_minutes": expiresInMinutes,
  };

  bool get isSuccess => type == 'success';
}

class Message {
  final List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"] != null
        ? List<String>.from(json["success"].map((x) => x))
        : [],
  );

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(success.map((x) => x)),
  };
}
