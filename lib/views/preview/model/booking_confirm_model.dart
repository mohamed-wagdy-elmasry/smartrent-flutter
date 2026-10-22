class BookingConfirmModel {
  Message? message;
  Data? data;
  String type;

  BookingConfirmModel({
    this.message,
    this.data,
    required this.type,
  });

  factory BookingConfirmModel.fromJson(Map<String, dynamic> json) =>
      BookingConfirmModel(
        message: json["message"] != null ? Message.fromJson(json["message"]) : null,
        data: json["data"] != null && json["data"] is Map ? Data.fromJson(json["data"]) : null,
        type: json["type"] ?? 'error',
      );

  Map<String, dynamic> toJson() => {
    "message": message?.toJson(),
    "data": data?.toJson(),
    "type": type,
  };
}

class Data {
  String? redirectUrl;
  List<RedirectLink>? redirectLinks;
  String? actionType;
  List<dynamic>? addressInfo;
  String? identifier;

  Data({
    this.redirectUrl,
    this.redirectLinks,
    this.actionType,
    this.addressInfo,
    this.identifier,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    redirectUrl: json["redirect_url"],
    redirectLinks: json["redirect_links"] != null
        ? List<RedirectLink>.from(
            json["redirect_links"].map((x) => RedirectLink.fromJson(x)))
        : null,
    actionType: json["action_type"],
    addressInfo: json["address_info"] != null
        ? List<dynamic>.from(json["address_info"].map((x) => x))
        : null,
    identifier: json["identifier"],
  );

  Map<String, dynamic> toJson() => {
    "redirect_url": redirectUrl,
    "redirect_links": redirectLinks != null
        ? List<dynamic>.from(redirectLinks!.map((x) => x.toJson()))
        : null,
    "action_type": actionType,
    "address_info": addressInfo != null
        ? List<dynamic>.from(addressInfo!.map((x) => x))
        : null,
  };
}

class RedirectLink {
  String href;
  String rel;
  String method;

  RedirectLink({required this.href, required this.rel, required this.method});

  factory RedirectLink.fromJson(Map<String, dynamic> json) => RedirectLink(
    href: json["href"],
    rel: json["rel"],
    method: json["method"],
  );

  Map<String, dynamic> toJson() => {"href": href, "rel": rel, "method": method};
}

class Message {
  List<String>? success;
  List<String>? error;

  Message({this.success, this.error});

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(
        success: json["success"] != null 
            ? List<String>.from(json["success"].map((x) => x)) 
            : null,
        error: json["error"] != null 
            ? List<String>.from(json["error"].map((x) => x)) 
            : null,
      );

  Map<String, dynamic> toJson() => {
    "success": success != null ? List<dynamic>.from(success!.map((x) => x)) : null,
    "error": error != null ? List<dynamic>.from(error!.map((x) => x)) : null,
  };
}
