part of '../screen/product_details_screen.dart';

class Range extends GetView<ProductDetailsController> {
  const Range({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Sizes.height.v10,
        Row(
          mainAxisAlignment: mainSpaceBet,
          children: [
            TextWidget(
              padding: EdgeInsets.only(left: Dimensions.defaultHorizontalSize),
              Strings.range,
              fontWeight: FontWeight.bold,
            ),
            TextWidget(
              padding: EdgeInsets.only(right: Dimensions.defaultHorizontalSize),
              '360/mi',
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        Sizes.height.v10,
        Container(
          height: 16,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                CustomColor.whiteColor,
                CustomColor.primary.withValues(alpha: 0.8),
                CustomColor.whiteColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ],
    );
  }
}
