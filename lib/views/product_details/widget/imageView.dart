part of '../screen/product_details_screen.dart';

class Imageview extends GetView<ProductDetailsController> {
  const Imageview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.imageList.isEmpty) {
        return Center(child: Loader());
      }
      return ImageView360(
        imageList: controller.imageList
            .map((path) => NetworkImage(path))
            .toList(),
        // autoRotate: true,
        rotationDirection: RotationDirection.anticlockwise,
        allowSwipeToRotate: true,
        rotationCount: 2,
        swipeSensitivity: 2,
        frameChangeDuration: const Duration(milliseconds: 170),

        key: UniqueKey(),
      );
    });
  }
}
