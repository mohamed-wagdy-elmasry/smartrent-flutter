import 'package:cached_network_image/cached_network_image.dart';
import 'package:carbo/routes/routes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/utils/local_storage.dart';
import '../../../base/widgets/app_cached_image.dart';
import '../../../base/services/location_service.dart';
import '../controller/all_vendors_dashboard_controller.dart';
import '../../dashboard/controller/dashboard_controller.dart';
import '../model/vendor_cars_model.dart';

part 'all_vendors_dashboard_mobile_screen.dart';
part '../widget/all_vendors_filter_box.dart';
part '../widget/all_vendors_enhanced_filter_box.dart';
part '../widget/all_vendors_car_carousel.dart';
part '../widget/all_vendors_car_list_view.dart';
part '../widget/all_vendors_search_button.dart';
part '../widget/all_vendors_app_bar.dart';
part '../widget/all_vendors_brand_filter.dart';
part '../widget/all_vendors_city_filter.dart';

class AllVendorsDashboardScreen extends GetView<AllVendorsDashboardController> {
  const AllVendorsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AllVendorsDashboardMobileScreen();
  }
}

// Helper widget for loading network images with better error handling
class NetworkImageLoader extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;
  final Widget Function(BuildContext) loadingBuilder;
  final Widget Function(BuildContext, Object, StackTrace) errorBuilder;

  const NetworkImageLoader({
    required this.imageUrl,
    required this.height,
    required this.width,
    this.fit = BoxFit.cover,
    required this.loadingBuilder,
    required this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: height,
      width: width,
      fit: fit,
      placeholder: (context, url) => loadingBuilder(context),
      errorWidget: (context, url, error) => errorBuilder(context, error, StackTrace.current),
    );
  }
}
