part of '../screen/product_details_screen.dart';

class CarInfo extends GetView<ProductDetailsController> {
  const CarInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: Row(
        mainAxisAlignment: mainSpaceBet,
        children: [
          Wrap(
            children: [
              Icon(Icons.speed, size: Dimensions.iconSizeDefault),
              Sizes.width.v5,
              Column(
                crossAxisAlignment: crossStart,
                children: [
                  TextWidget(Strings.speed, fontSize: Dimensions.titleSmall),
                  TextWidget('200/mph', fontWeight: FontWeight.bold),
                  TextWidget(Strings.topSpeed, fontSize: Dimensions.titleSmall),
                ],
              ),
            ],
          ),
          Wrap(
            children: [
              Icon(Icons.flash_on_outlined, size: Dimensions.iconSizeDefault),
              Sizes.width.v5,
              Column(
                crossAxisAlignment: crossStart,
                children: [
                  TextWidget(Strings.speed, fontSize: Dimensions.titleSmall),
                  TextWidget('1020/hp', fontWeight: FontWeight.bold),
                  TextWidget(
                    Strings.peakPower,
                    fontSize: Dimensions.titleSmall,
                  ),
                ],
              ),
            ],
          ),
          Wrap(
            children: [
              Icon(Icons.candlestick_chart, size: Dimensions.iconSizeDefault),
              Sizes.width.v5,
              Column(
                crossAxisAlignment: crossStart,
                children: [
                  TextWidget(
                    Strings.acceleration,
                    fontSize: Dimensions.titleSmall,
                  ),
                  TextWidget('200/mph', fontWeight: FontWeight.bold),
                  TextWidget('0-60 mph', fontSize: Dimensions.titleSmall),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
