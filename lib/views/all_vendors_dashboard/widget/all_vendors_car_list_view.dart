part of '../screen/all_vendors_dashboard_screen.dart';

// ────────────────────────────────────────────────────────────────
// Design Tokens (screen-local)
// ────────────────────────────────────────────────────────────────
class _C {
  static const Color surface = Color(0xFFF7F8FA);
  static const Color card = Colors.white;
  static const Color headerStart = Color(0xFF0A2540);
  static const Color headerMid = Color(0xFF0B5FA5);
  static const Color headerEnd = Color(0xFF1A7FD4);
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color border = Color(0xFFE5E7EB);
  static const Color chipBg = Color(0xFFF3F4F6);
  static const Color greenBadge = Color(0xFF10B981);
  static const Color amberBadge = Color(0xFFF59E0B);
  static const Color blueBadge = Color(0xFF3B82F6);
  static const Color purpleBadge = Color(0xFF8B5CF6);
}

class _S {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

class _R {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
}

// ────────────────────────────────────────────────────────────────
// All Vendors Car List — Premium Redesign
// ────────────────────────────────────────────────────────────────
class AllVendorsCarListView extends GetView<AllVendorsDashboardController> {
  const AllVendorsCarListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          if (controller.isSearchingCar && controller.vendorCars.isEmpty) {
            return _buildSkeletonLoading(context);
          }
          if (controller.vendorCars.isEmpty) {
            return _buildEmptyState(context);
          }
          return RefreshIndicator(
        onRefresh: controller.refreshCars,
        color: CustomColor.primary,
        backgroundColor: Colors.white,
        displacement: 60,
        child: CustomScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Animated sliver header
              _buildSliverHeader(context),

              // Filter bar
              SliverToBoxAdapter(child: _buildFilterBar(context)),



              // Location banner
              if (controller.locationPermissionDenied.value)
                SliverToBoxAdapter(child: _buildLocationBanner(context)),

              // Car cards
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _S.base,
                  vertical: _S.sm,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == controller.vendorCars.length) {
                        return _buildLoadMore();
                      }
                      final car = controller.vendorCars[index];
                      return _PremiumCarCard(
                        car: car,
                        onTap: () => _onCarTap(car),
                      );
                    },
                    childCount: controller.vendorCars.length +
                        (controller.hasMore.value ? 1 : 0),
                  ),
                ),
              ),

              // Bottom safe area — extra room for FAB
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).padding.bottom + 96,
                ),
              ),
            ],
          ),
      );
        }),
        _buildFilterFab(context),
      ],
    );
  }

  // ─────────────────────────── Animated SliverAppBar ────────
  Widget _buildSliverHeader(BuildContext context) {
    final dashCtrl = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());
    final isLoggedIn = LocalStorage.isLoggedIn;

    return SliverAppBar(
      expandedHeight: isLoggedIn ? 148 : 80,
      pinned: true,
      stretch: false,
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _C.headerStart,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final statusBar = MediaQuery.of(context).padding.top;
          final expandedH = (isLoggedIn ? 148.0 : 80.0) + statusBar;
          final collapsedH = kToolbarHeight + statusBar;
          final t = ((constraints.maxHeight - collapsedH) /
                  (expandedH - collapsedH))
              .clamp(0.0, 1.0);

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_C.headerStart, _C.headerMid, _C.headerEnd],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // ── Pinned top bar ──────────────────────────────
                  SizedBox(
                    height: kToolbarHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _S.base),
                      child: Row(
                        children: [
                          // Menu button
                          Builder(
                            builder: (ctx) => _HeaderIconButton(
                              onTap: () => Scaffold.of(ctx).openDrawer(),
                              child: const Icon(
                                Icons.menu_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Profile avatar or Login button
                          if (isLoggedIn)
                            _buildProfileAvatar(dashCtrl)
                          else
                            _HeaderLoginButton(),
                        ],
                      ),
                    ),
                  ),

                  // ── Greeting — fills remaining expanded space, fades on scroll ──
                  if (isLoggedIn)
                    Expanded(
                      child: ClipRect(
                        child: Opacity(
                          opacity: t,
                          child: Transform.translate(
                            offset: Offset(0, 10 * (1 - t)),
                            child: OverflowBox(
                              maxHeight: double.infinity,
                              alignment: AlignmentDirectional.bottomStart,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    _S.base, 0, _S.base, _S.base),
                                child: Obx(() {
                                  final name = dashCtrl.userFullName.value;
                                  final greeting = _getGreeting();
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              greeting,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white
                                                    .withOpacity(0.75),
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            if (name.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                name,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: -0.2,
                                                  height: 1.2,
                                                ),
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      // Car count badge
                                      Obx(() {
                                        final count =
                                            controller.vendorCars.length;
                                        if (count == 0) {
                                          return const SizedBox.shrink();
                                        }
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.18),
                                            borderRadius:
                                                BorderRadius.circular(_R.xl),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.25),
                                            ),
                                          ),
                                          child: Text(
                                            '$count ${DynamicLanguage.key(Strings.carsAvailable)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAvatar(DashboardController dashCtrl) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.update_profileScreen),
      child: Obx(() {
        final profileUrl = dashCtrl.userProfileImage.value;
        final defaultUrl = dashCtrl.userDefaultImageUrl.value;

        bool isValid(String url) =>
            url.isNotEmpty &&
            (url.startsWith('http://') || url.startsWith('https://'));

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
            color: Colors.white.withOpacity(0.15),
          ),
          child: ClipOval(
            child: isValid(profileUrl)
                ? AppCachedImage(
                    imageUrl: profileUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    shape: BoxShape.circle,
                    useShimmer: true,
                    errorWidget: _fallbackAvatar(defaultUrl),
                  )
                : _fallbackAvatar(defaultUrl),
          ),
        );
      }),
    );
  }

  Widget _fallbackAvatar(String url) {
    if (url.isNotEmpty &&
        (url.startsWith('http://') || url.startsWith('https://'))) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: 40,
        height: 40,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.person_rounded,
          color: Colors.white70,
          size: 22,
        ),
      );
    }
    return const Icon(Icons.person_rounded, color: Colors.white70, size: 22);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // ─────────────────────────── Compact Filter Bar ──────────
  Widget _buildFilterBar(BuildContext context) {
    return Obx(() {
      final filter = controller.quickFilter.value;
      final sort = controller.sortOption.value;
      final brand = controller.selectedBrand.value;
      final city = controller.selectedCity.value;

      final filterLabel = switch (filter) {
        'available' => DynamicLanguage.key(Strings.available),
        'deliveryAvailable' => DynamicLanguage.key(Strings.deliveryCar),
        _ => DynamicLanguage.key(Strings.allCars),
      };

      final sortLabel = switch (sort) {
        'priceLowToHigh' => DynamicLanguage.key(Strings.priceLowToHigh),
        'priceHighToLow' => DynamicLanguage.key(Strings.priceHighToLow),
        'rating' => DynamicLanguage.key(Strings.rating),
        _ => DynamicLanguage.key(Strings.popularity),
      };

      return Container(
        color: _C.surface,
        padding: const EdgeInsets.symmetric(
            horizontal: _S.base, vertical: _S.sm),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              if (filter != 'all')
                _ActiveChip(
                  label: filterLabel,
                  onRemove: () => controller.changeQuickFilter('all'),
                )
              else
                _ActiveChip(
                  label: filterLabel,
                  isDefault: true,
                ),
              const SizedBox(width: _S.xs),
              _ActiveChip(
                label: sortLabel,
                icon: Icons.swap_vert_rounded,
                isDefault: sort == 'popularity',
                onRemove: sort != 'popularity'
                    ? () => controller.changeSortOption('popularity')
                    : null,
              ),
              if (brand != 'all') ...[
                const SizedBox(width: _S.xs),
                _ActiveChip(
                  label: brand,
                  icon: Icons.directions_car_outlined,
                  onRemove: () => controller.changeBrandFilter('all'),
                ),
              ],
              if (city != 'all') ...[
                const SizedBox(width: _S.xs),
                _ActiveChip(
                  label: city,
                  icon: Icons.location_city_outlined,
                  onRemove: () => controller.changeCityFilter('all'),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────── Filter FAB ──────────────────
  Widget _buildFilterFab(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: bottomInset + _S.xl,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() {
          final hasActive =
              controller.quickFilter.value != 'all' ||
              controller.sortOption.value != 'popularity' ||
              controller.selectedBrand.value != 'all' ||
              controller.selectedCity.value != 'all';
          final count =
              (controller.quickFilter.value != 'all' ? 1 : 0) +
              (controller.sortOption.value != 'popularity' ? 1 : 0) +
              (controller.selectedBrand.value != 'all' ? 1 : 0) +
              (controller.selectedCity.value != 'all' ? 1 : 0);

          return GestureDetector(
            onTap: () => _showFilterSheet(context),
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
                          ? [_C.headerStart, _C.headerEnd]
                          : [
                              Colors.white,
                              Colors.white,
                            ],
                    ),
                    border: hasActive
                        ? null
                        : Border.all(color: _C.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: hasActive
                            ? _C.headerStart.withOpacity(0.35)
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
                            color: _C.headerStart, width: 2),
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
                            color: _C.headerStart,
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(controller: controller),
    );
  }

  // ─────────────────────────── Location Banner ──────────────
  Widget _buildLocationBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_S.base, _S.xs, _S.base, _S.sm),
      child: Container(
        padding: const EdgeInsets.all(_S.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
          ),
          borderRadius: BorderRadius.circular(_R.md),
          border: Border.all(color: _C.amberBadge.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _C.amberBadge.withOpacity(0.15),
                borderRadius: BorderRadius.circular(_R.sm),
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 20,
                color: Color(0xFFD97706),
              ),
            ),
            const SizedBox(width: _S.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location Access Needed',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF92400E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Enable to see delivery options',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final locationService = Get.find<LocationService>();
                await locationService.openAppSettings();
                await controller.retryDeliveryCheck();
              },
              style: TextButton.styleFrom(
                backgroundColor: _C.amberBadge,
                padding:
                    const EdgeInsets.symmetric(horizontal: _S.md, vertical: _S.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_R.sm),
                ),
              ),
              child: const Text(
                'Enable',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────── Load More ────────────────────
  Widget _buildLoadMore() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(vertical: _S.xl),
        child: Center(
          child: controller.isLoadingMore
              ? SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: CustomColor.primary,
                    strokeWidth: 2.5,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  // ─────────────────────────── Skeleton ──────────────────────
  Widget _buildSkeletonLoading(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        _buildSliverHeader(context),
        SliverToBoxAdapter(child: _buildFilterBar(context)),
        SliverPadding(
          padding:
              const EdgeInsets.symmetric(horizontal: _S.base, vertical: _S.sm),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => const _SkeletonCard(),
              childCount: 3,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────── Empty State ──────────────────
  Widget _buildEmptyState(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshCars,
      color: CustomColor.primary,
      backgroundColor: Colors.white,
      displacement: 60,
      child: CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      slivers: [
        _buildSliverHeader(context),
        SliverToBoxAdapter(child: _buildFilterBar(context)),
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(_S.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: _C.chipBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 48,
                      color: _C.textTertiary,
                    ),
                  ),
                  const SizedBox(height: _S.xl),
                  Text(
                    DynamicLanguage.key(Strings.noCarsFound),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: _S.sm),
                  Text(
                    DynamicLanguage.key(Strings.tryDifferentFilters),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _C.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
    );
  }

  // ─────────────────────────── Helpers ──────────────────────
  void _onCarTap(VendorCar car) {
    if (!LocalStorage.isLoggedIn) {
      Get.toNamed(Routes.otpLoginScreen);
      return;
    }
    controller.selectedCarId.value = car.id.toString();
    try {
      final bookingController = Get.find<BookingController>();
      bookingController.initializeWithCar(car);
    } catch (_) {}
    Get.toNamed(Routes.bookingScreen, arguments: {'car': car});
  }

}

// ════════════════════════════════════════════════════════════════
// Header Helper Widgets
// ════════════════════════════════════════════════════════════════
class _HeaderIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(_R.md),
        ),
        child: child,
      ),
    );
  }
}

class _HeaderLoginButton extends StatelessWidget {
  const _HeaderLoginButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.otpLoginScreen),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_R.xl),
        ),
        alignment: Alignment.center,
        child: Text(
          DynamicLanguage.key(Strings.login),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _C.headerMid,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Premium Car Card Widget
// ════════════════════════════════════════════════════════════════
class _PremiumCarCard extends StatelessWidget {
  final VendorCar car;
  final VoidCallback onTap;

  const _PremiumCarCard({
    required this.car,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: _S.md),
        decoration: BoxDecoration(
          color: _C.card,
          borderRadius: BorderRadius.circular(_R.xl),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(_S.base, _S.md, _S.base, _S.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameRow(),
                  const SizedBox(height: _S.sm),
                  _buildVendorRow(),
                  if (car.features.isNotEmpty) ...[
                    const SizedBox(height: _S.md),
                    _buildFeatures(),
                  ],
                  const SizedBox(height: _S.md),
                  Container(height: 1, color: _C.border.withOpacity(0.6)),
                  const SizedBox(height: _S.sm),
                  _buildStatusBadgeRow(),
                  const SizedBox(height: _S.sm),
                  Container(height: 1, color: _C.border.withOpacity(0.6)),
                  const SizedBox(height: _S.md),
                  _buildPriceAndCTA(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    final imageUrl = car.modelImage?.trim() ?? '';
    final screenWidth = MediaQuery.of(context).size.width - (_S.base * 2);
    final imageHeight = screenWidth * 0.56;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(_R.xl),
        topRight: Radius.circular(_R.xl),
      ),
      child: Stack(
        children: [
          AppCachedImage(
            imageUrl: imageUrl,
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(_R.xl),
              topRight: Radius.circular(_R.xl),
            ),
            useShimmer: true,
            fadeIn: true,
          ),
          // Top gradient for badge visibility
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withOpacity(0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom gradient for smooth transition
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 40,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    _C.card.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Branch badge
          if (car.vendorLocation?.city != null)
            Positioned(
              top: _S.md,
              left: _S.md,
              child: _Badge(
                label: car.vendorLocation!.city!,
                color: _C.purpleBadge,
                icon: Icons.location_on_rounded,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNameRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            car.displayName,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: _C.textPrimary,
              letterSpacing: -0.3,
              height: 1.25,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: _S.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: _S.sm,
            vertical: _S.xs,
          ),
          decoration: BoxDecoration(
            color: CustomColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(_R.sm),
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

  Widget _buildVendorRow() {
    return Row(
      children: [
        const Icon(Icons.storefront_rounded, size: 14, color: _C.textTertiary),
        const SizedBox(width: _S.xs),
        Expanded(
          child: Text(
            car.vendorName,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _C.textSecondary,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatures() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: car.features.take(3).map((feature) {
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: _S.sm, vertical: _S.xs),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Text(
            feature,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E40AF),
              height: 1.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadgeRow() {
    return Row(
      children: [
        if (Get.find<AllVendorsDashboardController>().isDeliveryAvailable(car)) ...[
          _Badge(
            label: DynamicLanguage.key(Strings.deliveryCar),
            color: _C.blueBadge,
            icon: Icons.local_shipping_rounded,
          ),
          const SizedBox(width: _S.sm),
        ],
        _Badge(
          label: car.isAvailable
              ? DynamicLanguage.key(Strings.available)
              : DynamicLanguage.key(Strings.limited),
          color: car.isAvailable ? _C.greenBadge : _C.amberBadge,
          icon: car.isAvailable
              ? Icons.check_circle_rounded
              : Icons.schedule_rounded,
        ),
      ],
    );
  }

  Widget _buildPriceAndCTA() {
    final currencySymbols = {
      'SAR': 'ريال',
      'USD': '\$',
      'AED': 'د.إ',
      'EGP': '£',
      'KWD': 'د.ك',
    };
    final symbol = currencySymbols[car.currency] ?? car.currency;
    final unitText = car.pricing.unit == 'day'
        ? DynamicLanguage.key(Strings.Day)
        : car.pricing.unit;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$symbol ${car.pricing.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CustomColor.primary,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '/ $unitText',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _C.textTertiary,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_R.md),
            gradient: LinearGradient(
              colors: [
                CustomColor.primary,
                CustomColor.primary.withOpacity(0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: CustomColor.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(_R.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _S.lg,
                  vertical: _S.md,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DynamicLanguage.key(Strings.bookNow),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: _S.xs),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Supporting Widgets
// ════════════════════════════════════════════════════════════════
// ════════════════════════════════════════════════════════════════
// Active Chip (filter bar preview)
// ════════════════════════════════════════════════════════════════
class _ActiveChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isDefault;
  final VoidCallback? onRemove;

  const _ActiveChip({
    required this.label,
    this.icon,
    this.isDefault = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 32,
      padding: EdgeInsets.only(
        left: _S.sm + 2,
        right: onRemove != null ? _S.xs : _S.sm + 2,
      ),
      decoration: BoxDecoration(
        color: isDefault ? Colors.white : CustomColor.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(_R.xl),
        border: Border.all(
          color: isDefault ? _C.border : CustomColor.primary.withOpacity(0.3),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 13,
              color: isDefault ? _C.textSecondary : CustomColor.primary,
            ),
            const SizedBox(width: _S.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDefault ? _C.textSecondary : CustomColor.primary,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 2),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close_rounded,
                size: 14,
                color: CustomColor.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: _S.sm + 2,
        vertical: _S.xs + 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(_R.sm),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: _S.xs),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: _S.md),
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(_R.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: (MediaQuery.of(context).size.width - _S.base * 2) * 0.56,
            decoration: const BoxDecoration(
              color: _C.chipBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(_R.xl),
                topRight: Radius.circular(_R.xl),
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.directions_car_rounded,
                size: 48,
                color: _C.border,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_S.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 18,
                  width: 160,
                  decoration: BoxDecoration(
                    color: _C.chipBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: _S.md),
                Container(
                  height: 14,
                  width: 100,
                  decoration: BoxDecoration(
                    color: _C.chipBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: _S.base),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 22,
                      width: 80,
                      decoration: BoxDecoration(
                        color: _C.chipBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 40,
                      width: 100,
                      decoration: BoxDecoration(
                        color: _C.chipBg,
                        borderRadius: BorderRadius.circular(_R.md),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// Premium Filter Bottom Sheet
// ════════════════════════════════════════════════════════════════
class _FilterSheet extends StatefulWidget {
  final AllVendorsDashboardController controller;

  const _FilterSheet({required this.controller});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _selectedFilter;
  late String _selectedSort;
  late String _selectedBrand;
  late String _selectedCity;

  AllVendorsDashboardController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _selectedFilter = c.quickFilter.value;
    _selectedSort = c.sortOption.value;
    _selectedBrand = c.selectedBrand.value;
    _selectedCity = c.selectedCity.value;
  }

  void _applyFilters() {
    if (_selectedFilter != c.quickFilter.value) {
      c.changeQuickFilter(_selectedFilter);
    }
    if (_selectedSort != c.sortOption.value) {
      c.changeSortOption(_selectedSort);
    }
    if (_selectedBrand != c.selectedBrand.value) {
      c.changeBrandFilter(_selectedBrand);
    }
    if (_selectedCity != c.selectedCity.value) {
      c.changeCityFilter(_selectedCity);
    }
    Navigator.pop(context);
  }

  void _resetFilters() {
    setState(() {
      _selectedFilter = 'all';
      _selectedSort = 'popularity';
      _selectedBrand = 'all';
      _selectedCity = 'all';
    });
  }

  bool get _isModified =>
      _selectedFilter != 'all' || _selectedSort != 'popularity' ||
      _selectedBrand != 'all' || _selectedCity != 'all';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final brands = c.availableBrands;
    final cities = c.availableCities;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // ── Drag handle ──
          const SizedBox(height: _S.md),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _C.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: _S.base),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: _S.lg),
            child: Row(
              children: [
                Text(
                  DynamicLanguage.key(Strings.filterBy),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _C.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                if (_isModified)
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: _S.md, vertical: _S.xs),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(_R.xl),
                        border: Border.all(
                            color: const Color(0xFFFCA5A5), width: 1),
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: _S.sm),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: _C.chipBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: _C.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: _S.xl),
          const Divider(height: 1, color: _C.border),

          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: _S.xl),

                  // ── Section: Car Status ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _S.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel(Icons.filter_list_rounded, 'Car Status'),
                        const SizedBox(height: _S.md),
                        Row(
                          children: [
                            Expanded(
                              child: _OptionCard(
                                icon: Icons.apps_rounded,
                                label: DynamicLanguage.key(Strings.allCars),
                                isSelected: _selectedFilter == 'all',
                                onTap: () => setState(() => _selectedFilter = 'all'),
                              ),
                            ),
                            const SizedBox(width: _S.sm),
                            Expanded(
                              child: _OptionCard(
                                icon: Icons.check_circle_outline_rounded,
                                label: DynamicLanguage.key(Strings.available),
                                isSelected: _selectedFilter == 'available',
                                onTap: () =>
                                    setState(() => _selectedFilter = 'available'),
                              ),
                            ),
                            if (!c.locationPermissionDenied.value) ...[
                              const SizedBox(width: _S.sm),
                              Expanded(
                                child: _OptionCard(
                                  icon: Icons.local_shipping_outlined,
                                  label: DynamicLanguage.key(Strings.deliveryCar),
                                  isSelected: _selectedFilter == 'deliveryAvailable',
                                  onTap: () => setState(
                                      () => _selectedFilter = 'deliveryAvailable'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: _S.xl),

                  // ── Section: Sort By ──
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _S.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel(Icons.swap_vert_rounded,
                            DynamicLanguage.key(Strings.sortBy)),
                        const SizedBox(height: _S.md),
                        _SortOption(
                          icon: Icons.trending_up_rounded,
                          label: DynamicLanguage.key(Strings.popularity),
                          isSelected: _selectedSort == 'popularity',
                          onTap: () => setState(() => _selectedSort = 'popularity'),
                        ),
                        const SizedBox(height: _S.sm),
                        _SortOption(
                          icon: Icons.arrow_upward_rounded,
                          label: DynamicLanguage.key(Strings.priceLowToHigh),
                          isSelected: _selectedSort == 'priceLowToHigh',
                          onTap: () =>
                              setState(() => _selectedSort = 'priceLowToHigh'),
                        ),
                        const SizedBox(height: _S.sm),
                        _SortOption(
                          icon: Icons.arrow_downward_rounded,
                          label: DynamicLanguage.key(Strings.priceHighToLow),
                          isSelected: _selectedSort == 'priceHighToLow',
                          onTap: () =>
                              setState(() => _selectedSort = 'priceHighToLow'),
                        ),
                        const SizedBox(height: _S.sm),
                        _SortOption(
                          icon: Icons.star_rounded,
                          label: DynamicLanguage.key(Strings.rating),
                          isSelected: _selectedSort == 'rating',
                          onTap: () => setState(() => _selectedSort = 'rating'),
                        ),
                      ],
                    ),
                  ),

                  // ── Section: Brand ──
                  if (brands.isNotEmpty) ...[
                    const SizedBox(height: _S.xl),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _S.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel(Icons.directions_car_rounded, 'Brands'),
                          const SizedBox(height: _S.md),
                          Wrap(
                            spacing: _S.xs,
                            runSpacing: _S.xs,
                            children: [
                              _SheetChip(
                                label: 'All',
                                isSelected: _selectedBrand == 'all',
                                onTap: () => setState(() => _selectedBrand = 'all'),
                              ),
                              ...brands.map((b) => _SheetChip(
                                    label: b,
                                    isSelected: _selectedBrand == b,
                                    onTap: () => setState(() => _selectedBrand = b),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Section: City ──
                  if (cities.isNotEmpty) ...[
                    const SizedBox(height: _S.xl),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: _S.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel(Icons.location_city_rounded, 'Cities'),
                          const SizedBox(height: _S.md),
                          Wrap(
                            spacing: _S.xs,
                            runSpacing: _S.xs,
                            children: [
                              _SheetChip(
                                label: DynamicLanguage.key(Strings.allCities),
                                isSelected: _selectedCity == 'all',
                                onTap: () => setState(() => _selectedCity = 'all'),
                              ),
                              ...cities.map((city) => _SheetChip(
                                    label: city,
                                    isSelected: _selectedCity == city,
                                    onTap: () => setState(() => _selectedCity = city),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: _S.xl),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: _C.border),

          // ── Apply Button ──
          Padding(
            padding: EdgeInsets.fromLTRB(
                _S.lg, _S.base, _S.lg, _S.base + bottomInset),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_R.lg),
                  gradient: LinearGradient(
                    colors: [
                      CustomColor.primary,
                      CustomColor.primary.withOpacity(0.85),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: CustomColor.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _applyFilters,
                    borderRadius: BorderRadius.circular(_R.lg),
                    child: Center(
                      child: Text(
                        DynamicLanguage.key(Strings.showResults),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: CustomColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(_R.sm),
          ),
          child: Icon(icon, size: 17, color: CustomColor.primary),
        ),
        const SizedBox(width: _S.sm),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ── Option Card (status filter) ──────────────────────────────
class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: _S.md, horizontal: _S.sm),
        decoration: BoxDecoration(
          color: isSelected ? CustomColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(_R.md),
          border: Border.all(
            color: isSelected ? CustomColor.primary : _C.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CustomColor.primary.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : _C.textSecondary,
            ),
            const SizedBox(height: _S.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : _C.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sort Option Row ──────────────────────────────────────────
class _SortOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: _S.base, vertical: _S.md),
        decoration: BoxDecoration(
          color: isSelected ? CustomColor.primary.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(_R.md),
          border: Border.all(
            color: isSelected
                ? CustomColor.primary.withOpacity(0.35)
                : _C.border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? CustomColor.primary.withOpacity(0.12)
                    : _C.chipBg,
                borderRadius: BorderRadius.circular(_R.sm),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? CustomColor.primary : _C.textSecondary,
              ),
            ),
            const SizedBox(width: _S.md),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? CustomColor.primary : _C.textPrimary,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? CustomColor.primary : _C.border,
                  width: 2,
                ),
                color:
                    isSelected ? CustomColor.primary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter sheet pill chip (used inside _FilterSheet for brand/city) ─────────
class _SheetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SheetChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? CustomColor.primary : Colors.white,
          borderRadius: BorderRadius.circular(_R.xl),
          border: Border.all(
            color: isSelected ? CustomColor.primary : _C.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CustomColor.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _C.textPrimary,
          ),
        ),
      ),
    );
  }
}
