import '../../../base/widgets/custom_drop_down.dart';

class CarAreaModel {
  Message message;
  List<Datum> data;
  String type;

  CarAreaModel({required this.message, required this.data, required this.type});

  factory CarAreaModel.fromJson(Map<String, dynamic> json) => CarAreaModel(
    message: Message.fromJson(json["message"]),
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "message": message.toJson(),
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "type": type,
  };
}

class Datum implements DropdownModel {
  int id;
  String name;
  String slug;
  int status;
  int lastEditBy;
  DateTime createdAt;
  DateTime updatedAt;

  Datum({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.lastEditBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    status: json["status"],
    lastEditBy: json["last_edit_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "status": status,
    "last_edit_by": lastEditBy,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  @override
  String get title => name;
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
