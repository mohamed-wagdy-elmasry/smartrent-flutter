import 'dart:convert';

DeliveryZonesResponse deliveryZonesResponseFromJson(String str) =>
    DeliveryZonesResponse.fromJson(json.decode(str));

String deliveryZonesResponseToJson(DeliveryZonesResponse data) =>
    json.encode(data.toJson());

class DeliveryZonesResponse {
  String status;
  String message;
  DeliveryZonesData? data;

  DeliveryZonesResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory DeliveryZonesResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryZonesResponse(
      status: json["status"] ?? 'error',
      message: json["message"] ?? '',
      data: json["data"] != null
          ? DeliveryZonesData.fromJson(json["data"] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        if (data != null) "data": data?.toJson(),
      };

  bool get isSuccess => status == 'success';
  bool get hasZones => data?.zones != null && data!.zones!.isNotEmpty;
}

class DeliveryZonesData {
  BranchInfo? branch;
  DeliveryCoverage? coverage;
  List<DeliveryZone>? zones;
  int? totalZones;

  DeliveryZonesData({
    this.branch,
    this.coverage,
    this.zones,
    this.totalZones,
  });

  factory DeliveryZonesData.fromJson(Map<String, dynamic> json) {
    return DeliveryZonesData(
      branch: json["branch"] != null
          ? BranchInfo.fromJson(json["branch"] as Map<String, dynamic>)
          : null,
      coverage: json["coverage"] != null
          ? DeliveryCoverage.fromJson(json["coverage"] as Map<String, dynamic>)
          : null,
      zones: json["zones"] != null
          ? List<DeliveryZone>.from(
              (json["zones"] as List)
                  .map((x) => DeliveryZone.fromJson(x as Map<String, dynamic>)))
          : null,
      totalZones: _parseInt(json["total_zones"]),
    );
  }

  Map<String, dynamic> toJson() => {
        if (branch != null) "branch": branch?.toJson(),
        if (coverage != null) "coverage": coverage?.toJson(),
        if (zones != null) "zones": zones?.map((x) => x.toJson()).toList(),
        if (totalZones != null) "total_zones": totalZones,
      };
}

class BranchInfo {
  int? id;
  String? name;
  String? city;

  BranchInfo({
    this.id,
    this.name,
    this.city,
  });

  factory BranchInfo.fromJson(Map<String, dynamic> json) {
    return BranchInfo(
      id: _parseInt(json["id"]),
      name: json["name"]?.toString(),
      city: json["city"]?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) "id": id,
        if (name != null) "name": name,
        if (city != null) "city": city,
      };
}

class DeliveryCoverage {
  double? minKm;
  double? maxKm;

  DeliveryCoverage({
    this.minKm,
    this.maxKm,
  });

  factory DeliveryCoverage.fromJson(Map<String, dynamic> json) {
    return DeliveryCoverage(
      minKm: _parseDouble(json["min_km"]),
      maxKm: _parseDouble(json["max_km"]),
    );
  }

  Map<String, dynamic> toJson() => {
        if (minKm != null) "min_km": minKm,
        if (maxKm != null) "max_km": maxKm,
      };

  bool get isValid => maxKm != null && maxKm! > 0;
}

class DeliveryZone {
  int? id;
  double? minKm;
  double? maxKm;
  double? fee;

  DeliveryZone({
    this.id,
    this.minKm,
    this.maxKm,
    this.fee,
  });

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    return DeliveryZone(
      id: _parseInt(json["id"]),
      minKm: _parseDouble(json["min_km"]),
      maxKm: _parseDouble(json["max_km"]),
      fee: _parseDouble(json["fee"]),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) "id": id,
        if (minKm != null) "min_km": minKm,
        if (maxKm != null) "max_km": maxKm,
        if (fee != null) "fee": fee,
      };
}

/// Safe int parser — handles null, int, string, double inputs
int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// Safe double parser — handles null, int, string, double inputs
double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}
