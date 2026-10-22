part of '../screen/vendor_cars_screen.dart';

// ════════════════════════════════════════════════════════════════
// Vendor Cars — Brand & City Filter Bottom Sheet
// ════════════════════════════════════════════════════════════════
class _VendorCarsFilterSheet extends StatefulWidget {
  final VendorCarsController controller;

  const _VendorCarsFilterSheet({required this.controller});

  @override
  State<_VendorCarsFilterSheet> createState() => _VendorCarsFilterSheetState();
}

class _VendorCarsFilterSheetState extends State<_VendorCarsFilterSheet> {
  late String _selectedBrand;
  late String _selectedCity;

  VendorCarsController get c => widget.controller;

  @override
  void initState() {
    super.initState();
    _selectedBrand = c.selectedBrand.value;
    _selectedCity = c.selectedCity.value;
  }

  void _applyFilters() {
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
      _selectedBrand = 'all';
      _selectedCity = 'all';
    });
  }

  bool get _isModified => _selectedBrand != 'all' || _selectedCity != 'all';

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
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  DynamicLanguage.key(Strings.filterBy),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                if (_isModified)
                  GestureDetector(
                    onTap: _resetFilters,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: const Color(0xFFFCA5A5), width: 1),
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
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 18, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Section: Brand ──
                  if (brands.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _vcSectionLabel(Icons.directions_car_rounded, 'Brands'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _VcSheetChip(
                          label: 'All',
                          isSelected: _selectedBrand == 'all',
                          onTap: () => setState(() => _selectedBrand = 'all'),
                        ),
                        ...brands.map((brand) => _VcSheetChip(
                              label: brand,
                              isSelected: _selectedBrand == brand,
                              onTap: () =>
                                  setState(() => _selectedBrand = brand),
                            )),
                      ],
                    ),
                  ],

                  // ── Section: City ──
                  if (cities.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _vcSectionLabel(Icons.location_city_rounded, 'Cities'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _VcSheetChip(
                          label: DynamicLanguage.key(Strings.allCities),
                          isSelected: _selectedCity == 'all',
                          onTap: () => setState(() => _selectedCity = 'all'),
                        ),
                        ...cities.map((city) => _VcSheetChip(
                              label: city,
                              isSelected: _selectedCity == city,
                              onTap: () =>
                                  setState(() => _selectedCity = city),
                            )),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // ── Apply Button ──
          Padding(
            padding:
                EdgeInsets.fromLTRB(24, 16, 24, 16 + bottomInset),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
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
                    borderRadius: BorderRadius.circular(14),
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

  Widget _vcSectionLabel(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: CustomColor.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: CustomColor.primary),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ── Pill chip for the vendor-cars filter sheet ────────────────────────────────
class _VcSheetChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VcSheetChip({
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
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? CustomColor.primary : const Color(0xFFE5E7EB),
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
            color: isSelected ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}
