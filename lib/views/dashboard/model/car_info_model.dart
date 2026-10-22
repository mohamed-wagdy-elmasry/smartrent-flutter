// To parse this JSON data, do
//
//     final carInfoModel = carInfoModelFromJson(jsonString);

import 'dart:convert';

CarInfoModel carInfoModelFromJson(String str) =>
    CarInfoModel.fromJson(json.decode(str));

String carInfoModelToJson(CarInfoModel data) => json.encode(data.toJson());

class CarInfoModel {
  Message message;
  Data data;
  String type;

  CarInfoModel({required this.message, required this.data, required this.type});

  factory CarInfoModel.fromJson(Map<String, dynamic> json) => CarInfoModel(
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
  String token;
  List<Car> cars;
  DataPath dataPath;

  Data({required this.token, required this.cars, required this.dataPath});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    cars: List<Car>.from(json["cars"].map((x) => Car.fromJson(x))),
    dataPath: DataPath.fromJson(json["data_path"]),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "cars": List<dynamic>.from(cars.map((x) => x.toJson())),
    "data_path": dataPath.toJson(),
  };
}

class Car {
  int id;
  int vendorId;
  List<String>? images;
  int? branchId;
  int carAreaId;
  int? carModelId;
  int carTypeId;
  String slug;
  CarTitle? carTitle;
  String carType;
  String carModel;
  int carYear;
  int seat;
  int? experience;
  String? carNumber;
  String fees;
  String? image;
  Map<String, dynamic>? model;
  int status;
  int approval;
  DateTime createdAt;
  DateTime updatedAt;

  Car({
    required this.id,
    required this.vendorId,
    required this.carAreaId,
    required this.carTypeId,
    required this.slug,
    this.carTitle,
    this.branchId,
    this.carModelId,
    required this.carType,
    required this.carModel,
    required this.carYear,
    required this.seat,
    this.experience,
    this.carNumber,
    List<String>? images,
    Map<String, dynamic>? model,
    required this.fees,
    this.image,
    required this.status,
    required this.approval,
    required this.createdAt,
    required this.updatedAt,
  }) : images = images,
       model = model;

  factory Car.fromJson(Map<String, dynamic> json) => Car(
    id: json["id"],
    vendorId: json["vendor_id"],
    branchId: json.containsKey("branch_id")
        ? (json["branch_id"] is int
              ? json["branch_id"]
              : int.tryParse(json["branch_id"]?.toString() ?? ''))
        : null,
    carAreaId: json["car_area_id"],
    carTypeId: json["car_type_id"],
    slug: json["slug"],
    carTitle: json["car_title"] == null
        ? null
        : CarTitle.fromJson(json["car_title"]),
    carModelId: json.containsKey("car_model_id")
        ? (json["car_model_id"] is int
              ? json["car_model_id"]
              : int.tryParse(json["car_model_id"]?.toString() ?? ''))
        : null,
    carType: json["car_type"],
    carModel: json["car_model"],
    carYear: json["year"],
    seat: json["seat"],
    // // Handle nullable and mixed-type values safely
    // experience: json.containsKey("experience") && json["experience"] != null
    //   ? (json["experience"] is int
    //     ? json["experience"] as int
    //     : int.tryParse(json["experience"].toString()))
    //   : null,
    // carNumber: json.containsKey("car_number") && json["car_number"] != null
    //   ? json["car_number"].toString()
    //   : null,
    fees: json["fees"],
    image: json["image"] == null ? null : json["image"].toString(),
    status: json["status"],
    approval: json["approval"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    // parse images which may be sent as a JSON array or as a stringified JSON
    images: (() {
      try {
        final raw = json.containsKey('images') ? json['images'] : null;
        if (raw == null) return null;
        List<String> parsed = [];
        if (raw is List) {
          parsed = raw
              .map((e) => e?.toString() ?? '')
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (raw is String) {
          final decoded = jsonDecode(raw);
          if (decoded is List) {
            parsed = decoded
                .map((e) => e?.toString() ?? '')
                .where((s) => s.isNotEmpty)
                .toList();
          }
        }
        return parsed.isEmpty ? null : parsed;
      } catch (e) {
        return null;
      }
    })(),
    model: (() {
      try {
        final rawModel = json.containsKey('model') ? json['model'] : null;
        if (rawModel == null) return null;
        if (rawModel is Map) return Map<String, dynamic>.from(rawModel);
        return null;
      } catch (e) {
        return null;
      }
    })(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "car_area_id": carAreaId,
    "car_type_id": carTypeId,
    "slug": slug,
    if (branchId != null) "branch_id": branchId,
    if (carModelId != null) "car_model_id": carModelId,
    if (carTitle != null) "car_title": carTitle!.toJson(),
    "car_model": carModel,
    "car_year": carYear,
    "car_type": carType,

    "seat": seat,
    // // Only include optional fields when non-null to avoid sending nulls
    // if (experience != null) "experience": experience,
    // if (carNumber != null) "car_number": carNumber,
    // images column (JSON array) - include only when present
    if (images != null) "images": List<dynamic>.from(images!.map((x) => x)),
    "fees": fees,
    if (image != null) "image": image,
    if (model != null) "model": model,
    "status": status,
    "approval": approval,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  /// Returns images list if present, otherwise a placeholder fallback.
  /// Use `imagesOrPlaceholder` in UI to always have at least one image.
  List<String> get imagesOrPlaceholder {
    const String defaultPlaceholder =
        'https://via.placeholder.com/300x200?text=No+Image';
    if (images != null && images!.isNotEmpty) {
      final filtered = images!
          .where((s) => s.trim().isNotEmpty && s.toLowerCase() != 'null')
          .toList();
      if (filtered.isNotEmpty) return filtered;
    }
    if (image != null &&
        image!.trim().isNotEmpty &&
        image!.toLowerCase() != 'null')
      return [image!];
    return [defaultPlaceholder];
  }
}

class CarTitle {
  Ar? en;
  Ar? fr;
  Ar? es;
  Ar? ar;

  CarTitle({this.en, this.fr, this.es, this.ar});

  factory CarTitle.fromJson(Map<String, dynamic> json) => CarTitle(
    en: json["en"] == null ? null : Ar.fromJson(json["en"]),
    fr: json["fr"] == null ? null : Ar.fromJson(json["fr"]),
    es: json["es"] == null ? null : Ar.fromJson(json["es"]),
    ar: json["ar"] == null ? null : Ar.fromJson(json["ar"]),
  );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (en != null) map["en"] = en!.toJson();
    if (fr != null) map["fr"] = fr!.toJson();
    if (es != null) map["es"] = es!.toJson();
    if (ar != null) map["ar"] = ar!.toJson();
    return map;
  }
}

class Ar {
  String carTitle;

  Ar({required this.carTitle});

  factory Ar.fromJson(Map<String, dynamic> json) =>
      Ar(carTitle: json["car_title"] ?? '');

  Map<String, dynamic> toJson() => {"car_title": carTitle};
}

class DataPath {
  String baseUrl;
  String imagePath;

  DataPath({required this.baseUrl, required this.imagePath});

  factory DataPath.fromJson(Map<String, dynamic> json) =>
      DataPath(baseUrl: json["base_url"], imagePath: json["image_path"]);

  Map<String, dynamic> toJson() => {
    "base_url": baseUrl,
    "image_path": imagePath,
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
