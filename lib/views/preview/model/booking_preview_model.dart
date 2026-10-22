import '../../../base/widgets/custom_drop_down.dart';

class BookingPreviewModel {
  Message message;
  Data data;
  String type;

  BookingPreviewModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory BookingPreviewModel.fromJson(Map<String, dynamic> json) =>
      BookingPreviewModel(
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
  BookingDetails bookingDetails;
  String bookingCurrency;
  Car car;
  User user;
  PaymentType paymentType;
  List<PaymentGateway> paymentGateways;

  Data({
    required this.token,
    required this.bookingDetails,
    required this.bookingCurrency,
    required this.car,
    required this.user,
    required this.paymentType,
    required this.paymentGateways,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    token: json["token"],
    bookingDetails: BookingDetails.fromJson(json["booking_details"]),
    bookingCurrency: json["booking_currency"],
    car: Car.fromJson(json["car"]),
    user: User.fromJson(json["user"]),
    paymentType: PaymentType.fromJson(json["payment-type"]),
    paymentGateways: List<PaymentGateway>.from(
      json["payment_gateways"].map((x) => PaymentGateway.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "token": token,
    "booking_details": bookingDetails.toJson(),
    "booking_currency": bookingCurrency,
    "car": car.toJson(),
    "user": user.toJson(),
    "payment-type": paymentType.toJson(),
    "payment_gateways": List<dynamic>.from(
      paymentGateways.map((x) => x.toJson()),
    ),
  };
}

class BookingDetails {
  int carArea;
  int carType;
  String pickupTime;
  String pickupDate;

  BookingDetails({
    required this.carArea,
    required this.carType,
    required this.pickupTime,
    required this.pickupDate,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) => BookingDetails(
    carArea: json["car_area"],
    carType: json["car_type"],
    pickupTime: json["pickup_time"],
    pickupDate: json["pickup_date"],
  );

  Map<String, dynamic> toJson() => {
    "car_area": carArea,
    "car_type": carType,
    "pickup_time": pickupTime,
    "pickup_date": pickupDate,
  };
}

class Car {
  int id;
  int vendorId;
  int carAreaId;
  int carTypeId;
  String slug;
  String carModel;
  int seat;
  int experience;
  String carNumber;
  String fees;
  String image;
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
    required this.carModel,
    required this.seat,
    required this.experience,
    required this.carNumber,
    required this.fees,
    required this.image,
    required this.status,
    required this.approval,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) => Car(
    id: json["id"],
    vendorId: json["vendor_id"],
    carAreaId: json["car_area_id"],
    carTypeId: json["car_type_id"],
    slug: json["slug"],
    carModel: json["car_model"],
    seat: json["seat"],
    experience: json["experience"],
    carNumber: json["car_number"],
    fees: json["fees"],
    image: json["image"],
    status: json["status"],
    approval: json["approval"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "car_area_id": carAreaId,
    "car_type_id": carTypeId,
    "slug": slug,
    "car_model": carModel,
    "seat": seat,
    "experience": experience,
    "car_number": carNumber,
    "fees": fees,
    "image": image,
    "status": status,
    "approval": approval,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class PaymentGateway implements DropdownModel {
  int id;
  String type;
  String name;
  int crypto;
  dynamic desc;
  int status;
  List<Currency> currencies;

  PaymentGateway({
    required this.id,
    required this.type,
    required this.name,
    required this.crypto,
    required this.desc,
    required this.status,
    required this.currencies,
  });

  factory PaymentGateway.fromJson(Map<String, dynamic> json) => PaymentGateway(
    id: json["id"],
    type: json["type"],
    name: json["name"],
    crypto: json["crypto"],
    desc: json["desc"],
    status: json["status"],
    currencies: List<Currency>.from(
      json["currencies"].map((x) => Currency.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "name": name,
    "crypto": crypto,
    "desc": desc,
    "status": status,
    "currencies": List<dynamic>.from(currencies.map((x) => x.toJson())),
  };

  @override
  String get title => name;
}

class Currency implements DropdownModel {
  dynamic id;
  dynamic paymentGatewayId;
  String name;
  String alias;
  String currencyCode;
  String currencySymbol;
  dynamic image;
  dynamic minLimit;
  dynamic maxLimit;
  dynamic percentCharge;
  dynamic fixedCharge;
  dynamic rate;
  DateTime createdAt;
  DateTime updatedAt;

  Currency({
    required this.id,
    required this.paymentGatewayId,
    required this.name,
    required this.alias,
    required this.currencyCode,
    required this.currencySymbol,
    required this.image,
    required this.minLimit,
    required this.maxLimit,
    required this.percentCharge,
    required this.fixedCharge,
    required this.rate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    id: json["id"],
    paymentGatewayId: json["payment_gateway_id"],
    name: json["name"],
    alias: json["alias"],
    currencyCode: json["currency_code"],
    currencySymbol: json["currency_symbol"] ?? '',
    image: json["image"],
    minLimit: json["min_limit"],
    maxLimit: json["max_limit"],
    percentCharge: json["percent_charge"],
    fixedCharge: json["fixed_charge"],
    rate: json["rate"].toInt(),
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "payment_gateway_id": paymentGatewayId,
    "name": name,
    "alias": alias,
    "currency_code": currencyCode,
    "currency_symbol": currencySymbol,
    "image": image,
    "min_limit": minLimit,
    "max_limit": maxLimit,
    "percent_charge": percentCharge,
    "fixed_charge": fixedCharge,
    "rate": rate,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  @override
  String get title => name;
}

class PaymentType {
  String onlinePayment;
  String cash;

  PaymentType({required this.onlinePayment, required this.cash});

  factory PaymentType.fromJson(Map<String, dynamic> json) =>
      PaymentType(onlinePayment: json["online-payment"], cash: json["cash"]);

  Map<String, dynamic> toJson() => {
    "online-payment": onlinePayment,
    "cash": cash,
  };
}

class User {
  int id;
  String firstname;
  String lastname;
  String username;
  String email;
  dynamic mobileCode;
  dynamic mobile;
  dynamic fullMobile;
  dynamic referralId;
  dynamic image;
  int status;
  dynamic address;
  int emailVerified;
  int smsVerified;
  int kycVerified;
  dynamic verCode;
  dynamic verCodeSendAt;
  int twoFactorVerified;
  int twoFactorStatus;
  dynamic twoFactorSecret;
  dynamic emailVerifiedAt;
  dynamic deletedAt;
  DateTime createdAt;
  DateTime updatedAt;
  String fullname;
  String userImage;
  StringStatus stringStatus;
  String lastLogin;
  StringStatus kycStringStatus;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
    required this.mobileCode,
    required this.mobile,
    required this.fullMobile,
    required this.referralId,
    required this.image,
    required this.status,
    required this.address,
    required this.emailVerified,
    required this.smsVerified,
    required this.kycVerified,
    required this.verCode,
    required this.verCodeSendAt,
    required this.twoFactorVerified,
    required this.twoFactorStatus,
    required this.twoFactorSecret,
    required this.emailVerifiedAt,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.fullname,
    required this.userImage,
    required this.stringStatus,
    required this.lastLogin,
    required this.kycStringStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    firstname: json["firstname"],
    lastname: json["lastname"],
    username: json["username"],
    email: json["email"],
    mobileCode: json["mobile_code"],
    mobile: json["mobile"],
    fullMobile: json["full_mobile"],
    referralId: json["referral_id"],
    image: json["image"],
    status: json["status"],
    address: json["address"],
    emailVerified: json["email_verified"] ?? 0,
    smsVerified: json["sms_verified"] ?? 0,
    kycVerified: json["kyc_verified"] ?? 0,
    verCode: json["ver_code"],
    verCodeSendAt: json["ver_code_send_at"],
    twoFactorVerified: json["two_factor_verified"],
    twoFactorStatus: json["two_factor_status"],
    twoFactorSecret: json["two_factor_secret"],
    emailVerifiedAt: json["email_verified_at"],
    deletedAt: json["deleted_at"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    fullname: json["fullname"],
    userImage: json["userImage"],
    stringStatus: StringStatus.fromJson(json["stringStatus"]),
    lastLogin: json["lastLogin"],
    kycStringStatus: StringStatus.fromJson(json["kycStringStatus"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "email": email,
    "mobile_code": mobileCode,
    "mobile": mobile,
    "full_mobile": fullMobile,
    "referral_id": referralId,
    "image": image,
    "status": status,
    "address": address,
    "email_verified": emailVerified,
    "sms_verified": smsVerified,
    "kyc_verified": kycVerified,
    "ver_code": verCode,
    "ver_code_send_at": verCodeSendAt,
    "two_factor_verified": twoFactorVerified,
    "two_factor_status": twoFactorStatus,
    "two_factor_secret": twoFactorSecret,
    "email_verified_at": emailVerifiedAt,
    "deleted_at": deletedAt,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "fullname": fullname,
    "userImage": userImage,
    "stringStatus": stringStatus.toJson(),
    "lastLogin": lastLogin,
    "kycStringStatus": kycStringStatus.toJson(),
  };
}

class StringStatus {
  String stringStatusClass;
  String value;

  StringStatus({required this.stringStatusClass, required this.value});

  factory StringStatus.fromJson(Map<String, dynamic> json) =>
      StringStatus(stringStatusClass: json["class"], value: json["value"]);

  Map<String, dynamic> toJson() => {"class": stringStatusClass, "value": value};
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
