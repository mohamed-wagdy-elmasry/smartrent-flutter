import '../../../base/widgets/custom_drop_down.dart';

class AreaHasTypeModel {
  Message message;
  Data data;
  String type;

  AreaHasTypeModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory AreaHasTypeModel.fromJson(Map<String, dynamic> json) =>
      AreaHasTypeModel(
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
  Area area;

  Data({required this.area});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(area: Area.fromJson(json["area"]));

  Map<String, dynamic> toJson() => {"area": area.toJson()};
}

class TypesAll implements DropdownModel {
  int id;
  int carAreaId;
  int carTypeId;
  DateTime createdAt;
  dynamic updatedAt;
  dynamic name;
  Area? typeN;
  Area? type;

  TypesAll({
    required this.id,
    required this.carAreaId,
    required this.carTypeId,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.typeN,
    this.type,
  });

  factory TypesAll.fromJson(Map<String, dynamic> json) => TypesAll(
    id: json["id"],
    carAreaId: json["car_area_id"],
    carTypeId: json["car_type_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"],
    name: json["name"] ?? '',
    typeN: json["typeN"] == null ? null : Area.fromJson(json["typeN"]),
    type: json["type"] == null ? null : Area.fromJson(json["type"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "car_area_id": carAreaId,
    "car_type_id": carTypeId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt,
    "typeN": typeN?.toJson(),
    "type": type?.toJson(),
  };

  @override
  String get title => name;
}

class Area {
  int id;
  String name;
  String slug;
  int status;
  int lastEditBy;
  DateTime createdAt;
  DateTime updatedAt;
  List<TypesAll>? typesAll;

  Area({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.lastEditBy,
    required this.createdAt,
    required this.updatedAt,
    this.typesAll,
  });

  factory Area.fromJson(Map<String, dynamic> json) => Area(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    status: json["status"],
    lastEditBy: json["last_edit_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    typesAll: json["types"] == null
        ? []
        : List<TypesAll>.from(json["types"]!.map((x) => TypesAll.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "status": status,
    "last_edit_by": lastEditBy,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "typesAll": typesAll == null
        ? []
        : List<dynamic>.from(typesAll!.map((x) => x.toJson())),
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
