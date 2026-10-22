part of 'dashboard_screen.dart';

// ──────────────────────────────────────────────────────────────
// Design Tokens (screen-local, only what this file uses)
// ──────────────────────────────────────────────────────────────
class _DashboardColors {
  static const Color surface = Color(0xFFF7F8FA);
}

// ──────────────────────────────────────────────────────────────
// Dashboard Mobile Screen — Redesigned
// ──────────────────────────────────────────────────────────────
class DashboardMobileScreen extends GetView<DashboardController> {
  DashboardMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _DashboardColors.surface,
        drawer: DrawerMobileScreen(),
        body: Obx(
          () => controller.isLoading
              ? const Center(child: Loader())
              : _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (!Get.isRegistered<AllVendorsDashboardController>()) {
      Get.put(AllVendorsDashboardController(), permanent: true);
    }

    return GetBuilder<AllVendorsDashboardController>(
      builder: (vendorCtrl) {
        return AllVendorsCarListView();
      },
    );
  }
}
