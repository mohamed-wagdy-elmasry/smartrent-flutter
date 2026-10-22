import 'package:carbo/base/widgets/counter_input.dart';
import 'package:carbo/routes/routes.dart';
import 'package:carbo/views/all_vendors_dashboard/model/vendor_cars_model.dart';
import 'package:flutter/material.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/widgets/custom_date_picker.dart';
import '../../../base/widgets/custom_time_picker.dart';
import '../../../base/services/delivery_service.dart';
import '../controller/booking_controller.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widget/location_picker_widget.dart';
part 'booking_tablet_screen.dart';
part 'booking_mobile_screen.dart';
part '../widget/booking_all_fields.dart';

class BookingScreen extends GetView<BookingController> {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: BookingMobileScreen(),
      tablet: BookingTabletScreen(),
    );
  }
}
