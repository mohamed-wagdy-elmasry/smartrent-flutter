part of '../screen/dashboard_screen.dart';

class FindCarButton extends GetView<DashboardController> {
  const FindCarButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize,
          vertical: Dimensions.verticalSize,
        ),
        child: PrimaryButton(
          isLoading: controller.isSearchingCar,
          title: Strings.findCar,
          onPressed: () {
            controller.searchAllCar();
          },
        ),
      ),
    );
  }
}
