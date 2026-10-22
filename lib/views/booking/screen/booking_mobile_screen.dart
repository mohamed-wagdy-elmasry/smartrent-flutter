part of 'booking_screen.dart';

// ── Design tokens (screen-local) ─────────────────────────────────────────────
class _BC {
  static const Color primary      = Color(0xFF0B5FA5);
  static const Color primaryLight = Color(0xFF1A8CFF);
  static const Color surface      = Color(0xFFF4F7FB);
  static const Color cardBg       = Color(0xFFFFFFFF);
}

class _BR {
  static const double card   = 20.0;
  static const double button = 16.0;
  static const double chip   = 10.0;
}

class _BS {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
}
// ─────────────────────────────────────────────────────────────────────────────

class BookingMobileScreen extends GetView<BookingController> {
  const BookingMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: _BC.surface,
      body: Column(
        children: [
          _buildHeader(context, topPad),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(_BS.md, _BS.md, _BS.md, _BS.md),
              physics: const BouncingScrollPhysics(),
              children: [
                BookingAllFields(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ── Unified hero header ────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, double topPad) {
    return Obx(() {
      final car = controller.selectedCar.value;
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A4D8C), _BC.primary, _BC.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
        ),
        child: Stack(
          children: [
            // ── Decorative circles ───────────────────────────────────────────
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 40,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            Positioned(
              top: 60,
              left: -20,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.04),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(_BS.md, topPad + _BS.sm, _BS.md, _BS.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top row: back + title
                  Row(
                    children: [
                      _backButton(context),
                      const SizedBox(width: _BS.sm),
                      Expanded(
                        child: Text(
                          DynamicLanguage.key(Strings.bookYorCar),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      // Balance the back button so the title stays centered
                      const SizedBox(width: 38),
                    ],
                  ),

                  if (car != null) ...[
                    const SizedBox(height: _BS.lg),
                    // ── Car info row ─────────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(_BS.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(_BR.card),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.22), width: 1),
                      ),
                      child: Row(
                        children: [
                          // Car image
                          _carImage(car),
                          const SizedBox(width: _BS.md),
                          // Car details
                          Expanded(child: _carDetails(car)),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: _BS.sm),
                    // Subtitle when no car selected
                    Text(
                      'Fill in your details below',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _backButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _carImage(VendorCar car) {
    final imgUrl = car.modelImage ??
        (car.images.isNotEmpty ? car.images.first.url : null);
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: imgUrl != null && imgUrl.isNotEmpty
          ? Image.network(
              imgUrl,
              width: 80,
              height: 64,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _carPlaceholder(),
            )
          : _carPlaceholder(),
    );
  }

  Widget _carPlaceholder() => Container(
        width: 80,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.directions_car_rounded,
            color: Colors.white70, size: 32),
      );

  Widget _carDetails(VendorCar car) {
    final pricing = controller.selectedPricing.value;
    final price = pricing?.price ?? 0;
    final currency = pricing?.currency ?? 'SAR';
    final unit = controller.pricingUnit.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${car.make} ${car.model}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: _BS.xs),
        if (car.year > 0)
          Text(
            car.year.toString(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.65),
              fontSize: 12,
            ),
          ),
        const SizedBox(height: _BS.xs),
        // Price chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(_BR.chip),
          ),
          child: Text(
            '$price $currency${unit.isNotEmpty ? ' / $unit' : ''}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom bar ─────────────────────────────────────────────────────────────
  Widget _buildBottomBar() {
    return Obx(() {
      final disabled = !controller.isFormValid.value;
      return Container(
        padding: const EdgeInsets.fromLTRB(_BS.md, _BS.sm, _BS.md, _BS.lg),
        decoration: BoxDecoration(
          color: _BC.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: disabled
                ? null
                : () {
                    Get.toNamed(Routes.previewScreen,
                        arguments: controller.getBookingData());
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: _BC.primary,
              disabledBackgroundColor: const Color(0xFFBDBDBD),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white70,
              elevation: disabled ? 0 : 4,
              shadowColor: _BC.primary.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(_BR.button),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DynamicLanguage.key(Strings.continuee),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                if (!disabled) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
