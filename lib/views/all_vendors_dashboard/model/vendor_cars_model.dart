// To parse this JSON data, do
//
//     final vendorCarsModel = vendorCarsModelFromJson(jsonString);

import 'dart:convert';

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

VendorCarsModel vendorCarsModelFromJson(String str) =>
    VendorCarsModel.fromJson(json.decode(str));

String vendorCarsModelToJson(VendorCarsModel data) =>
    json.encode(data.toJson());

class VendorCarsModel {
  bool success;
  List<String> message;
  VendorCarsData data;
  String? type;

  VendorCarsModel({
    required this.success,
    required this.message,
    required this.data,
    this.type,
  });

  factory VendorCarsModel.fromJson(Map<String, dynamic> json) =>
      VendorCarsModel(
        success: json["success"] ?? (json["type"] == "success"),
        message: (() {
          final m = json["message"];
          if (m == null) return <String>[];
          // Handle nested structure: { "success": [...] }
          if (m is Map) {
            final successList = m["success"];
            if (successList is List) {
              return List<String>.from(successList.map((x) => x.toString()));
            }
            return <String>[];
          }
          if (m is String) return <String>[m];
          if (m is List) return List<String>.from(m.map((x) => x.toString()));
          return <String>[];
        })(),
        data: VendorCarsData.fromJson(json["data"] ?? {}),
        type: json["type"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": List<dynamic>.from(message.map((x) => x)),
    "data": data.toJson(),
    if (type != null) "type": type,
  };
}

class VendorCarsData {
  String? token;
  List<VendorCar> cars;
  Pagination pagination;
  Map<String, dynamic> filtersApplied;
  MetaInfo meta;

  VendorCarsData({
    this.token,
    required this.cars,
    required this.pagination,
    required this.filtersApplied,
    required this.meta,
  });

  factory VendorCarsData.fromJson(Map<String, dynamic> json) => VendorCarsData(
    token: json["token"]?.toString(),
    cars: (() {
      final c = json["cars"];
      if (c == null) return <VendorCar>[];
      if (c is List)
        return List<VendorCar>.from(c.map((x) => VendorCar.fromJson(x)));
      // Unexpected shape -> return empty
      return <VendorCar>[];
    })(),
    pagination: json["pagination"] != null
        ? Pagination.fromJson(json["pagination"])
        : Pagination.empty(),
    filtersApplied: (() {
      final fa = json["filters_applied"];
      if (fa == null) return <String, dynamic>{};
      if (fa is Map) return Map<String, dynamic>.from(fa);
      // If API returns an array (e.g., []), treat as empty map
      return <String, dynamic>{};
    })(),
    meta: json["meta"] != null
        ? MetaInfo.fromJson(json["meta"])
        : MetaInfo.empty(),
  );

  Map<String, dynamic> toJson() => {
    if (token != null) "token": token,
    "cars": List<dynamic>.from(cars.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
    "filters_applied": filtersApplied,
    "meta": meta.toJson(),
  };
}

class VendorCar {
  int id;
  int vendorId;
  String vendorName;
  double vendorRating;
  int? branchId;
  String make;
  String model;
  String? modelImage;
  String type;
  int year;
  String color;
  String? licensePlate;
  String transmission;
  String fuelType;
  int seats;
  int doors;
  Pricing pricing;
  String currency;
  bool taxEnabled;
  double taxPercentage;
  double rating;
  int totalReviews;
  String availabilityStatus;
  String? nextAvailableDate;
  List<CarImage> images;
  List<String> features;
  bool insuranceIncluded;
  int? mileageLimitPerDay;
  String? mileageUnit;
  double? depositRequired;
  double? deliveryPrice;
  String? cancellationPolicy;
  VendorLocation? vendorLocation;
  bool isDeliveryAvailable;
  double? distanceKm;
  double? kmAllowance;
  double? kmOverageCharge;

  VendorCar({
    required this.id,
    required this.vendorId,
    required this.vendorName,
    required this.vendorRating,
    this.branchId,
    required this.make,
    required this.model,
    this.modelImage,
    required this.type,
    required this.year,
    required this.color,
    this.licensePlate,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.doors,
    required this.pricing,
    required this.currency,
    required this.taxEnabled,
    required this.taxPercentage,
    required this.rating,
    required this.totalReviews,
    required this.availabilityStatus,
    this.nextAvailableDate,
    required this.images,
    required this.features,
    required this.insuranceIncluded,
    this.mileageLimitPerDay,
    this.mileageUnit,
    this.depositRequired,
    this.deliveryPrice,
    this.cancellationPolicy,
    this.vendorLocation,
    required this.isDeliveryAvailable,
    this.distanceKm,
    this.kmAllowance,
    this.kmOverageCharge,
  });

  factory VendorCar.fromJson(Map<String, dynamic> json) => VendorCar(
    id: json["id"] ?? 0,
    vendorId: json["vendor_id"] ?? 0,
    vendorName: json["vendor_name"] ?? '',
    vendorRating: (json["vendor_rating"] ?? 0).toDouble(),
    branchId: json["branch_id"],
    make: json["make"] ?? '',
    model: json["model"] ?? '',
    modelImage: json["model_image"],
    type: json["type"] ?? '',
    year: json["year"] ?? 0,
    color: json["color"] ?? 'Not specified',
    licensePlate: json["license_plate"],
    transmission: json["transmission"] ?? 'automatic',
    fuelType: json["fuel_type"] ?? 'petrol',
    seats: json["seats"] ?? 0,
    doors: json["doors"] ?? 0,
    pricing: json["pricing"] != null
        ? Pricing.fromJson(json["pricing"])
        : Pricing.empty(),
    currency: json["currency"] ?? 'USD',
    taxEnabled: json["tax_enabled"] ?? false,
    taxPercentage: (json["tax_percentage"] ?? 0).toDouble(),
    rating: (json["rating"] ?? 0).toDouble(),
    totalReviews: json["total_reviews"] ?? 0,
    availabilityStatus: json["availability_status"] ?? 'available',
    nextAvailableDate: json["next_available_date"],
    images: json["images"] != null
        ? List<CarImage>.from(json["images"].map((x) => CarImage.fromJson(x)))
        : [],
    features: json["features"] != null
        ? List<String>.from(json["features"].map((x) => x))
        : [],
    insuranceIncluded: json["insurance_included"] ?? false,
    mileageLimitPerDay: json["mileage_limit_per_day"],
    mileageUnit: json["mileage_unit"],
    depositRequired: json["deposit_required"] != null
        ? (json["deposit_required"]).toDouble()
        : null,
    deliveryPrice: json["delivery_price"] != null
        ? (json["delivery_price"]).toDouble()
        : null,
    cancellationPolicy: json["cancellation_policy"],
    vendorLocation: json["vendor_location"] != null
        ? VendorLocation.fromJson(json["vendor_location"])
        : null,
    isDeliveryAvailable: json["is_delivery_available"] ?? false,
    distanceKm: _parseDouble(json["distance_km"]),
    kmAllowance: _parseDouble(json["km_allowance"]),
    kmOverageCharge: _parseDouble(json["km_overage_charge"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "vendor_name": vendorName,
    "vendor_rating": vendorRating,
    if (branchId != null) "branch_id": branchId,
    "make": make,
    "model": model,
    "model_image": modelImage,
    "type": type,
    "year": year,
    "color": color,
    "license_plate": licensePlate,
    "transmission": transmission,
    "fuel_type": fuelType,
    "seats": seats,
    "doors": doors,
    "pricing": pricing.toJson(),
    "currency": currency,
    "tax_enabled": taxEnabled,
    "tax_percentage": taxPercentage,
    "rating": rating,
    "total_reviews": totalReviews,
    "availability_status": availabilityStatus,
    "next_available_date": nextAvailableDate,
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "features": List<dynamic>.from(features.map((x) => x)),
    "insurance_included": insuranceIncluded,
    "mileage_limit_per_day": mileageLimitPerDay,
    "mileage_unit": mileageUnit,
    "deposit_required": depositRequired,
    "delivery_price": deliveryPrice,
    "cancellation_policy": cancellationPolicy,
    "vendor_location": vendorLocation?.toJson(),
    "is_delivery_available": isDeliveryAvailable,
    if (kmAllowance != null) "km_allowance": kmAllowance,
    if (kmOverageCharge != null) "km_overage_charge": kmOverageCharge,
  };

  String get displayName => '$make $model';

  bool get isAvailable => availabilityStatus == 'available';

  String get formattedPrice {
    // Map currency codes to their symbols (SAR for Saudi Riyal)
    final currencySymbols = {
      'SAR': 'ريال',
      'USD': '\$',
      'AED': 'د.إ',
      'EGP': '£',
      'KWD': 'د.ك',
    };
    final symbol = currencySymbols[currency] ?? currency;
    return '${symbol} ${pricing.price.toStringAsFixed(0)}/${pricing.unit}';
  }
}

class Pricing {
  String type;
  String currency;
  double price;
  double dailyPrice;
  double weeklyPrice;
  double monthlyPrice;
  String unit;
  String displayName;

  Pricing({
    required this.type,
    required this.currency,
    required this.price,
    required this.dailyPrice,
    required this.weeklyPrice,
    required this.monthlyPrice,
    required this.unit,
    required this.displayName,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
    type: json["type"] ?? 'per_day',
    currency: json["currency"] ?? 'USD',
    price: (json["price"] ?? 0).toDouble(),
    dailyPrice: (json["daily_price"] ?? 0).toDouble(),
    weeklyPrice: (json["weekly_price"] ?? 0).toDouble(),
    monthlyPrice: (json["monthly_price"] ?? 0).toDouble(),
    unit: json["unit"] ?? 'day',
    displayName: json["display_name"] ?? 'Price per day',
  );

  factory Pricing.empty() => Pricing(
    type: 'per_day',
    currency: 'USD',
    price: 0,
    dailyPrice: 0,
    weeklyPrice: 0,
    monthlyPrice: 0,
    unit: 'day',
    displayName: 'Price per day',
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "currency": currency,
    "price": price,
    "daily_price": dailyPrice,
    "weekly_price": weeklyPrice,
    "monthly_price": monthlyPrice,
    "unit": unit,
    "display_name": displayName,
  };
}

class CarImage {
  int id;
  String url;
  bool isPrimary;

  CarImage({required this.id, required this.url, required this.isPrimary});

  factory CarImage.fromJson(Map<String, dynamic> json) => CarImage(
    id: json["id"] ?? 0,
    url: json["url"] ?? '',
    isPrimary: json["is_primary"] ?? false,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "url": url,
    "is_primary": isPrimary,
  };
}

class VendorLocation {
  String? city;
  String? address;
  double? latitude;
  double? longitude;
  double? radiusKm;

  VendorLocation({this.city, this.address, this.latitude, this.longitude, this.radiusKm});

  factory VendorLocation.fromJson(Map<String, dynamic> json) => VendorLocation(
    city: json["city"],
    address: json["address"],
    latitude: json["latitude"] != null 
        ? (json["latitude"]).toDouble() 
        : (json["lat"] != null ? (json["lat"]).toDouble() : null),
    longitude: json["longitude"] != null
        ? (json["longitude"]).toDouble()
        : (json["long"] != null ? (json["long"]).toDouble() : null),
    radiusKm: json["radius_km"] != null
        ? (json["radius_km"]).toDouble()
        : (json["max_radius_km"] != null ? (json["max_radius_km"]).toDouble() : null),
  );

  Map<String, dynamic> toJson() => {
    "city": city,
    "address": address,
    "latitude": latitude,
    "longitude": longitude,
    if (radiusKm != null) "radius_km": radiusKm,
  };

  String get displayLocation {
    if (city != null && address != null) {
      return '$address, $city';
    } else if (city != null) {
      return city!;
    } else if (address != null) {
      return address!;
    }
    return 'Location not specified';
  }

  /// Compatibility alias: some parts of the codebase expect `maxRadiusKm`.
  /// Keep this computed getter to avoid lookup failures when reflecting getters.
  double? get maxRadiusKm => radiusKm;

  /// Backwards-compatible snake_case alias in case any reflection
  /// or generated code looks for `max_radius_km` as a getter name.
  double? get max_radius_km => radiusKm;
}

class Pagination {
  int currentPage;
  int perPage;
  int total;
  int totalPages;
  int from;
  int to;
  bool hasMore;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    required this.from,
    required this.to,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"] ?? 1,
    perPage: json["per_page"] ?? 15,
    total: json["total"] ?? 0,
    totalPages: json["total_pages"] ?? 0,
    from: json["from"] ?? 0,
    to: json["to"] ?? 0,
    hasMore: json["has_more"] ?? false,
  );

  factory Pagination.empty() => Pagination(
    currentPage: 1,
    perPage: 15,
    total: 0,
    totalPages: 0,
    from: 0,
    to: 0,
    hasMore: false,
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "per_page": perPage,
    "total": total,
    "total_pages": totalPages,
    "from": from,
    "to": to,
    "has_more": hasMore,
  };
}

class MetaInfo {
  List<String> availableTypes;
  List<String> pricingTypes;
  Map<String, PricingRange> priceRanges;
  YearRange yearRange;
  List<String> availableCities;

  MetaInfo({
    required this.availableTypes,
    required this.pricingTypes,
    required this.priceRanges,
    required this.yearRange,
    required this.availableCities,
  });

  factory MetaInfo.fromJson(Map<String, dynamic> json) => MetaInfo(
    availableTypes: json["available_types"] != null
        ? List<String>.from(json["available_types"].map((x) => x))
        : [],
    pricingTypes: json["pricing_types"] != null
        ? List<String>.from(json["pricing_types"].map((x) => x))
        : [],
    priceRanges: (() {
      final pr = json["price_ranges"];
      if (pr == null || pr is! Map) return <String, PricingRange>{};
      final result = <String, PricingRange>{};
      pr.forEach((key, value) {
        result[key.toString()] = PricingRange.fromJson(value);
      });
      return result;
    })(),
    yearRange: json["year_range"] != null
        ? YearRange.fromJson(json["year_range"])
        : YearRange.empty(),
    availableCities: json["available_cities"] != null
        ? List<String>.from(json["available_cities"].map((x) => x.toString()))
        : [],
  );

  factory MetaInfo.empty() => MetaInfo(
    availableTypes: [],
    pricingTypes: [],
    priceRanges: {},
    yearRange: YearRange.empty(),
    availableCities: [],
  );

  Map<String, dynamic> toJson() {
    final result = <String, dynamic>{
      "available_types": List<dynamic>.from(availableTypes.map((x) => x)),
      "pricing_types": List<dynamic>.from(pricingTypes.map((x) => x)),
      "year_range": yearRange.toJson(),
      "available_cities": List<dynamic>.from(availableCities.map((x) => x)),
    };
    final priceRangesMap = <String, dynamic>{};
    priceRanges.forEach((key, value) {
      priceRangesMap[key] = value.toJson();
    });
    result["price_ranges"] = priceRangesMap;
    return result;
  }
}

class PricingRange {
  double min;
  double max;

  PricingRange({required this.min, required this.max});

  factory PricingRange.fromJson(Map<String, dynamic> json) => PricingRange(
    min: (json["min"] ?? 0).toDouble(),
    max: (json["max"] ?? 0).toDouble(),
  );

  factory PricingRange.empty() => PricingRange(min: 0, max: 0);

  Map<String, dynamic> toJson() => {"min": min, "max": max};
}

class YearRange {
  int min;
  int max;

  YearRange({required this.min, required this.max});

  factory YearRange.fromJson(Map<String, dynamic> json) =>
      YearRange(min: json["min"] ?? 0, max: json["max"] ?? 0);

  factory YearRange.empty() => YearRange(min: 0, max: 0);

  Map<String, dynamic> toJson() => {"min": min, "max": max};
}
