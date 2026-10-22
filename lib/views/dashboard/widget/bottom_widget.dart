part of '../screen/dashboard_screen.dart';

class BottomWidget extends GetView<DashboardController> {
  final int index;

  BottomWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cars.isEmpty || index >= controller.cars.length) {
        return SizedBox();
      }

      final car = controller.cars[index];

      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 5,
          vertical: Dimensions.verticalSize * 0.8,
        ),
        child: PrimaryButton(
          title: Strings.bookNow,
          onPressed: () {
            if (!LocalStorage.isLoggedIn) {
              Get.toNamed(Routes.otpLoginScreen);
              return;
            }
            controller.selectedCarId.value = car.id.toString();
            Get.toNamed(Routes.bookingScreen);
          },
        ),
      );
    });
  }
}
