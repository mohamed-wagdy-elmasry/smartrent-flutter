part of '../screen/vendor_cars_screen.dart';

/// Car card widget for displaying individual car information
class VendorCarCard extends GetView<VendorCarsController> {
  final VendorCar car;
  final VoidCallback? onTap;
  final VoidCallback? onBookNow;

  const VendorCarCard({
    Key? key,
    required this.car,
    this.onTap,
    this.onBookNow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
          vertical: Dimensions.verticalSize * 0.5,
        ),
        decoration: BoxDecoration(
          color: CustomColor.whiteColor,
          borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap ?? () => onBookNow?.call(),
          borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageSection(context),
              _buildDetailsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width -
        (Dimensions.defaultHorizontalSize * 2);
    final imageHeight = screenWidth * 3 / 4;

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(Dimensions.radius * 1.2),
        topRight: Radius.circular(Dimensions.radius * 1.2),
      ),
      child: Stack(
        children: [
          // Car image
          AppCachedImage(
            imageUrl: car.modelImage?.trim() ?? '',
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(Dimensions.radius * 1.2),
              topRight: Radius.circular(Dimensions.radius * 1.2),
            ),
            useShimmer: true,
            fadeIn: true,
          ),

          // Gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5],
                ),
              ),
            ),
          ),

          // Availability badge
          Positioned(
            top: Dimensions.verticalSize * 0.75,
            right: Dimensions.horizontalSize * 0.75,
            child: _buildAvailabilityBadge(),
          ),

          // Delivery badge
          if (controller.isDeliveryAvailable(car))
            Positioned(
              top: Dimensions.verticalSize * 0.75,
              left: Dimensions.horizontalSize * 0.75,
              child: _buildDeliveryBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityBadge() {
    final isAvailable = car.isAvailable;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSize * 0.7,
        vertical: Dimensions.verticalSize * 0.35,
      ),
      decoration: BoxDecoration(
        color: isAvailable ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.6),
        boxShadow: [
          BoxShadow(
            color: (isAvailable
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B))
                .withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        isAvailable
            ? DynamicLanguage.key(Strings.available)
            : DynamicLanguage.key(Strings.limited),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildDeliveryBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSize * 0.7,
        vertical: Dimensions.verticalSize * 0.35,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(Dimensions.radius * 0.6),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_shipping_rounded,
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            DynamicLanguage.key(Strings.deliveryCar),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car name and year
          _buildNameAndYear(),
          SizedBox(height: Dimensions.verticalSize * 0.4),

          // Vendor info
          _buildVendorInfo(),
          SizedBox(height: Dimensions.verticalSize * 0.6),

          // Features chips
          if (car.features.isNotEmpty) ...[
            _buildFeatureChips(),
            SizedBox(height: Dimensions.verticalSize * 0.8),
          ],

          // Price and book button
          _buildPriceAndBookButton(context),
        ],
      ),
    );
  }

  Widget _buildNameAndYear() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            car.displayName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: Dimensions.horizontalSize * 0.6),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.horizontalSize * 0.6,
            vertical: Dimensions.verticalSize * 0.3,
          ),
          decoration: BoxDecoration(
            color: CustomColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: CustomColor.primary.withOpacity(0.12),
            ),
          ),
          child: Text(
            '${car.year}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: CustomColor.primary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVendorInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.store_rounded,
            size: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        SizedBox(width: Dimensions.horizontalSize * 0.5),
        Expanded(
          child: Text(
            car.vendorName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: car.features.take(3).map((feature) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: const Color(0xFFDBEAFE),
            ),
          ),
          child: Text(
            feature,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF1E40AF),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceAndBookButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Price
        Expanded(
          child: Text(
            controller.formatPrice(car),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: CustomColor.primary,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildBookButton(context),
      ],
    );
  }

  Widget _buildBookButton(BuildContext context) {
    final isLoggedIn = LocalStorage.isLoggedIn;

    return ElevatedButton(
      onPressed: onBookNow ?? () => controller.onBookNowTap(car),
      style: ElevatedButton.styleFrom(
        backgroundColor: isLoggedIn
            ? CustomColor.primary
            : CustomColor.primary.withOpacity(0.7),
        foregroundColor: CustomColor.whiteColor,
        elevation: 0,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.horizontalSize * 0.9,
          vertical: Dimensions.verticalSize * 0.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLoggedIn) ...[
            const Icon(Icons.lock_outline, size: 14),
            const SizedBox(width: 4),
          ],
          Text(
            DynamicLanguage.key(Strings.bookNow),
            style: TextStyle(
              color: CustomColor.whiteColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
