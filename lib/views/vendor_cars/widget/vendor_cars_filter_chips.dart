part of '../screen/vendor_cars_screen.dart';

/// Filter chips widget for quick filtering
class VendorCarsFilterChips extends GetView<VendorCarsController> {
  const VendorCarsFilterChips({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildFilterChip('all', Strings.allCars, Icons.apps_rounded),
            _buildFilterChip('available', Strings.available, Icons.check_circle),
            if (!controller.locationPermissionDenied.value)
              _buildDeliveryFilterChip(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String labelKey, IconData icon) {
    final isSelected = controller.quickFilter.value == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 6),
          Text(
            DynamicLanguage.key(labelKey),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
      onSelected: (_) => controller.changeQuickFilter(value),
      selectedColor: CustomColor.primary,
      backgroundColor: const Color(0xFFF3F4F6),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF1F2937),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? CustomColor.primary : const Color(0xFFE5E7EB),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildDeliveryFilterChip() {
    final isSelected = controller.quickFilter.value == 'deliveryAvailable';
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping_rounded,
            size: 14,
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 6),
          Text(
            DynamicLanguage.key(Strings.deliveryCar),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
      onSelected: (_) => controller.changeQuickFilter('deliveryAvailable'),
      selectedColor: CustomColor.primary,
      backgroundColor: const Color(0xFFF3F4F6),
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : const Color(0xFF1F2937),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: isSelected ? CustomColor.primary : const Color(0xFFE5E7EB),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
