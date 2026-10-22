import 'package:flutter/material.dart';
import 'package:imageview360/imageview360.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/utils/local_storage.dart';
import '../../../routes/routes.dart';
import '../controller/product_details_controller.dart';
part 'product_details_tablet_screen.dart';
part 'product_details_mobile_screen.dart';
part '../widget/imageView.dart';
part '../widget/book_now.dart';
part '../widget/brand_header.dart';
part '../widget/car_info.dart';
part '../widget/range.dart';
part '../widget/detail_review.dart';

class ProductDetailsScreen extends GetView<ProductDetailsController> {
  const ProductDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: ProductDetailsMobileScreen(),
      tablet: ProductDetailsTabletScreen(),
    );
  }
}
