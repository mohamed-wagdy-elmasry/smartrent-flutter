class NotificationModel {
  NotificationModelMessage message;
  Data data;
  String type;

  NotificationModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        message: NotificationModelMessage.fromJson(json["message"]),
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
  List<Notification> notification;

  Data({required this.notification});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    notification: List<Notification>.from(
      json["notification"].map((x) => Notification.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "notification": List<dynamic>.from(notification.map((x) => x.toJson())),
  };
}

class Notification {
  int id;
  int userId;
  String type;
  NotificationMessage message;
  DateTime createdAt;
  DateTime updatedAt;

  Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json["id"],
    userId: json["user_id"],
    type: json["type"],
    message: NotificationMessage.fromJson(json["message"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "type": type,
    "message": message.toJson(),
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class NotificationMessage {
  String title;
  String message;
  String time;
  String image;
  String? trxId;

  NotificationMessage({
    required this.title,
    required this.message,
    required this.time,
    required this.image,
    this.trxId,
  });

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      NotificationMessage(
        title: json["title"] as String? ?? 'Notification',
        message: json["message"] as String? ?? '',
        time: json["time"] as String? ?? '',
        image: json["image"] as String? ?? '',
        trxId: json["trx_id"] as String?,
      );

  Map<String, dynamic> toJson() => {
    "title": title,
    "message": message,
    "time": time,
    "image": image,
    "trx_id": trxId,
  };
}

class NotificationModelMessage {
  List<String> success;

  NotificationModelMessage({required this.success});

  factory NotificationModelMessage.fromJson(Map<String, dynamic> json) =>
      NotificationModelMessage(
        success: List<String>.from(json["success"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(success.map((x) => x)),
  };
}
