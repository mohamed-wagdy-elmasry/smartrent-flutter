part of '../screen/vendor_cars_screen.dart';

/// Header widget showing car count and sort options
class VendorCarsHeader extends GetView<VendorCarsController> {
  const VendorCarsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.directions_car_rounded,
                    size: 18,
                    color: CustomColor.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => Text(
                        '${controller.pagination.value?.total ?? controller.vendorCars.length} ${DynamicLanguage.key(Strings.carsAvailable)}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          const VendorCarsSortDropdown(),
        ],
      ),
    );
  }
}
