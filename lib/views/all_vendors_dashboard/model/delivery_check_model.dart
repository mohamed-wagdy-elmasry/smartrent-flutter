import 'dart:convert';

DeliveryCheckResponse deliveryCheckResponseFromJson(String str) =>
    DeliveryCheckResponse.fromJson(json.decode(str));

String deliveryCheckResponseToJson(DeliveryCheckResponse data) =>
    json.encode(data.toJson());

class DeliveryCheckResponse {
  String status;
  String message;
  double? distanceKm;
  double? deliveryFee;
  double? maxRadiusKm;
  String? deliverySource;
  int? zoneId;
  DeliveryBranch? branch;

  DeliveryCheckResponse({
    required this.status,
    required this.message,
    this.distanceKm,
    this.deliveryFee,
    this.maxRadiusKm,
    this.deliverySource,
    this.zoneId,
    this.branch,
  });

  factory DeliveryCheckResponse.fromJson(Map<String, dynamic> json) {
    double? _dn(dynamic v) => v == null ? null : double.tryParse(v.toString());
    int? _in(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }
    // Support both top-level fields and nested under data{}
    final d = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    return DeliveryCheckResponse(
      status: json["status"] ?? d["status"] ?? 'error',
      message: json["message"] ?? d["message"] ?? '',
      distanceKm: _dn(d["distance_km"] ?? json["distance_km"]),
      deliveryFee: _dn(d["delivery_fee"] ?? json["delivery_fee"]),
      maxRadiusKm: _dn(d["max_radius_km"] ?? json["max_radius_km"]),
      deliverySource: (d["delivery_source"] ?? json["delivery_source"])?.toString(),
      zoneId: _in(d["zone_id"] ?? json["zone_id"]),
      branch: (d["branch"] ?? json["branch"]) != null
          ? DeliveryBranch.fromJson((d["branch"] ?? json["branch"]) as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        if (distanceKm != null) "distance_km": distanceKm,
        if (deliveryFee != null) "delivery_fee": deliveryFee,
        if (maxRadiusKm != null) "max_radius_km": maxRadiusKm,
        if (deliverySource != null) "delivery_source": deliverySource,
        if (zoneId != null) "zone_id": zoneId,
        if (branch != null) "branch": branch?.toJson(),
      };

  bool get isAvailable => status == 'available' || deliverySource == 'zone' || deliverySource == 'flat';
  bool get isUnavailable => status == 'unavailable' || deliverySource == 'none';
  bool get isError => status == 'error';
}

class DeliveryBranch {
  int id;
  String name;
  String? city;

  DeliveryBranch({
    required this.id,
    required this.name,
    this.city,
  });

  factory DeliveryBranch.fromJson(Map<String, dynamic> json) => DeliveryBranch(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        city: json["city"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        if (city != null) "city": city,
      };
}
