part of '../screen/all_vendors_dashboard_screen.dart';

// ── Bottom-nav design tokens ──────────────────────────────────────────────────
class _NavC {
  static const Color active   = Color(0xFF0B5FA5);
  static const Color inactive = Color(0xFF94A3B8);
  static const Color bg       = Color(0xFFFFFFFF);
  static const Color pill     = Color(0xFFE8F1FB);
}
// ─────────────────────────────────────────────────────────────────────────────

class AllVendorsDashboardMobileScreen
    extends GetView<AllVendorsDashboardController> {
  const AllVendorsDashboardMobileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: CustomColor.primary,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: _NavC.bg,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: CustomColor.background,
        body: Obx(() => controller.isLoad ? Loader() : AllVendorsCarListView()),
        bottomNavigationBar: _BottomNavBar(),
      ),
    );
  }
}

// ── Bottom nav bar ────────────────────────────────────────────────────────────
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: BoxDecoration(
        color: _NavC.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64 + (bottomPad > 0 ? 0 : 4),
          child: Row(
            children: [
              _NavItem(
                icon: Iconsax.car5,
                activeIcon: Iconsax.car5,
                label: DynamicLanguage.key(Strings.bookYorCar),
                isActive: true,
                onTap: () {},
              ),
              _NavItem(
                icon: Iconsax.wallet_2,
                activeIcon: Iconsax.wallet_25,
                label: DynamicLanguage.key(Strings.wallet),
                isActive: false,
                onTap: () => Get.toNamed(Routes.walletScreen),
              ),
              _NavItem(
                icon: Iconsax.user,
                activeIcon: Iconsax.user_tick5,
                label: DynamicLanguage.key(Strings.editProfile),
                isActive: false,
                onTap: () => Get.toNamed(Routes.update_profileScreen),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? _NavC.pill : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 22,
                color: isActive ? _NavC.active : _NavC.inactive,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? _NavC.active : _NavC.inactive,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
