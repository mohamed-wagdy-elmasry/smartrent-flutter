import '../../../base/widgets/country_drop_down.dart';

class ProfileInfoModel {
  Message message;
  Data data;

  ProfileInfoModel({
    required this.message,
    required this.data,
  });

  factory ProfileInfoModel.fromJson(Map<String, dynamic> json) =>
      ProfileInfoModel(
        message: Message.fromJson(json["message"]),
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "message": message.toJson(),
    "data": data.toJson(),
  };
}

class Message {
  List<String> success;

  Message({required this.success});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    success: json["success"] is List 
        ? List<String>.from(json["success"].map((x) => x.toString()))
        : [json["success"].toString()],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
  };
}

class Data {
  Instructions instructions;
  UserInfo userInfo;
  ImagePaths imagePaths;
  List<Country>? countries;

  Data({
    required this.instructions,
    required this.userInfo,
    required this.imagePaths,
    this.countries,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    instructions: Instructions.fromJson(json["instructions"]),
    userInfo: UserInfo.fromJson(json["user_info"]),
    imagePaths: ImagePaths.fromJson(json["image_paths"]),
    countries: json["countries"] != null
        ? List<Country>.from(json["countries"].map((x) => Country.fromJson(x)))
        : null,
  );

  Map<String, dynamic> toJson() => {
    "instructions": instructions.toJson(),
    "user_info": userInfo.toJson(),
    "image_paths": imagePaths.toJson(),
    if (countries != null) "countries": List<dynamic>.from(countries!.map((x) => x.toJson())),
  };
}

class Country implements CountryDropdownModel {
  int id;
  String name;
  String mobileCode;
  String currencyName;
  String currencyCode;
  String currencySymbol;

  Country({
    required this.id,
    required this.name,
    required this.mobileCode,
    required this.currencyName,
    required this.currencyCode,
    required this.currencySymbol,
  });

  factory Country.fromJson(Map<String, dynamic> json) => Country(
    id: json["id"],
    name: json["name"],
    mobileCode: json["mobile_code"],
    currencyName: json["currency_name"],
    currencyCode: json["currency_code"],
    currencySymbol: json["currency_symbol"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "mobile_code": mobileCode,
    "currency_name": currencyName,
    "currency_code": currencyCode,
    "currency_symbol": currencySymbol,
  };

  @override
  String get title => name;
}

class ImagePaths {
  String baseUrl;
  String pathLocation;
  String defaultImage;

  ImagePaths({
    required this.baseUrl,
    required this.pathLocation,
    required this.defaultImage,
  });

  factory ImagePaths.fromJson(Map<String, dynamic> json) => ImagePaths(
    baseUrl: json["base_url"],
    pathLocation: json["path_location"],
    defaultImage: json["default_image"],
  );

  Map<String, dynamic> toJson() => {
    "base_url": baseUrl,
    "path_location": pathLocation,
    "default_image": defaultImage,
  };
}

class Instructions {
  String kycVerified;

  Instructions({required this.kycVerified});

  factory Instructions.fromJson(Map<String, dynamic> json) =>
      Instructions(
        kycVerified: json["kyc_verified"]?.toString() ?? 'Status not available',
      );

  Map<String, dynamic> toJson() => {"kyc_verified": kycVerified};
}

class UserInfo {
  int id;
  String firstname;
  String lastname;
  String username;
  String email;
  String? mobileCode;
  String? mobile;
  String? image;
  String? nationalIdImage;
  String? drivingLicenseImage;
  String? nationalIdImageUrl;
  String? drivingLicenseImageUrl;
  int kycVerified;
  String country;
  String city;
  String state;
  String postalCode;
  String address;
  Kyc kyc;

  UserInfo({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.username,
    required this.email,
    this.mobileCode,
    this.mobile,
    this.image,
    this.nationalIdImage,
    this.drivingLicenseImage,
    this.nationalIdImageUrl,
    this.drivingLicenseImageUrl,
    required this.kycVerified,
    required this.country,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.address,
    required this.kyc,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json["id"] ?? 0,
    firstname: json["firstname"] ?? '',
    lastname: json["lastname"] ?? '',
    username: json["username"] ?? '',
    email: json["email"] ?? '',
    mobileCode: json["mobile_code"],
    mobile: json["mobile"],
    image: json["image"],
    nationalIdImage: json["national_id_image"],
    drivingLicenseImage: json["driving_license_image"],
    nationalIdImageUrl: json["nationalIdImageUrl"],
    drivingLicenseImageUrl: json["drivingLicenseImageUrl"],
    kycVerified: json["kyc_verified"] ?? 0,
    country: json["country"] ?? '',
    city: json["city"] ?? '',
    state: json["state"] ?? '',
    postalCode: json["postal_code"] ?? '',
    address: json["address"] ?? '',
    kyc: json["kyc"] != null ? Kyc.fromJson(json["kyc"]) : Kyc(data: {}, rejectReason: ''),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstname": firstname,
    "lastname": lastname,
    "username": username,
    "email": email,
    "mobile_code": mobileCode,
    "mobile": mobile,
    "image": image,
    "national_id_image": nationalIdImage,
    "driving_license_image": drivingLicenseImage,
    "nationalIdImageUrl": nationalIdImageUrl,
    "drivingLicenseImageUrl": drivingLicenseImageUrl,
    "kyc_verified": kycVerified,
    "country": country,
    "city": city,
    "state": state,
    "postal_code": postalCode,
    "address": address,
    "kyc": kyc.toJson(),
  };
}

class Kyc {
  Map<String, dynamic> data;
  String rejectReason;

  Kyc({required this.data, required this.rejectReason});

  factory Kyc.fromJson(Map<String, dynamic> json) => Kyc(
    data: json["data"] is Map ? Map<String, dynamic>.from(json["data"]) : {},
    rejectReason: json["reject_reason"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "data": data,
    "reject_reason": rejectReason,
  };
}
