import 'package:flutter/foundation.dart';

class PriceEstimateModel {
  final int carId;
  final int rentalDays;
  final String pricingTier;
  final double rateUsed;
  final double subtotal;
  final double? deliveryFee;
  final double? deliveryDistance;
  final String? deliverySource;
  final int taxPercentage;
  final double taxAmount;
  final double total;
  // Insurance fields
  final String? insuranceType;
  final double? insuranceDailyAmount;
  final double? insuranceSubtotal;
  final double? insuranceExcessLiabilityAmount;
  final Map<String, String>? insuranceMessage; // {en: "...", ar: "..."}

  PriceEstimateModel({
    required this.carId,
    required this.rentalDays,
    required this.pricingTier,
    required this.rateUsed,
    required this.subtotal,
    this.deliveryFee,
    this.deliveryDistance,
    this.deliverySource,
    required this.taxPercentage,
    required this.taxAmount,
    required this.total,
    this.insuranceType,
    this.insuranceDailyAmount,
    this.insuranceSubtotal,
    this.insuranceExcessLiabilityAmount,
    this.insuranceMessage,
  });

  factory PriceEstimateModel.fromJson(Map<String, dynamic> json) {
    debugPrint('[PriceEstimateModel] Parsing response: $json');
    
    final data = json['data'] as Map<String, dynamic>? ?? json;
    debugPrint('[PriceEstimateModel] Extracted data object: $data');
    
    double _d(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      final parsed = double.tryParse(v.toString());
      debugPrint('[PriceEstimateModel] Parsed "$v" (${v.runtimeType}) → $parsed');
      return parsed ?? 0.0;
    }
    
    double? _dn(dynamic v) {
      if (v == null) return null;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      final parsed = double.tryParse(v.toString());
      debugPrint('[PriceEstimateModel] Parsed nullable "$v" (${v.runtimeType}) → $parsed');
      return parsed;
    }
    
    int _i(dynamic v) => _d(v).toInt();

    // Parse insurance message (bilingual support)
    Map<String, String>? _parseInsuranceMessage(dynamic msg) {
      if (msg == null) return null;
      if (msg is Map<String, dynamic>) {
        final result = <String, String>{};
        if (msg['en'] != null) result['en'] = msg['en'].toString();
        if (msg['ar'] != null) result['ar'] = msg['ar'].toString();
        return result.isNotEmpty ? result : null;
      }
      return null;
    }

    final model = PriceEstimateModel(
      carId: _i(data['car_id']),
      rentalDays: _i(data['rental_days']),
      pricingTier: data['pricing_tier']?.toString() ?? '',
      rateUsed: _d(data['rate_used']),
      subtotal: _d(data['subtotal']),
      deliveryFee: _dn(data['delivery_fee']),
      deliveryDistance: _dn(data['delivery_distance']),
      deliverySource: data['delivery_source']?.toString(),
      taxPercentage: _i(data['tax_percentage']),
      taxAmount: _d(data['tax_amount']),
      total: _d(data['total']),
      // Insurance fields
      insuranceType: data['insurance_type']?.toString(),
      insuranceDailyAmount: _dn(data['insurance_daily_amount']),
      insuranceSubtotal: _dn(data['insurance_subtotal']),
      insuranceExcessLiabilityAmount: _dn(data['insurance_excess_liability_amount']),
      insuranceMessage: _parseInsuranceMessage(data['insurance_message']),
    );
    
    debugPrint('[PriceEstimateModel] ✅ Successfully parsed:');
    debugPrint('  - carId: ${model.carId}');
    debugPrint('  - rentalDays: ${model.rentalDays}');
    debugPrint('  - subtotal: ${model.subtotal}');
    debugPrint('  - deliveryFee: ${model.deliveryFee}');
    debugPrint('  - deliveryDistance: ${model.deliveryDistance}');
    debugPrint('  - deliverySource: ${model.deliverySource}');
    debugPrint('  - taxAmount: ${model.taxAmount}');
    debugPrint('  - total: ${model.total}');
    debugPrint('  - insuranceType: ${model.insuranceType}');
    debugPrint('  - insuranceDailyAmount: ${model.insuranceDailyAmount}');
    debugPrint('  - insuranceSubtotal: ${model.insuranceSubtotal}');
    debugPrint('  - insuranceExcessLiabilityAmount: ${model.insuranceExcessLiabilityAmount}');
    debugPrint('  - insuranceMessage: ${model.insuranceMessage}');
    
    return model;
  }
}
