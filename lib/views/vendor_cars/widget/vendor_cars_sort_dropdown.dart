part of '../screen/vendor_cars_screen.dart';

/// Sort dropdown widget for vendor cars
class VendorCarsSortDropdown extends GetView<VendorCarsController> {
  const VendorCarsSortDropdown({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: controller.changeSortOption,
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: CustomColor.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: CustomColor.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort_rounded,
              size: 18,
              color: CustomColor.primary,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: CustomColor.primary,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem('popularity', Strings.popularity, Icons.trending_up),
        _buildMenuItem(
          'priceLowToHigh',
          Strings.priceLowToHigh,
          Icons.arrow_upward,
        ),
        _buildMenuItem(
          'priceHighToLow',
          Strings.priceHighToLow,
          Icons.arrow_downward,
        ),
        _buildMenuItem('rating', Strings.rating, Icons.star_rounded),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    String labelKey,
    IconData icon,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Obx(
        () => Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF6B7280)),
            const SizedBox(width: 12),
            Text(
              DynamicLanguage.key(labelKey),
              style: TextStyle(
                fontSize: 14,
                fontWeight: controller.sortOption.value == value
                    ? FontWeight.w600
                    : FontWeight.w500,
                color: controller.sortOption.value == value
                    ? CustomColor.primary
                    : const Color(0xFF1F2937),
              ),
            ),
            if (controller.sortOption.value == value) ...[
              const Spacer(),
              Icon(Icons.check, size: 18, color: CustomColor.primary),
            ],
          ],
        ),
      ),
    );
  }
}
