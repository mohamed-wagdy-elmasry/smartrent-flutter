part of '../screen/booking_screen.dart';

class BookingAllFields extends GetView<BookingController> {
  const BookingAllFields({Key? key}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionCard(
          icon: Icons.access_time_rounded,
          iconColor: const Color(0xFF0B5FA5),
          iconBg: const Color(0xFFE3F0FB),
          title: DynamicLanguage.key(Strings.bookingDetails),
          child: _quantityAndDateTime(),
        ),
        const SizedBox(height: 14),
        _buildDeliveryCard(),
        const SizedBox(height: 14),
        _buildInsuranceCard(),
        const SizedBox(height: 14),
        _buildPricingCard(),
        const SizedBox(height: 14),
        _buildKmAllowanceCard(),
        const SizedBox(height: 14),
        _buildNoteCard(),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Section card wrapper ─────────────────────────────────────────────────
  Widget _buildSectionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5FA5).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: const Color(0xFFE8ECF0), indent: 16, endIndent: 16),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

    // ── Quantity + date + time ──────────────────────────────────────────────
  Widget _quantityAndDateTime() {
    return Column(
      children: [
        // Quantity field — counter for per_day, text input for per_km
        Obx(() {
          if (controller.pricingType.value == 'per_day') {
            return CounterInput(
              controller: controller.quantityController,
              label: controller.getQuantityLabel(),
              min: 1,
              max: 90,
              suffixBuilder: (count) {
                final isArabic =
                    DynamicLanguage.selectedLanguage.value == 'ar';
                if (isArabic) {
                  if (count == 1) return 'يوم';
                  if (count == 2) return 'يومان';
                  if (count <= 10) return 'أيام';
                  return 'يومًا';
                }
                return count == 1 ? 'Day' : 'Days';
              },
            );
          }
          // per_km or unknown — keep text input
          return _styledInput(
            icon: Icons.route_rounded,
            child: PrimaryInputWidget(
              textInputType: TextInputType.number,
              controller: controller.quantityController,
              label: controller.getQuantityLabel(),
              hintText: controller.getQuantityHint(),
              showBorderSide: false,
              skipEnterText: true,
            ),
          );
        }),
        const SizedBox(height: 12),
        // Pickup date
        _styledInput(
          icon: Icons.event_rounded,
          child: CustomDatePicker(
            selectedDate: controller.pickupDate,
            label: DynamicLanguage.key(Strings.PickUpdate),
            subtitle: DynamicLanguage.key(Strings.SelectADate),
            showBorder: false,
          ),
        ),
        const SizedBox(height: 12),
        // Pickup time
        _styledInput(
          icon: Icons.schedule_rounded,
          child: CustomTimePicker(
            selectedTime: controller.pickupTime,
            label: DynamicLanguage.key(Strings.PickUpTime),
            subtitle: DynamicLanguage.key(Strings.SelectATime),
            showBorder: false,
          ),
        ),
      ],
    );
  }
  Widget _styledInput({required IconData icon, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3ECF5), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(icon, color: const Color(0xFF0B5FA5), size: 20),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ── Delivery card ─────────────────────────────────────────────────────────
  Widget _buildDeliveryCard() {
    return Obx(() {
      if (!controller.isDeliveryAvailable()) return const SizedBox.shrink();
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B5FA5).withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Toggle row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Obx(() => Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: controller.isDeliver.value
                          ? const Color(0xFF0B5FA5).withOpacity(0.1)
                          : const Color(0xFFF0F4F8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_shipping_rounded,
                      color: controller.isDeliver.value
                          ? const Color(0xFF0B5FA5)
                          : const Color(0xFF9EAAB8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DynamicLanguage.key(Strings.deliveryCar),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xFF0D1B2A),
                          ),
                        ),
                        if (controller.deliverySource.value == 'zone' &&
                            controller.deliveryDistance.value != null)
                          Text(
                            '${controller.deliveryDistance.value!.toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF0B5FA5),
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else
                          Text(
                            DynamicLanguage.key(Strings.deliveryCharge),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7A8D),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Custom animated toggle
                  GestureDetector(
                    onTap: () => controller.isDeliver.value = !controller.isDeliver.value,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 28,
                      decoration: BoxDecoration(
                        color: controller.isDeliver.value
                            ? const Color(0xFF0B5FA5)
                            : const Color(0xFFDDE3EA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: AnimatedAlign(
                        duration: const Duration(milliseconds: 200),
                        alignment: controller.isDeliver.value
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.all(3),
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ),
            // Location picker (shown when delivery enabled)
            Obx(() {
              if (!controller.isDeliver.value) return const SizedBox.shrink();
              return Column(
                children: [
                  Divider(height: 1, color: const Color(0xFFE8ECF0), indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildLocationPickerButton(),
                  ),
                ],
              );
            }),
            // Out-of-range warning (source == "none": zones exist but user is outside all)
            Obx(() {
              if (!controller.isDeliver.value) return const SizedBox.shrink();
              if (controller.deliverySource.value != 'none') return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    border: Border.all(color: const Color(0xFFFF9800)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFE65100), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          DynamicLanguage.key(Strings.outOfDeliveryRange),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7B4000),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  /// Build location picker button that navigates to map
  Widget _buildLocationPickerButton() {
    return Obx(() {
      final hasLocation = controller.pickupLocation.value != null;
      return GestureDetector(
        onTap: () async {
          final selectedCar = controller.selectedCar.value;
          if (selectedCar == null) return;

          final vendorLoc = selectedCar.vendorLocation;
          LatLng? center;
          double? radiusMeters;

          // Set center location if available
          if (vendorLoc != null && vendorLoc.latitude != null && vendorLoc.longitude != null) {
            center = LatLng(vendorLoc.latitude!, vendorLoc.longitude!);
          }

          // Fetch delivery zones from API for coverage radius
          if (selectedCar.branchId != null && center != null) {
            final deliveryService = Get.find<DeliveryService>();
            final zonesResponse = await deliveryService.fetchDeliveryZones(
              branchId: selectedCar.branchId!,
            );

            if (zonesResponse != null && zonesResponse.isSuccess && zonesResponse.data?.coverage?.isValid == true) {
              // Use coverage.max_km from API (convert km to meters)
              radiusMeters = zonesResponse.data!.coverage!.maxKm! * 1000.0;
            }
          }

          Get.to(() => LocationPickerWidget(
            onLocationSelected: (location) {
              debugPrint('[LocationPicker] Location selected: ${location.address}');
              debugPrint('[LocationPicker] Coordinates: ${location.latitude}, ${location.longitude}');
              controller.pickupLocation.value = location;
              controller.pickupLatitude.value = location.latitude;
              controller.pickupLongitude.value = location.longitude;
              debugPrint('[LocationPicker] Controller state updated');
              debugPrint('[LocationPicker] isDeliver: ${controller.isDeliver.value}');
            },
            initialLocation: controller.pickupLocation.value,
            center: center,
            radiusMeters: radiusMeters,
          ));
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: hasLocation
                ? const Color(0xFFE3F0FB)
                : const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasLocation
                  ? const Color(0xFF0B5FA5)
                  : const Color(0xFFDDE3EA),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: hasLocation
                      ? const Color(0xFF0B5FA5)
                      : const Color(0xFFE8ECF0),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: hasLocation ? Colors.white : const Color(0xFF9EAAB8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DynamicLanguage.key(Strings.PickUpLocation),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: hasLocation
                            ? const Color(0xFF0B5FA5)
                            : const Color(0xFF6B7A8D),
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (hasLocation) ...[
                      Text(
                        controller.pickupLocation.value!.address,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0D1B2A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${controller.pickupLocation.value!.latitude.toStringAsFixed(4)}, ${controller.pickupLocation.value!.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9EAAB8),
                        ),
                      ),
                    ] else
                      Text(
                        DynamicLanguage.key(Strings.PickUpLocation),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9EAAB8),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                hasLocation
                    ? Icons.edit_location_alt_rounded
                    : Icons.chevron_right_rounded,
                color: hasLocation
                    ? const Color(0xFF0B5FA5)
                    : const Color(0xFF9EAAB8),
                size: 22,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Insurance card ────────────────────────────────────────────────────────
  Widget _buildInsuranceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B5FA5).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Color(0xFF4CAF50),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  DynamicLanguage.key(Strings.appLSelectInsurance),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D1B2A),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: const Color(0xFFE8ECF0), indent: 16, endIndent: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Daily Insurance Option
                Obx(() => _buildInsuranceOption(
                  label: DynamicLanguage.key(Strings.appLDailyInsurance),
                  value: 'daily',
                  isSelected: controller.selectedInsuranceType.value == 'daily',
                  icon: Icons.today_rounded,
                )),
                const SizedBox(height: 12),
                // Excess Liability Insurance Option
                Obx(() => _buildInsuranceOption(
                  label: DynamicLanguage.key(Strings.appLExcessLiabilityInsurance),
                  value: 'excess_liability',
                  isSelected: controller.selectedInsuranceType.value == 'excess_liability',
                  icon: Icons.warning_rounded,
                )),
                const SizedBox(height: 12),
                // Warning message for excess_liability
                Obx(() {
                  if (controller.selectedInsuranceType.value != 'excess_liability') {
                    return const SizedBox.shrink();
                  }
                  return _buildInsuranceWarning();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single insurance option button
  Widget _buildInsuranceOption({
    required String label,
    required String value,
    required bool isSelected,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: () => controller.selectedInsuranceType.value = value,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE3F0FB)
              : const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0B5FA5)
                : const Color(0xFFDDE3EA),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF0B5FA5)
                      : const Color(0xFF9EAAB8),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF0B5FA5),
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0B5FA5) : const Color(0xFF9EAAB8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF0B5FA5)
                      : const Color(0xFF6B7A8D),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build insurance warning card for excess_liability
  Widget _buildInsuranceWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFE65100),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                DynamicLanguage.key(Strings.appLInsuranceWarning),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF7B4000),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Display message based on app language
          Obx(() {
            String message = '';
            if (controller.insuranceMessage.value != null) {
              // Get current app language from DynamicLanguage
              final currentLang = DynamicLanguage.selectedLanguage.value;
              message = controller.insuranceMessage.value![currentLang] ??
                  controller.insuranceMessage.value!['en'] ??
                  '';
            }
            return Text(
              message.isNotEmpty ? message : DynamicLanguage.key(Strings.appLInsuranceWarning),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7B4000),
                height: 1.4,
              ),
            );
          }),
          const SizedBox(height: 8),
          // Show insurance amount
          Obx(() {
            if (controller.insuranceExcessLiabilityAmount.value <= 0) {
              return const SizedBox.shrink();
            }
            final currency = _cur(controller.selectedPricing.value?.currency);
            return Text(
              '${DynamicLanguage.key(Strings.appLInsuranceAmount)}: ${_smartPrice(controller.insuranceExcessLiabilityAmount.value)} $currency',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE65100),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Pricing card ──────────────────────────────────────────────────────────
  Widget _buildPricingCard() {
    return Obx(() {
      final currency = _cur(controller.selectedPricing.value?.currency);
      final hasTotal = controller.total.value > 0;

      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF0B5FA5), Color(0xFF1A8CFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B5FA5).withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DynamicLanguage.key(Strings.totalRent),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withOpacity(0.2)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Vehicle Rental (subtotal)
                  if (controller.subtotal.value > 0) ...[
                    _pricingRow(
                      'Vehicle Rental',
                      '${_smartPrice(controller.subtotal.value)} $currency',
                      isWhite: true,
                      isSubtle: true,
                    ),
                  ],
                  // Delivery charge
                  if (controller.isDeliver.value && controller.deliveryCharge.value > 0) ...[
                    const SizedBox(height: 8),
                    _pricingRow(
                      DynamicLanguage.key(Strings.deliveryCharge),
                      controller.deliverySource.value == 'zone' &&
                              controller.deliveryDistance.value != null
                          ? '${_smartPrice(controller.deliveryCharge.value)} $currency (${controller.deliveryDistance.value!.toStringAsFixed(1)} km)'
                          : '${_smartPrice(controller.deliveryCharge.value)} $currency',
                      isWhite: true,
                      isSubtle: true,
                    ),
                  ],
                  // Daily Insurance (only when selected)
                  if (controller.selectedInsuranceType.value == 'daily' && controller.insuranceSubtotal.value > 0) ...[
                    const SizedBox(height: 8),
                    _pricingRow(
                      DynamicLanguage.key(Strings.appLDailyInsurance),
                      '${_smartPrice(controller.insuranceSubtotal.value)} $currency',
                      isWhite: true,
                      isSubtle: true,
                    ),
                  ],
                  // VAT (15%)
                  if (controller.selectedCar.value != null &&
                      controller.selectedCar.value!.taxEnabled &&
                      controller.taxAmount.value > 0) ...[
                    const SizedBox(height: 8),
                    _pricingRow(
                      'VAT (15%)',
                      '${_smartPrice(controller.taxAmount.value)} $currency',
                      isWhite: true,
                      isSubtle: true,
                    ),
                  ],
                  // Total
                  if (hasTotal) ...[
                    const SizedBox(height: 12),
                    Divider(color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 8),
                    _pricingRow(
                      DynamicLanguage.key(Strings.total),
                      '${_smartPrice(controller.total.value)} $currency',
                      isWhite: true,
                      isTotal: true,
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

  Widget _pricingRow(String label, String value, {
    bool isWhite = false,
    bool isSubtle = false,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isWhite
                ? (isSubtle ? Colors.white.withOpacity(0.75) : Colors.white)
                : (isSubtle ? const Color(0xFF6B7A8D) : const Color(0xFF0D1B2A)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isWhite ? Colors.white : const Color(0xFF0B5FA5),
          ),
        ),
      ],
    );
  }

  Widget _buildKmAllowanceCard() {
    return Obx(() {
      final car = controller.selectedCar.value;
      if (car?.kmOverageCharge == null || car!.kmOverageCharge! <= 0) {
        return const SizedBox.shrink();
      }

      final kmStr = _smartPrice(car.kmAllowance ?? 0);
      final chargeStr = _smartPrice(car.kmOverageCharge ?? 0);
      final appLocalizations = AppLocalizations.of(Get.context!);
      final message = appLocalizations?.appLKmAllowanceMessage(chargeStr, kmStr) ?? '';

      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAF1FD),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF0B5FA5).withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0B5FA5).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: Color(0xFF0B5FA5), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    DynamicLanguage.key(Strings.kmAllowanceLabel),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0D1B2A),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: const Color(0xFF0B5FA5).withOpacity(0.10),
              indent: 16,
              endIndent: 16,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0D1B2A),
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Note card ─────────────────────────────────────────────────────────────
  Widget _buildNoteCard() {
    return _buildSectionCard(
      icon: Icons.edit_note_rounded,
      iconColor: const Color(0xFFFF8C00),
      iconBg: const Color(0xFFFFF3E0),
      title: DynamicLanguage.key(Strings.note),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3ECF5), width: 1.2),
        ),
        child: PrimaryInputWidget(
          skipEnterText: true,
          optionalText: DynamicLanguage.key(Strings.Optional),
          label: DynamicLanguage.key(Strings.note),
          maxLines: 4,
          controller: controller.noteController,
          hintText: DynamicLanguage.key(Strings.writeHere),
          textInputType: TextInputType.name,
          showBorderSide: false,
        ),
      ),
    );
  }
}

