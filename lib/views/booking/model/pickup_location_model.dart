class PickupLocation {
  final double latitude;
  final double longitude;
  final String address;

  PickupLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
    };
  }

  factory PickupLocation.fromMap(Map<String, dynamic> map) {
    return PickupLocation(
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      address: map['address'] ?? '',
    );
  }

  @override
  String toString() => 'PickupLocation(lat: $latitude, lng: $longitude, address: $address)';
}
