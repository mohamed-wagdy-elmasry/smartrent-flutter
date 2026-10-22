class ModelHasYearsModel {
  Message message;
  Data data;
  String type;

  ModelHasYearsModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory ModelHasYearsModel.fromJson(Map<String, dynamic> json) =>
      ModelHasYearsModel(
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
  List<int> years;

  Data({required this.years});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    years: json["years"] == null
        ? []
        : List<int>.from(json["years"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "years": List<dynamic>.from(years.map((x) => x)),
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
