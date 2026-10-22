part of '../screen/vendor_cars_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens (screen-local)
// ─────────────────────────────────────────────────────────────────────────────
class _BrandPalette {
  static const Map<String, List<Color>> _gradients = {
    'nissan':    [Color(0xFFC0392B), Color(0xFF922B21)],
    'toyota':    [Color(0xFF1A1A2E), Color(0xFF16213E)],
    'honda':     [Color(0xFFCC0000), Color(0xFF900000)],
    'bmw':       [Color(0xFF0066B1), Color(0xFF004E8C)],
    'mercedes':  [Color(0xFF2C3E50), Color(0xFF1A252F)],
    'mercedes-benz': [Color(0xFF2C3E50), Color(0xFF1A252F)],
    'audi':      [Color(0xFF1C1C1C), Color(0xFF3D3D3D)],
    'volkswagen':[Color(0xFF1A3A6B), Color(0xFF0D2345)],
    'vw':        [Color(0xFF1A3A6B), Color(0xFF0D2345)],
    'hyundai':   [Color(0xFF002C5F), Color(0xFF001B3E)],
    'kia':       [Color(0xFF05141F), Color(0xFF0B2239)],
    'ford':      [Color(0xFF003478), Color(0xFF002060)],
    'chevrolet': [Color(0xFFD4AF37), Color(0xFFB8960C)],
    'lexus':     [Color(0xFF1A1A2E), Color(0xFF0F0F1F)],
    'jeep':      [Color(0xFF2E7D32), Color(0xFF1B5E20)],
    'dodge':     [Color(0xFFB71C1C), Color(0xFF7F0000)],
    'gmc':       [Color(0xFF37474F), Color(0xFF263238)],
    'porsche':   [Color(0xFFB59410), Color(0xFF8A6D0B)],
    'ferrari':   [Color(0xFFCC0000), Color(0xFF8B0000)],
    'lamborghini':[Color(0xFFD4AF37), Color(0xFF9E7B00)],
    'land rover':[Color(0xFF2E6B4F), Color(0xFF1B4332)],
    'landrover': [Color(0xFF2E6B4F), Color(0xFF1B4332)],
    'range rover':[Color(0xFF2E6B4F), Color(0xFF1B4332)],
    'maserati':  [Color(0xFF003087), Color(0xFF001A5E)],
    'bentley':   [Color(0xFF1B4B36), Color(0xFF0D2E20)],
    'rolls-royce':[Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
    'cadillac':  [Color(0xFF8B0000), Color(0xFF5B0000)],
    'lincoln':   [Color(0xFF1A2744), Color(0xFF0D1629)],
    'infiniti':  [Color(0xFF2D2D2D), Color(0xFF1A1A1A)],
    'acura':     [Color(0xFF1A1A2E), Color(0xFF0D0D20)],
    'subaru':    [Color(0xFF1B3A6B), Color(0xFF0F2245)],
    'mitsubishi':[Color(0xFFCC0000), Color(0xFF8B0000)],
    'mazda':     [Color(0xFF8B0000), Color(0xFF5B0000)],
    'suzuki':    [Color(0xFF003087), Color(0xFF001860)],
    'renault':   [Color(0xFFE2001A), Color(0xFFA80013)],
    'peugeot':   [Color(0xFF1A1A2E), Color(0xFF101026)],
    'citroen':   [Color(0xFFCC0000), Color(0xFF8B0000)],
    'fiat':      [Color(0xFF003087), Color(0xFF001860)],
    'volvo':     [Color(0xFF003C8F), Color(0xFF002867)],
    'alfa romeo':[Color(0xFFB21E29), Color(0xFF7D1520)],
    'opel':      [Color(0xFFFF6B00), Color(0xFFCC5500)],
    'skoda':     [Color(0xFF1A4731), Color(0xFF0D2E1F)],
    'seat':      [Color(0xFF1A1A2E), Color(0xFF0D0D20)],
  };

  static const Color _defaultTop    = Color(0xFF374151);
  static const Color _defaultBottom = Color(0xFF1F2937);

  static List<Color> gradient(String make) {
    return _gradients[make.toLowerCase().trim()] ??
        [_defaultTop, _defaultBottom];
  }

  static String abbreviation(String make) {
    final words = make.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
    return make.substring(0, make.length >= 2 ? 2 : 1).toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Brand filter row
// ─────────────────────────────────────────────────────────────────────────────
class VendorCarsBrandFilter extends GetView<VendorCarsController> {
  const VendorCarsBrandFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final brands = controller.availableBrands;
      final currentBrand = controller.selectedBrand.value;
      if (brands.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.defaultHorizontalSize,
            ),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: CustomColor.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Brands',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF374151),
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: CustomColor.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${brands.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: CustomColor.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.defaultHorizontalSize,
              ),
              physics: const BouncingScrollPhysics(),
              itemCount: brands.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _AllBrandChip(
                    isSelected: currentBrand == 'all',
                    carCount: controller.brandCarCount('all'),
                    onTap: () => controller.changeBrandFilter('all'),
                  );
                }
                final brand = brands[index - 1];
                return _BrandChip(
                  brand: brand,
                  isSelected: currentBrand == brand,
                  carCount: controller.brandCarCount(brand),
                  onTap: () => controller.changeBrandFilter(brand),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// "All brands" chip
// ─────────────────────────────────────────────────────────────────────────────
class _AllBrandChip extends StatelessWidget {
  final bool isSelected;
  final int carCount;
  final VoidCallback onTap;

  const _AllBrandChip({
    required this.isSelected,
    required this.carCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? CustomColor.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? CustomColor.primary : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: CustomColor.primary.withOpacity(0.30),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF374151),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$carCount',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual brand chip
// ─────────────────────────────────────────────────────────────────────────────
class _BrandChip extends StatelessWidget {
  final String brand;
  final bool isSelected;
  final int carCount;
  final VoidCallback onTap;

  const _BrandChip({
    required this.brand,
    required this.isSelected,
    required this.carCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _BrandPalette.gradient(brand);
    final displayName = brand
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1))
        .join(' ');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? colors[0] : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors[0] : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colors[0].withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              displayName,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF374151),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$carCount',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
