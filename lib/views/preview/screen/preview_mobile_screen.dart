part of 'preview_screen.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _C {
  static final Color bg      = const Color(0xFFF4F6FB);
  static final Color card    = Colors.white;
  static final Color primary = CustomColor.primary;
  static final Color accent  = CustomColor.secondary;
  static final Color textDark  = const Color(0xFF1A1A2E);
  static final Color textMuted = const Color(0xFF8A94A6);
  static final Color divider   = const Color(0xFFEEF0F5);
  static final Color success   = const Color(0xFF27AE60);
  static final Color warning   = const Color(0xFFF59F00);
  static final Color surfaceBlue   = const Color(0xFFEAF1FD);
  static final Color heroTop    = const Color(0x000B1E3A);
  static final Color heroBottom = const Color(0xDD0B1E3A);
}

class _S {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
}

class _Radii {
  static const double card  = 16;
  static const double large = 24;
  static const double chip  = 100;
}
// ─────────────────────────────────────────────────────────────────────────────

// ─── KM Allowance Formatter ───────────────────────────────────────────────────
String _formatKmAllowanceMessage(double? kmAllowance, double? kmOverageCharge, String Function(num) p) {
  final kmStr = p(kmAllowance ?? 0);
  final chargeStr = p(kmOverageCharge ?? 0);
  final appLocalizations = AppLocalizations.of(Get.context!);
  return appLocalizations?.appLKmAllowanceMessage(chargeStr, kmStr) ?? '';
}

class PreviewMobileScreen extends GetView<PreviewController> {
  const PreviewMobileScreen({super.key});

  // ── currency symbol ──────────────────────────────────────────────────────
  static String _cur(String? code) {
    switch (code?.toUpperCase()) {
      case 'SAR': return 'ر.س';
      case 'AED': return 'د.إ';
      case 'KWD': return 'د.ك';
      case 'USD': return '\$';
      case 'EUR': return '€';
      case 'GBP': return '£';
      default:    return code ?? '';
    }
  }

  // ── smart price (drops ".00") ────────────────────────────────────────────
  static String _p(num v) =>
      v == v.truncateToDouble() ? v.truncate().toString() : v.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final bookCtrl = Get.find<BookingController>();
    return Scaffold(
      backgroundColor: _C.bg,
      body: Obx(
        () => controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildScrollBody(context, bookCtrl),
      ),
      bottomNavigationBar: Obx(
        () => controller.isLoading
            ? const SizedBox.shrink()
            : _BottomBar(controller: controller, bookCtrl: bookCtrl, p: _p, cur: _cur),
      ),
    );
  }

  Widget _buildScrollBody(BuildContext context, BookingController bookCtrl) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildHeroAppBar(bookCtrl),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(_S.md, _S.md, _S.md, 120),
            child: Column(
              children: [
                _CarInfoCard(bookCtrl: bookCtrl),
                const SizedBox(height: _S.md),
                _TripDetailsCard(bookCtrl: bookCtrl),
                const SizedBox(height: _S.md),
                _PricingCard(bookCtrl: bookCtrl, p: _p, cur: _cur),
                const SizedBox(height: _S.md),
                _WalletCard(previewCtrl: controller),
                const SizedBox(height: _S.sm),
              ],
            ),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildHeroAppBar(BookingController bookCtrl) {
    final car = bookCtrl.selectedCar.value;
    final heroUrl = car?.modelImage?.trim() ??
        (car?.images.isNotEmpty == true ? car!.images.first.url : '');

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: false,
      backgroundColor: _C.primary,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.20),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
      ),
      title: Text(
        DynamicLanguage.key(Strings.bookingPreview),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.3,
        ),
      ),
      centerTitle: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            heroUrl.isNotEmpty
                ? AppCachedImage(
                    imageUrl: heroUrl,
                    fit: BoxFit.cover,
                    useShimmer: false,
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_C.primary, _C.primary.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
            // Dark gradient overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_C.heroTop, _C.heroBottom],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Car Info Card (overlaps hero) ────────────────────────────────────────────
class _CarInfoCard extends StatelessWidget {
  final BookingController bookCtrl;
  const _CarInfoCard({required this.bookCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final car = bookCtrl.selectedCar.value;
      if (car == null) return const SizedBox.shrink();

      return Container(
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(_Radii.large),
            boxShadow: [
              BoxShadow(
                color: _C.primary.withOpacity(0.10),
                blurRadius: 28,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(_S.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car name + year chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${car.make} ${car.model}',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: _C.textDark,
                        letterSpacing: -0.4,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: _S.sm),
                  _PreviewChip(
                    '${car.year}',
                    icon: Icons.calendar_today_rounded,
                    color: _C.primary,
                  ),
                ],
              ),
              const SizedBox(height: _S.xs + 2),
              // Vendor + rating
              Row(
                children: [
                  Icon(Icons.store_rounded, size: 13, color: _C.textMuted),
                  const SizedBox(width: _S.xs),
                  Expanded(
                    child: Text(
                      car.vendorName,
                      style: TextStyle(
                        fontSize: 13,
                        color: _C.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.star_rounded, size: 15, color: Colors.amber.shade600),
                  const SizedBox(width: 2),
                  Text(
                    car.vendorRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _C.textDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: _S.md),
              // Spec badges
              Wrap(
                spacing: _S.sm,
                runSpacing: _S.sm,
                children: [
                  _SpecBadge(icon: Icons.people_alt_rounded, label: '${car.seats} Seats'),
                  _SpecBadge(icon: Icons.settings_rounded,     label: car.transmission),
                  _SpecBadge(icon: Icons.local_gas_station_rounded, label: car.fuelType),
                  if (car.insuranceIncluded)
                    _SpecBadge(icon: Icons.verified_user_rounded, label: 'Insured', color: _C.success),
                ],
              ),
            ],
          ),
      );
    });
  }
}

// ─── Trip Details Card ────────────────────────────────────────────────────────
class _TripDetailsCard extends StatelessWidget {
  final BookingController bookCtrl;
  const _TripDetailsCard({required this.bookCtrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() => _PreviewSectionCard(
        title: DynamicLanguage.key(Strings.preview),
        icon: Icons.route_rounded,
        children: [
          if (bookCtrl.isDeliver.value) ...[
            _DetailRow(
              icon: Icons.location_on_rounded,
              iconColor: _C.primary,
              label: DynamicLanguage.key(Strings.PickUpLocation),
              value: bookCtrl.pickupLocation.value?.address ??
                  bookCtrl.locationController.text,
            ),
            _PreviewDivider(),
            _DetailRow(
              icon: Icons.calendar_month_rounded,
              iconColor: _C.accent,
              label: DynamicLanguage.key(Strings.PickUpdate),
              value: bookCtrl.pickupDate.value,
            ),
            _PreviewDivider(),
            _DetailRow(
              icon: Icons.access_time_filled_rounded,
              iconColor: _C.accent,
              label: DynamicLanguage.key(Strings.PickUpTime),
              value: bookCtrl.pickupTime.value,
            ),
            _PreviewDivider(),
          ],
          _DetailRow(
            icon: Icons.date_range_rounded,
            iconColor: _C.primary,
            label: DynamicLanguage.key(Strings.rentalDays),
            value: bookCtrl.quantityController.text,
            badge: _PreviewChip(
              '${bookCtrl.quantityController.text} ${DynamicLanguage.key(Strings.Day)}',
              color: _C.primary,
            ),
          ),
          if (bookCtrl.isDeliver.value) ...[
            _PreviewDivider(),
            _DetailRow(
              icon: Icons.local_shipping_rounded,
              iconColor: _C.success,
              label: DynamicLanguage.key(Strings.deliveryCar),
              value: DynamicLanguage.key(Strings.yes),
              badge: _PreviewChip(
                DynamicLanguage.key(Strings.yes),
                color: _C.success,
              ),
            ),
          ],
        ],
      ));
  }
}

// ─── Pricing Card ─────────────────────────────────────────────────────────────
class _PricingCard extends StatelessWidget {
  final BookingController bookCtrl;
  final String Function(num) p;
  final String Function(String?) cur;
  const _PricingCard({
    required this.bookCtrl,
    required this.p,
    required this.cur,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
        final c = cur(bookCtrl.selectedPricing.value?.currency);
        final unitPrice = bookCtrl.effectivePrice.value > 0
            ? bookCtrl.effectivePrice.value
            : (bookCtrl.selectedPricing.value?.price ?? 0);
        final pricingLabel = bookCtrl.pricingType.value == 'per_day'
            ? DynamicLanguage.key(Strings.pricePerDay)
            : DynamicLanguage.key(Strings.pricePerKm);

        return _PreviewSectionCard(
          title: DynamicLanguage.key(Strings.payment),
          icon: Icons.receipt_long_rounded,
          children: [
            _PriceRow(label: pricingLabel, value: '${p(unitPrice)} $c'),
            _PreviewDivider(),
            _PriceRow(
              label: DynamicLanguage.key(Strings.totalRent),
              value: '${p(bookCtrl.subtotal.value)} $c',
            ),
            if (bookCtrl.isDeliver.value && bookCtrl.deliveryCharge.value > 0) ...[
              _PreviewDivider(),
              _PriceRow(
                label: DynamicLanguage.key(Strings.deliveryCharge),
                value: '${p(bookCtrl.deliveryCharge.value)} $c',
              ),
            ],
            if (bookCtrl.selectedInsuranceType.value == 'daily' && bookCtrl.insuranceSubtotal.value > 0) ...[
              _PreviewDivider(),
              _PriceRow(
                label: DynamicLanguage.key(Strings.appLDailyInsurance),
                value: '${p(bookCtrl.insuranceSubtotal.value)} $c',
              ),
            ],
            if (bookCtrl.selectedCar.value?.taxEnabled == true &&
                bookCtrl.taxAmount.value > 0) ...[
              _PreviewDivider(),
              _PriceRow(
                label: 'VAT (15%)',
                value: '${p(bookCtrl.taxAmount.value)} $c',
              ),
            ],
            if (bookCtrl.selectedCar.value?.kmOverageCharge != null &&
                bookCtrl.selectedCar.value!.kmOverageCharge! > 0) ...[
              _PreviewDivider(),
              _KmAllowanceAlertCard(
                kmAllowance: bookCtrl.selectedCar.value!.kmAllowance,
                kmOverageCharge: bookCtrl.selectedCar.value!.kmOverageCharge,
                p: p,
              ),
            ],
            const SizedBox(height: _S.sm),
            // Highlighted total row
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: _S.md,
                vertical: _S.md - 2,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _C.primary.withOpacity(0.06),
                    _C.primary.withOpacity(0.13),
                  ],
                ),
                borderRadius: BorderRadius.circular(_Radii.card),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DynamicLanguage.key(Strings.totalPayable),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _C.primary,
                    ),
                  ),
                  Text(
                    '${p(bookCtrl.total.value)} $c',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _C.primary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      });
  }
}

// ─── KM Allowance Alert Card ──────────────────────────────────────────────────
class _KmAllowanceAlertCard extends StatelessWidget {
  final double? kmAllowance;
  final double? kmOverageCharge;
  final String Function(num) p;

  const _KmAllowanceAlertCard({
    required this.kmAllowance,
    required this.kmOverageCharge,
    required this.p,
  });

  @override
  Widget build(BuildContext context) {
    final message = _formatKmAllowanceMessage(kmAllowance, kmOverageCharge, p);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: _S.sm),
      padding: const EdgeInsets.all(_S.md),
      decoration: BoxDecoration(
        color: _C.surfaceBlue,
        borderRadius: BorderRadius.circular(_Radii.card),
        border: Border.all(
          color: _C.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: _C.primary,
          ),
          const SizedBox(width: _S.md),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: _C.textDark,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wallet Card ──────────────────────────────────────────────────────────────
class _WalletCard extends StatelessWidget {
  final PreviewController previewCtrl;
  const _WalletCard({required this.previewCtrl});

  @override
  Widget build(BuildContext context) {
    try {
      final walletCtrl = Get.find<WalletController>();
      return Obx(() {
          final amount   = previewCtrl.totalPayable.value;
          final currency = previewCtrl.selectedCurrency.value?.alias ??
              (previewCtrl.alias.value.isNotEmpty
                  ? previewCtrl.alias.value
                  : 'SAR');
          final balance   = walletCtrl.getBalanceForCurrency(currency);
          final enough    = walletCtrl.hasSufficientBalance(amount, currency);
          final tint      = enough ? _C.success : _C.warning;
          final bgTint    = enough
              ? const Color(0xFFEAFAF1)
              : const Color(0xFFFFFAEB);

          return Container(
            decoration: BoxDecoration(
              color: bgTint,
              borderRadius: BorderRadius.circular(_Radii.large),
              border: Border.all(color: tint.withOpacity(0.30), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(_S.md),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(_S.sm + 1),
                        decoration: BoxDecoration(
                          color: tint.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: tint,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: _S.sm),
                      Text(
                        'Wallet Payment',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _C.textDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: tint.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(_Radii.chip),
                        ),
                        child: Text(
                          enough ? '✓  Ready' : 'Low Balance',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: tint,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: tint.withOpacity(0.20), height: 1),
                // Balance rows
                Padding(
                  padding: const EdgeInsets.all(_S.md),
                  child: Column(
                    children: [
                      _WalletRow(
                        label: 'Current Balance',
                        value: '$balance $currency',
                        valueColor: _C.textDark,
                      ),
                      const SizedBox(height: _S.sm),
                      _WalletRow(
                        label: 'Booking Amount',
                        value: '$amount $currency',
                        valueColor: _C.textDark,
                      ),
                      if (!enough) ...[
                        const SizedBox(height: _S.md),
                        // Warning notice
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: _S.sm, vertical: _S.sm),
                          decoration: BoxDecoration(
                            color: _C.warning.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 16, color: _C.warning),
                              const SizedBox(width: _S.xs + 2),
                              Expanded(
                                child: Text(
                                  'Insufficient balance. Top up your wallet to continue.',
                                  style: TextStyle(
                                      fontSize: 12, color: _C.warning),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: _S.sm),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () => Get.toNamed(Routes.walletScreen),
                            icon: const Icon(Icons.add_card_rounded, size: 16),
                            label: const Text('Top Up Wallet'),
                            style: TextButton.styleFrom(
                              foregroundColor: _C.warning,
                              backgroundColor: _C.warning.withOpacity(0.10),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(_Radii.card),
                              ),
                            ),
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
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

// ─── Bottom CTA Bar ───────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final PreviewController controller;
  final BookingController bookCtrl;
  final String Function(num) p;
  final String Function(String?) cur;
  const _BottomBar({
    required this.controller,
    required this.bookCtrl,
    required this.p,
    required this.cur,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(
          _S.md, _S.sm, _S.md, bottomPad > 0 ? bottomPad : _S.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Amount row
          Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DynamicLanguage.key(Strings.totalPayable),
                style: TextStyle(
                  fontSize: 13,
                  color: _C.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${p(bookCtrl.total.value)} ',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _C.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: cur(bookCtrl.selectedPricing.value?.currency),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _C.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )),
          const SizedBox(height: _S.sm),
          // Confirm button
          Obx(() => SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: controller.isBookingLoading
                  ? null
                  : controller.handlePaymentProcess,
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _C.primary.withOpacity(0.45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_Radii.card),
                ),
                elevation: 0,
              ),
              child: controller.isBookingLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            size: 20),
                        const SizedBox(width: _S.sm),
                        Text(
                          DynamicLanguage.key(Strings.ConfirmBooking),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Shared Section Card ──────────────────────────────────────────────────────
class _PreviewSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  const _PreviewSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.card,
        borderRadius: BorderRadius.circular(_Radii.large),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 18,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(_S.md, _S.md, _S.md, _S.sm - 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _C.surfaceBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 15, color: _C.primary),
                ),
                const SizedBox(width: _S.sm),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: _C.divider, height: 1),
          Padding(
            padding: const EdgeInsets.all(_S.md),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Widget? badge;
  const _DetailRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _S.sm - 1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: _C.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (badge != null)
            badge!
          else
            Flexible(
              flex: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(Get.context!).size.width * 0.42,
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _C.textDark,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Price Row ────────────────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  const _PriceRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: _S.sm - 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: _C.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _C.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Wallet Row ───────────────────────────────────────────────────────────────
class _WalletRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _WalletRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: _C.textMuted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor ?? _C.textDark,
          ),
        ),
      ],
    );
  }
}

// ─── Divider ──────────────────────────────────────────────────────────────────
class _PreviewDivider extends StatelessWidget {
  const _PreviewDivider();

  @override
  Widget build(BuildContext context) =>
      Divider(color: _C.divider, height: 1, thickness: 1);
}

// ─── Chip badge ───────────────────────────────────────────────────────────────
class _PreviewChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  const _PreviewChip(this.label, {this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(_Radii.chip),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: _S.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Spec Badge ───────────────────────────────────────────────────────────────
class _SpecBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _SpecBadge({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? _C.primary;
    final truncated =
        label.length > 14 ? '${label.substring(0, 13)}…' : label;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: _S.sm + 2, vertical: _S.xs + 2),
      decoration: BoxDecoration(
        color: c.withOpacity(0.09),
        borderRadius: BorderRadius.circular(_S.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: c),
          const SizedBox(width: _S.xs),
          Text(
            truncated,
            style: TextStyle(
              fontSize: 11,
              color: c,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
