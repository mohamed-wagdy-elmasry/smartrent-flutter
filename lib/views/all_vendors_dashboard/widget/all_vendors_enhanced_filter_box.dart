part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsEnhancedFilterBox
    extends GetView<AllVendorsDashboardController> {
  const AllVendorsEnhancedFilterBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filters have been removed from the All Vendors flow. Keep this widget
    // in place as a harmless placeholder to avoid referencing removed
    // controller fields/methods. If you want the filters back, we can
    // re-implement them behind feature flags.
    return SizedBox.shrink();
  }
}
