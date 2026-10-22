part of '../screen/dashboard_screen.dart';

class TimeDateBox extends GetView<DashboardController> {
  const TimeDateBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      decoration: BoxDecoration(
        color: CustomColor.whiteColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.verticalSize * 0.4,
        horizontal: Dimensions.defaultHorizontalSize * 0.8,
      ),
      child: Column(children: [_dateAndTimePicker(context)]),
    );
  }

  _dateAndTimePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomDatePicker(
            showBorder: false,
            labelSpacing: Sizes.height.v5,
            inputBoxHeight: Dimensions.inputBoxHeight * 0.695,
            labelFontSize: Dimensions.titleSmall * 0.8,
            hintFontSize: Dimensions.titleSmall * 0.8,
            label: Strings.SelectADate,
            selectedDate: controller.selectedDate,
          ),
        ),
        Sizes.width.v10,
        Expanded(
          child: CustomTimePicker(
            showBorder: false,
            labelSpacing: Sizes.height.v5,
            inputBoxHeight: Dimensions.inputBoxHeight * 0.695,
            labelFontSize: Dimensions.titleSmall * 0.8,
            hintFontSize: Dimensions.titleSmall * 0.8,
            label: Strings.SelectATime,
            selectedTime: controller.selectedTime,
          ),
        ),
      ],
    );
  }
}
