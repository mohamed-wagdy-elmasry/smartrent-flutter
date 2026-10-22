import 'dart:convert';
import '../../preview/model/manual_input_model.dart';

RePaymentInputFields rePaymentInputFieldsFromJson(String str) =>
    RePaymentInputFields.fromJson(json.decode(str));

String rePaymentInputFieldsToJson(RePaymentInputFields data) =>
    json.encode(data.toJson());

class RePaymentInputFields {
  Message message;
  Data data;
  String type;

  RePaymentInputFields({
    required this.message,
    required this.data,
    required this.type,
  });

  factory RePaymentInputFields.fromJson(Map<String, dynamic> json) =>
      RePaymentInputFields(
        message: Message.fromJson(json["message"]),
        data: Data.fromJson(json["data"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "message": message.toJson(),
        "data": data.toJson(),
        "type": type,
      };
}

class Data {
  Gateway gateway;
  List<InputField> inputFields;

  Data({required this.gateway, required this.inputFields});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        gateway: Gateway.fromJson(json["gateway"]),
        inputFields: List<InputField>.from(
          json["input_fields"].map((x) => InputField.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
        "gateway": gateway.toJson(),
        "input_fields": List<dynamic>.from(inputFields.map((x) => x.toJson())),
      };
}

class Gateway {
  String desc;

  Gateway({required this.desc});

  factory Gateway.fromJson(Map<String, dynamic> json) =>
      Gateway(desc: json["desc"]);

  Map<String, dynamic> toJson() => {"desc": desc};
}

class Message {
  List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: List<String>.from(json["success"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": List<dynamic>.from(success.map((x) => x)),
      };
}
