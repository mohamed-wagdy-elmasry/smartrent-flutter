part of '../screen/preview_screen.dart';

class PreviewSectionCard extends GetView<PreviewController> {
  PreviewSectionCard({super.key});

  /// Format price: 200 when whole, 200.50 when fractional
  static String _smartPrice(num v) {
    return v == v.truncate() ? v.truncate().toString() : v.toStringAsFixed(2);
  }

  /// Map ISO currency code to display symbol
  static String _cur(String? code) {
    switch (code?.toUpperCase()) {
      case 'SAR': return 'ر.س';
      case 'AED': return 'د.إ';
      case 'KWD': return 'د.ك';
      case 'BHD': return 'د.ب';
      case 'QAR': return 'ر.ق';
      case 'OMR': return 'ر.ع';
      case 'EGP': return 'ج.م';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default:    return code ?? 'ر.س';
    }
  }

  /// Get the existing BookingController (registered by binding, not a new instance)
  late final bookController = Get.find<BookingController>();

  @override
  Widget build(BuildContext context) {
    debugPrint('[PreviewSectionCard] Building with bookController:');
    debugPrint('  - isDeliver: ${bookController.isDeliver.value}');
    debugPrint('  - deliveryCharge: ${bookController.deliveryCharge.value}');
    debugPrint('  - deliverySource: ${bookController.deliverySource.value}');
    debugPrint('  - pickupLocation: ${bookController.pickupLocation.value?.address}');
    
    return Column(
      crossAxisAlignment: crossStart,
      children: [
        TextWidget(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.5,
          ),
          Strings.preview,
          fontWeight: FontWeight.bold,
          fontSize: Dimensions.titleSmall,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: Dimensions.verticalSize * 0.5,
            horizontal: Dimensions.defaultHorizontalSize,
          ),
          decoration: BoxDecoration(
            color: CustomColor.whiteColor,
            borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
          ),
          child: Obx(
            () {
              debugPrint('[PreviewSectionCard] Obx rebuild triggered:');
              debugPrint('  - deliveryCharge: ${bookController.deliveryCharge.value}');
              debugPrint('  - isDeliver: ${bookController.isDeliver.value}');
              debugPrint('  - Show delivery? ${bookController.isDeliver.value && bookController.deliveryCharge.value > 0}');
              
              return Column(
              children: [
                if (bookController.isDeliver.value)
                  _cardSection(
                    Strings.PickUpLocation,
                    // Prefer pickupLocation.address (set by map picker), fallback to text controller
                    bookController.pickupLocation.value?.address ?? bookController.locationController.text,
                  ),
                if (bookController.isDeliver.value)
                  _cardSection(
                    Strings.PickUpdate,
                    bookController.pickupDate.value,
                  ),
                if (bookController.isDeliver.value)
                  _cardSection(
                    Strings.PickUpTime,
                    bookController.pickupTime.value,
                  ),
                _cardSection(
                  Strings.rentalDays,
                  bookController.quantityController.text,
                ),
                if (bookController.isDeliver.value)
                  _cardSection(
                    Strings.deliveryCar,
                    DynamicLanguage.key(Strings.yes),
                  ),
                _cardSection(
                  bookController.pricingType.value == 'per_day'
                      ? Strings.pricePerDay
                      : Strings.pricePerKm,
                  '${_smartPrice(bookController.effectivePrice.value > 0 ? bookController.effectivePrice.value : (bookController.selectedPricing.value?.price ?? 0))} ${_cur(bookController.selectedPricing.value?.currency)}',
                ),
                _cardSection(
                  Strings.totalRent,
                  '${_smartPrice(bookController.subtotal.value)} ${_cur(bookController.selectedPricing.value?.currency)}',
                ),
                if (bookController.isDeliver.value && bookController.deliveryCharge.value > 0)
                  _cardSection(
                    Strings.deliveryCharge,
                    '${_smartPrice(bookController.deliveryCharge.value)} ${_cur(bookController.selectedPricing.value?.currency)}',
                  ),
                if (bookController.selectedCar.value != null &&
                    bookController.selectedCar.value!.taxEnabled &&
                    bookController.taxAmount.value > 0)
                  _cardSection(
                    Strings.tax,
                    '${_smartPrice(bookController.taxAmount.value)} ${_cur(bookController.selectedPricing.value?.currency)}',
                  ),
                _cardSection(
                  Strings.totalPayable,
                  '${_smartPrice(bookController.total.value)} ${_cur(bookController.selectedPricing.value?.currency)}',
                ),
              ],
              );
            },
          ),
        ),
      ],
    );
  }

  _cardSection(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.verticalSize * 0.25,
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextWidget(
              title,
              fontSize: Dimensions.titleSmall,
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 12),
          Flexible(
            flex: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(Get.context!).size.width * 0.45),
              child: TextWidget(
                value,
                fontWeight: FontWeight.w500,
                color: CustomColor.primary,
                fontSize: Dimensions.titleSmall,
                maxLines: 2,
                textOverflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
