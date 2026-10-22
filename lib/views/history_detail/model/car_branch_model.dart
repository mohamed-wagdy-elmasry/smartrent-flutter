int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

double? _parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

class CarBranch {
  final int id;
  final String? name;
  final String? address;
  final String? city;
  final String? phone;
  final String? email;
  final double? centerLat;
  final double? centerLng;

  const CarBranch({
    required this.id,
    this.name,
    this.address,
    this.city,
    this.phone,
    this.email,
    this.centerLat,
    this.centerLng,
  });

  factory CarBranch.fromJson(Map<String, dynamic> json) => CarBranch(
    id: _parseInt(json['id']) ?? 0,
    name: json['name']?.toString(),
    address: json['address']?.toString(),
    city: json['city']?.toString(),
    phone: json['phone']?.toString(),
    email: json['email']?.toString(),
    centerLat: _parseDouble(json['center_lat']),
    centerLng: _parseDouble(json['center_lng']),
  );
}

class CarBranchResponseModel {
  final CarBranch branch;

  const CarBranchResponseModel({required this.branch});

  factory CarBranchResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    final branchJson = data?['branch'] as Map<String, dynamic>?;
    if (branchJson == null) throw const FormatException('missing branch in response');
    return CarBranchResponseModel(branch: CarBranch.fromJson(branchJson));
  }
}
