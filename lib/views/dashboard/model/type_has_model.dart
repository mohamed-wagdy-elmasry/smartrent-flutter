import '../../../base/widgets/custom_drop_down.dart';

class TypeHasModelModel {
  Message message;
  Data data;
  String type;

  TypeHasModelModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory TypeHasModelModel.fromJson(Map<String, dynamic> json) =>
      TypeHasModelModel(
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
  TypeData type;

  Data({required this.type});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(type: TypeData.fromJson(json["type"]));

  Map<String, dynamic> toJson() => {"type": type.toJson()};
}

class ModelsAll implements DropdownModel {
  int id;
  int carTypeId;
  String slug;
  String name;
  int status;
  int lastEditBy;
  DateTime createdAt;
  DateTime updatedAt;

  ModelsAll({
    required this.id,
    required this.carTypeId,
    required this.slug,
    required this.name,
    required this.status,
    required this.lastEditBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModelsAll.fromJson(Map<String, dynamic> json) => ModelsAll(
    id: json["id"],
    carTypeId: json["car_type_id"],
    slug: json["slug"] ?? '',
    name: json["name"] ?? '',
    status: json["status"] ?? 0,
    lastEditBy: json["last_edit_by"] ?? 0,
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "car_type_id": carTypeId,
    "slug": slug,
    "name": name,
    "status": status,
    "last_edit_by": lastEditBy,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  @override
  String get title => name;
}

class TypeData {
  int id;
  String slug;
  String name;
  int status;
  int lastEditBy;
  DateTime createdAt;
  DateTime updatedAt;
  List<ModelsAll>? models;

  TypeData({
    required this.id,
    required this.slug,
    required this.name,
    required this.status,
    required this.lastEditBy,
    required this.createdAt,
    required this.updatedAt,
    this.models,
  });

  factory TypeData.fromJson(Map<String, dynamic> json) => TypeData(
    id: json["id"],
    slug: json["slug"],
    name: json["name"],
    status: json["status"],
    lastEditBy: json["last_edit_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    models: json["models"] == null
        ? []
        : List<ModelsAll>.from(
            json["models"]!.map((x) => ModelsAll.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "slug": slug,
    "name": name,
    "status": status,
    "last_edit_by": lastEditBy,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "models": models == null
        ? []
        : List<dynamic>.from(models!.map((x) => x.toJson())),
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
