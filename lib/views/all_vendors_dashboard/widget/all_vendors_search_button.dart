part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsSearchButton extends GetView<AllVendorsDashboardController> {
  const AllVendorsSearchButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filters removed; search happens automatically on init/refresh.
    // Keep widget as no-op placeholder.
    return SizedBox.shrink();
  }
}
