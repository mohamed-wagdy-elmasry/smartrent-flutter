part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsFilterBox extends GetView<AllVendorsDashboardController> {
  const AllVendorsFilterBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filters were removed from the dashboard controller. Keep this widget
    // as a no-op to avoid referencing removed fields/methods.
    return SizedBox.shrink();
  }
}
