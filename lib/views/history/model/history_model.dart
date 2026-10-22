import '../../../base/enums/booking_status.dart';
import '../../../base/api/services/basic_services.dart';
import '../../history_detail/model/booking_extension_model.dart';
import '../../history_detail/model/invoice_row_model.dart';

double? _parseCoord(dynamic v) {
  if (v == null) return null;
  final d = double.tryParse(v.toString());
  if (d == null || (d == 0.0)) return null;
  return d;
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

int _parseIntOr(dynamic v, int fallback) => _parseInt(v) ?? fallback;

String? _parseReason(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  return s;
}

class HistoryModel {
  Message message;
  Data data;
  String type;

  HistoryModel({required this.message, required this.data, required this.type});

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
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
  List<History> history;
  Pagination? pagination;

  Data({required this.history, this.pagination});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    history: List<History>.from(
      json["history"].map((x) => History.fromJson(x)),
    ),
    pagination: json["pagination"] != null
        ? Pagination.fromJson(json["pagination"])
        : null,
  );

  Map<String, dynamic> toJson() => {
    "history": List<dynamic>.from(history.map((x) => x.toJson())),
    if (pagination != null) "pagination": pagination!.toJson(),
  };
}

class Pagination {
  int currentPage;
  int perPage;
  int total;
  int totalPages;
  int? from;
  int? to;
  bool hasMore;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.totalPages,
    this.from,
    this.to,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: _parseIntOr(json["current_page"], 1),
    perPage: _parseIntOr(json["per_page"], 5),
    total: _parseIntOr(json["total"], 0),
    totalPages: _parseIntOr(json["total_pages"], 0),
    from: _parseInt(json["from"]),
    to: _parseInt(json["to"]),
    hasMore: json["has_more"] ?? false,
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

class History {
  int? id;
  int? vendorId;
  int? branchId;
  String? approvedBy;
  DateTime? approvedAt;
  int? carId;
  int? userId;
  String? slug;
  String? phone;
  String? email;
  int? tripId;
  String? location;
  bool? isDeliver;
  String? destination;
  String paymentType;
  String? trxId;
  dynamic amount;
  dynamic charges;
  int distance;
  int rentalDays;
  String pickupTime;
  String? roundPickupTime;
  String? roundPickupDate;
  DateTime pickupDate;
  DateTime? returnAt;
  String message;
  BookingStatus status;
  DateTime createdAt;
  DateTime updatedAt;
  Cars cars;
  VendorInfo? vendorInfo;
  List<InvoiceRow> invoiceRows;
  double? dailyPrice;
  double? subtotal;
  double? deliveryFee;
  double? taxAmount;
  double? discountAmount;
  double? totalAmount;
  double? ledgerBalance;
  bool? canExtend;
  bool? canCancel;
  bool? canPay;
  PriceBreakdown? priceBreakdown;
  double? pickupLat;
  double? pickupLng;
  String? insuranceType;
  double? insuranceDailyAmount;
  double? insuranceExcessLiabilityAmount;
  String? rejectionReason;

  BookingStatus get bookingStatus => status;

  History({
    this.id,
    this.vendorId,
    this.branchId,
    this.approvedBy,
    this.approvedAt,
    this.carId,
    this.userId,
    this.slug,
    this.phone,
    this.email,
    this.tripId,
    this.location,
    this.isDeliver,
    required this.destination,
    required this.paymentType,
    this.trxId,
    required this.amount,
    this.charges,
    required this.distance,
    required this.rentalDays,
    required this.pickupTime,
    this.roundPickupTime,
    required this.pickupDate,
    this.returnAt,
    this.roundPickupDate,
    required this.message,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.cars,
    this.vendorInfo,
    this.invoiceRows = const [],
    this.dailyPrice,
    this.subtotal,
    this.deliveryFee,
    this.taxAmount,
    this.discountAmount,
    this.totalAmount,
    this.ledgerBalance,
    this.canExtend,
    this.canCancel,
    this.canPay,
    this.priceBreakdown,
    this.pickupLat,
    this.pickupLng,
    this.insuranceType,
    this.insuranceDailyAmount,
    this.insuranceExcessLiabilityAmount,
    this.rejectionReason,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
    id: _parseInt(json["id"]),
    vendorId: _parseInt(json["vendor_id"]),
    branchId: _parseInt(json["branch_id"]),
    approvedBy: json["approved_by"]?.toString(),
    approvedAt: json["approved_at"] == null
        ? null
        : DateTime.tryParse(json["approved_at"]),
    carId: _parseInt(json["car_id"]),
    userId: _parseInt(json["user_id"]),
    slug: json["slug"]?.toString(),
    phone: json["phone"]?.toString(),
    email: json["email"]?.toString(),
    tripId: _parseInt(json["trip_id"]),
    location:
        (json["location"] == null || json["location"].toString().trim().isEmpty)
        ? null
        : json["location"].toString(),
    isDeliver: json["is_deliver"],
    destination: json["destination"],
    paymentType: json["payment_type"],
    trxId: json["trx_id"]?.toString(),
    amount: json["amount"],
    charges: json["charges"],
    distance: _parseIntOr(json["distance"], 0),
    rentalDays: _parseIntOr(json["rental_days"], 0),
    pickupTime: json["pickup_time"],
    roundPickupTime: json["round_pickup_time"]?.toString(),
    pickupDate: DateTime.parse(json["pickup_date"]),
    returnAt: json["return_at"] != null
        ? DateTime.tryParse(json["return_at"].toString())
        : null,
    roundPickupDate: json["round_pickup_date"]?.toString(),
    message: json["message"] ?? '',
    status: BookingStatus.fromJson(json["status"]),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    cars: Cars.fromJson(json["cars"]),
    vendorInfo: json["cars"]?["vendor_info"] != null
        ? VendorInfo.fromJson(json["cars"]["vendor_info"])
        : null,
    invoiceRows: InvoiceRow.listFromJson(json["invoice_rows"]),
    dailyPrice: double.tryParse(json["daily_price"]?.toString() ?? ''),
    subtotal: double.tryParse(json["subtotal"]?.toString() ?? ''),
    deliveryFee: double.tryParse(json["delivery_fee"]?.toString() ?? ''),
    taxAmount: double.tryParse(json["tax_amount"]?.toString() ?? ''),
    discountAmount: double.tryParse(json["discount_amount"]?.toString() ?? ''),
    totalAmount: double.tryParse(json["total_amount"]?.toString() ?? ''),
    ledgerBalance: double.tryParse(json["ledger_balance"]?.toString() ?? ''),
    canExtend: json["can_extend"] as bool?,
    canCancel: json["can_cancel"] as bool?,
    canPay: json["can_pay"] as bool?,
    priceBreakdown: json["price_breakdown"] != null
        ? PriceBreakdown.fromJson(json["price_breakdown"] as Map<String, dynamic>)
        : null,
    pickupLat: _parseCoord(json["pickup_lat"] ?? json["lat"] ?? json["delivery_latitude"] ?? json["pickup_latitude"]),
    pickupLng: _parseCoord(json["pickup_lng"] ?? json["lng"] ?? json["delivery_longitude"] ?? json["pickup_longitude"]),
    insuranceType: json["insurance_type"]?.toString(),
    insuranceDailyAmount: double.tryParse(json["insurance_daily_amount"]?.toString() ?? ''),
    insuranceExcessLiabilityAmount: double.tryParse(json["insurance_excess_liability_amount"]?.toString() ?? ''),
    rejectionReason: _parseReason(json["rejection_reason"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "branch_id": branchId,
    "approved_by": approvedBy,
    "approved_at": approvedAt?.toIso8601String(),
    "car_id": carId,
    "user_id": userId,
    "slug": slug,
    "phone": phone,
    "email": email,
    "trip_id": tripId,
    "location": location,
    "is_deliver": isDeliver,
    "destination": destination,
    "payment_type": paymentType,
    "trx_id": trxId,
    "amount": amount,
    "charges": charges,
    "distance": distance,
    "rental_days": rentalDays,
    "pickup_time": pickupTime,
    "round_pickup_time": roundPickupTime,
    "pickup_date":
        "${pickupDate.year.toString().padLeft(4, '0')}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}",
    if (returnAt != null) "return_at": returnAt!.toIso8601String(),
    "round_pickup_date": roundPickupDate,
    "message": message,
    "status": status.value,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "cars": cars.toJson(),
    "vendor_info": vendorInfo?.toJson(),
    "invoice_rows": invoiceRows.map((r) => r.toJson()).toList(),
    if (dailyPrice != null) "daily_price": dailyPrice,
    if (subtotal != null) "subtotal": subtotal,
    if (deliveryFee != null) "delivery_fee": deliveryFee,
    if (taxAmount != null) "tax_amount": taxAmount,
    if (discountAmount != null) "discount_amount": discountAmount,
    if (totalAmount != null) "total_amount": totalAmount,
    if (ledgerBalance != null) "ledger_balance": ledgerBalance,
    if (canExtend != null) "can_extend": canExtend,
    if (canCancel != null) "can_cancel": canCancel,
    if (canPay != null) "can_pay": canPay,
    if (priceBreakdown != null) "price_breakdown": priceBreakdown!.toJson(),
    if (insuranceType != null) "insurance_type": insuranceType,
    if (insuranceDailyAmount != null) "insurance_daily_amount": insuranceDailyAmount,
    if (insuranceExcessLiabilityAmount != null) "insurance_excess_liability_amount": insuranceExcessLiabilityAmount,
    if (rejectionReason != null) "rejection_reason": rejectionReason,
  };
}

class Cars {
  String? carModel;
  String? carNumber;
  String? carType;
  String? image;

  Cars({this.carModel, this.carNumber, this.carType, this.image});

  factory Cars.fromJson(Map<String, dynamic> json) {
    // car_model and car_type are present in some responses; fall back to localized titles if needed
    String? model = json["car_model"]?.toString();
    if (model == null) {
      // try to extract from car_title.en.car_title or first available locale
      try {
        final carTitle = json["car_title"] as Map?;
        if (carTitle != null) {
          if (carTitle["en"] != null && carTitle["en"]["car_title"] != null) {
            model = carTitle["en"]["car_title"].toString();
          } else {
            final first = carTitle.values.firstWhere(
              (v) => v is Map && v["car_title"] != null,
              orElse: () => null,
            );
            if (first != null) model = first["car_title"].toString();
          }
        }
      } catch (_) {
        model = null;
      }
    }

    String? type = json["car_type"]?.toString();
    if (type == null) {
      try {
        final t = json["type"] as Map?;
        if (t != null && t["name"] != null) type = t["name"].toString();
      } catch (_) {
        type = null;
      }
    }

    final carNumber = json["car_number"]?.toString();

    // Resolve car image: try every key the backend may use
    String? image;
    for (final key in const ['model_image', 'image', 'car_image', 'photo', 'thumbnail']) {
      final v = json[key]?.toString();
      if (v != null && v.isNotEmpty) {
        image = v;
        break;
      }
    }
    if (image == null || image.isEmpty) {
      try {
        final imgs = json["images"] as List?;
        if (imgs != null && imgs.isNotEmpty) {
          image = imgs.first["url"]?.toString();
        }
      } catch (_) {}
    }
    // Ensure absolute URL — prepend basePath for relative paths
    if (image != null && image.isNotEmpty && !image.startsWith('http')) {
      final base = BasicServices.basePath.value.trimRight().replaceAll(RegExp(r'/+$'), '');
      final path = image.trimLeft().replaceAll(RegExp(r'^/+'), '');
      image = '$base/$path';
    }

    return Cars(carModel: model, carNumber: carNumber, carType: type, image: image);
  }

  Map<String, dynamic> toJson() => {
    "car_model": carModel,
    "car_number": carNumber,
    "car_type": carType,
    if (image != null) "model_image": image,
  };
}

class Message {
  List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) {
    List<String> successList = [];

    if (json["success"] != null) {
      if (json["success"] is List) {
        successList = List<String>.from(
          json["success"].map((x) => x?.toString() ?? ''),
        );
      } else if (json["success"] is String) {
        successList = [json["success"].toString()];
      }
    }

    return Message(success: successList);
  }

  Map<String, dynamic> toJson() => {
    "success": List<dynamic>.from(success.map((x) => x)),
  };
}

class VendorInfo {
  int? id;
  String? firstname;
  String? lastname;
  String? fullname;
  String? email;
  String? mobile;
  String? image;

  VendorInfo({
    this.id,
    this.firstname,
    this.lastname,
    this.fullname,
    this.email,
    this.mobile,
    this.image,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) => VendorInfo(
    id: _parseInt(json["id"]),
    firstname: json["firstname"]?.toString(),
    lastname: json["lastname"]?.toString(),
    fullname: json["fullname"]?.toString(),
    email: json["email"]?.toString(),
    mobile: json["mobile"]?.toString(),
    image: json["image"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "fullname": fullname,
    "email": email,
    "mobile": mobile,
    "image": image,
  };
}

class PriceBreakdown {
  final int rentalDays;
  final double rental;
  final double delivery;
  final double tax;
  final List<BookingExtension> extensions;
  final String? insuranceType;
  final double insuranceDailyAmount;
  final double insuranceExcessLiabilityAmount;
  final Map<String, dynamic>? insuranceMessage;

  const PriceBreakdown({
    required this.rentalDays,
    required this.rental,
    required this.delivery,
    required this.tax,
    required this.extensions,
    this.insuranceType,
    this.insuranceDailyAmount = 0.0,
    this.insuranceExcessLiabilityAmount = 0.0,
    this.insuranceMessage,
  });

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) {
    return PriceBreakdown(
      rentalDays: _parseIntOr(json['rental_days'], 0),
      rental: _pd(json['rental']),
      delivery: _pd(json['delivery']),
      tax: _pd(json['tax']),
      extensions: (json['extensions'] as List<dynamic>? ?? [])
          .map((e) => BookingExtension.fromJson(e as Map<String, dynamic>))
          .toList(),
      insuranceType: json['insurance_type']?.toString(),
      insuranceDailyAmount: _pd(json['insurance_daily_amount']),
      insuranceExcessLiabilityAmount: _pd(json['insurance_excess_liability_amount']),
      insuranceMessage: json['insurance_message'] is Map
          ? Map<String, dynamic>.from(json['insurance_message'] as Map)
          : null,
    );
  }

  /// Total insurance cost (daily insurance only).
  /// - daily: insuranceDailyAmount × rentalDays
  /// - excess_liability: NOT included (displayed separately, not in total)
  double get totalInsurance {
    if (insuranceType == 'daily') return insuranceDailyAmount * rentalDays;
    return 0.0;
  }

  double get grandTotal {
    final extTotal = extensions.fold(0.0, (s, e) => s + e.totalAmount);
    return rental + delivery + tax + totalInsurance + extTotal;
  }

  Map<String, dynamic> toJson() => {
    'rental_days': rentalDays,
    'rental': rental,
    'delivery': delivery,
    'tax': tax,
    'extensions': extensions.map((e) => {
      'id': e.id,
      'extra_days': e.extraDays,
      'extra_amount': e.extraAmount,
      'daily_rate': e.dailyRate,
      'tax_amount': e.taxAmount,
      'total_amount': e.totalAmount,
      'status': e.status.value,
    }).toList(),
    if (insuranceType != null) 'insurance_type': insuranceType,
    'insurance_daily_amount': insuranceDailyAmount,
    'insurance_excess_liability_amount': insuranceExcessLiabilityAmount,
    if (insuranceMessage != null) 'insurance_message': insuranceMessage,
  };

  static double _pd(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}
