import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/base/localization/dynamic_language_shim.dart';
import 'package:carbo/base/widgets/app_cached_image.dart';
import 'package:carbo/base/services/location_service.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:carbo/routes/routes.dart';
import 'package:carbo/views/common/html_screen.dart';
import '../controller/vendor_cars_controller.dart';

// Widget parts
part '../widget/vendor_car_card.dart';
part '../widget/vendor_cars_skeleton.dart';
part '../widget/vendor_cars_empty_state.dart';
part '../widget/vendor_cars_error_state.dart';
part '../widget/vendor_cars_filter_chips.dart';
part '../widget/vendor_cars_sort_dropdown.dart';
part '../widget/vendor_cars_header.dart';
part '../widget/vendor_cars_guest_drawer.dart';
part '../widget/vendor_cars_brand_filter.dart';
part '../widget/vendor_cars_city_filter.dart';
part '../widget/vendor_cars_filter_sheet.dart';

/// Main screen for displaying vendor cars with filtering and booking
class VendorCarsScreen extends GetView<VendorCarsController> {
  const VendorCarsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColor.background,
      drawer: const VendorCarsGuestDrawer(),
      body: Stack(
        children: [
          _buildBody(context),
          _buildVcFilterFab(context),
        ],
      ),
    );
  }

  // ─────────────────────────── Filter FAB ──────────────────
  Widget _buildVcFilterFab(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: bottomInset + 24,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() {
          final hasActive = controller.selectedBrand.value != 'all' ||
              controller.selectedCity.value != 'all';
          final count = (controller.selectedBrand.value != 'all' ? 1 : 0) +
              (controller.selectedCity.value != 'all' ? 1 : 0);

          return GestureDetector(
            onTap: () => _showVcFilterSheet(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: hasActive
                          ? [
                              CustomColor.primary,
                              CustomColor.primary.withOpacity(0.8),
                            ]
                          : [Colors.white, Colors.white],
                    ),
                    border: hasActive
                        ? null
                        : Border.all(
                            color: const Color(0xFFE5E7EB), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: hasActive
                            ? CustomColor.primary.withOpacity(0.35)
                            : Colors.black.withOpacity(0.12),
                        blurRadius: hasActive ? 24 : 16,
                        spreadRadius: hasActive ? 2 : 0,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    size: 28,
                    color: hasActive ? Colors.white : CustomColor.primary,
                  ),
                ),
                if (hasActive)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: CustomColor.primary, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: CustomColor.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _showVcFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _VendorCarsFilterSheet(controller: controller),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 120,
      backgroundColor: CustomColor.whiteColor,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.08),
      elevation: 2,
      leading: Builder(
        builder: (ctx) => _AppBarIconButton(
          icon: Icons.menu_rounded,
          onTap: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      actions: [
        Obx(() => controller.isRefreshing
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CustomColor.primary,
                  ),
                ),
              )
            : _AppBarIconButton(
                icon: Icons.refresh_rounded,
                onTap: controller.refreshCars,
                color: CustomColor.primary,
              )),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsetsDirectional.only(
          start: 56,
          bottom: 14,
          end: 60,
        ),
        centerTitle: false,
        expandedTitleScale: 1.4,
        title: Obx(() => Text(
          controller.vendorName.value.isNotEmpty
              ? controller.vendorName.value
              : DynamicLanguage.key(Strings.availableCars),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: CustomColor.typography,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        )),
        background: Container(
          color: CustomColor.whiteColor,
          child: Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 56,
                bottom: 14,
              ),
              child: Obx(() => Text(
                '${controller.pagination.value?.total ?? controller.vendorCars.length}'
                ' ${DynamicLanguage.key(Strings.carsAvailable)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: CustomColor.typography.withOpacity(0.5),
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Obx(() {
      // Loading state
      if (controller.isLoading && controller.vendorCars.isEmpty) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),
            const SliverFillRemaining(child: VendorCarsSkeletonLoader()),
          ],
        );
      }

      // Error state
      if (controller.hasError && controller.vendorCars.isEmpty) {
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),
            SliverFillRemaining(
              child: VendorCarsErrorState(
                message: controller.errorMessage.value,
                onRetry: () => controller.fetchVendorCars(),
              ),
            ),
          ],
        );
      }

      // Empty state
      if (controller.vendorCars.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshCars,
          color: CustomColor.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              const SliverFillRemaining(child: VendorCarsEmptyState()),
            ],
          ),
        );
      }

      // Main content
      return RefreshIndicator(
        onRefresh: controller.refreshCars,
        color: CustomColor.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),

            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize),
            ),

            // Header with count and sort
            const SliverToBoxAdapter(child: VendorCarsHeader()),

            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 0.75),
            ),

            // Location permission banner
            if (controller.locationPermissionDenied.value)
              SliverToBoxAdapter(
                child: _buildLocationPermissionBanner(context),
              ),

            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 0.5),
            ),

            // Quick filter chips
            const SliverToBoxAdapter(child: VendorCarsFilterChips()),

            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 0.75),
            ),

            // Car cards list
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index == controller.vendorCars.length) {
                    return _buildLoadMoreButton();
                  }
                  final car = controller.vendorCars[index];
                  return Obx(
                    () => _buildShimmerWrapper(
                      isLoading: controller.isCheckingDelivery.value,
                      child: VendorCarCard(
                        car: car,
                        onBookNow: () => controller.onBookNowTap(car),
                      ),
                    ),
                  );
                },
                childCount:
                    controller.vendorCars.length +
                    (controller.hasMore.value ? 1 : 0),
              ),
            ),

            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: Dimensions.verticalSize * 3),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLoadMoreButton() {
    return Obx(
      () => controller.isLoadingMore
          ? Padding(
              padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
              child: Center(
                child: CircularProgressIndicator(color: CustomColor.primary),
              ),
            )
          : Padding(
              padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
              child: Center(
                child: OutlinedButton.icon(
                  onPressed: () => controller.fetchVendorCars(loadMore: true),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    DynamicLanguage.key(Strings.loadMore),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomColor.primary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    side: BorderSide(color: CustomColor.primary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildLocationPermissionBanner(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: Container(
        padding: EdgeInsets.all(Dimensions.defaultHorizontalSize),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 20,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DynamicLanguage.key(Strings.LocationPermissionDenied),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DynamicLanguage.key(Strings.OpenSettings),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () async {
                final locationService = Get.find<LocationService>();
                await locationService.openAppSettings();
                await controller.retryDeliveryCheck();
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                DynamicLanguage.key(Strings.OpenSettings),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerWrapper({
    required bool isLoading,
    required Widget child,
  }) {
    if (!isLoading) return child;

    return Stack(
      children: [
        Opacity(opacity: 0.5, child: child),
        Positioned.fill(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultHorizontalSize,
                vertical: Dimensions.verticalSize * 0.5,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F6F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color ?? CustomColor.typography,
          ),
        ),
      ),
    );
  }
}
