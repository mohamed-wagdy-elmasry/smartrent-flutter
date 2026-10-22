/// Filter model for vendor cars list
class VendorCarsFilter {
  final int? vendorId;
  final String? carType;
  final int? minYear;
  final int? maxYear;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy;
  final String? sortOrder;
  final String? city;

  VendorCarsFilter({
    this.vendorId,
    this.carType,
    this.minYear,
    this.maxYear,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.sortOrder,
    this.city,
  });

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    
    if (vendorId != null) params['vendor_id'] = vendorId.toString();
    if (carType != null && carType!.isNotEmpty) params['type'] = carType!;
    if (minYear != null) params['min_year'] = minYear.toString();
    if (maxYear != null) params['max_year'] = maxYear.toString();
    if (minPrice != null) params['min_price'] = minPrice.toString();
    if (maxPrice != null) params['max_price'] = maxPrice.toString();
    if (sortBy != null && sortBy!.isNotEmpty) params['sort_by'] = sortBy!;
    if (sortOrder != null && sortOrder!.isNotEmpty) params['sort_order'] = sortOrder!;
    if (city != null && city!.isNotEmpty) params['city'] = city!;
    
    return params;
  }

  VendorCarsFilter copyWith({
    int? vendorId,
    String? carType,
    int? minYear,
    int? maxYear,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    String? sortOrder,
    String? city,
  }) {
    return VendorCarsFilter(
      vendorId: vendorId ?? this.vendorId,
      carType: carType ?? this.carType,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      city: city ?? this.city,
    );
  }

  /// Clear all filters (preserves vendorId)
  VendorCarsFilter clear() {
    return VendorCarsFilter(vendorId: vendorId);
  }
}
