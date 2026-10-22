part of '../screen/product_details_screen.dart';

class DetailReview extends GetView<ProductDetailsController> {
  DetailReview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Sizes.height.v10,
          Row(
            children: [
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  controller.selectedTab.value = "Details";
                },
                child: Obx(
                  () => Column(
                    children: [
                      TextWidget(
                        Strings.details,
                        color: controller.selectedTab.value == "Details"
                            ? CustomColor.primary
                            : CustomColor.disableColor,
                        fontSize: Dimensions.titleSmall,
                        fontWeight: FontWeight.bold,
                      ),
                      // Conditional Divider
                      Container(
                        height: 2,
                        width: Dimensions.widthSize * 5,
                        color: controller.selectedTab.value == "Details"
                            ? CustomColor.primary
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
              Sizes.width.v10,
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  controller.selectedTab.value = "Reviews";
                },
                child: Obx(
                  () => Column(
                    children: [
                      TextWidget(
                        Strings.review,
                        color: controller.selectedTab.value == "Reviews"
                            ? CustomColor.primary
                            : CustomColor.disableColor,
                        fontSize: Dimensions.titleSmall,
                        fontWeight: FontWeight.bold,
                      ),
                      // Conditional Divider
                      Container(
                        height: Dimensions.heightSize * 0.2,
                        width: Dimensions.widthSize * 5,
                        color: controller.selectedTab.value == "Reviews"
                            ? CustomColor.primary
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Sizes.height.v10,
          Obx(
            () => TextWidget(
              controller.selectedTab.value == "Details"
                  ? Strings.longText
                  : Strings.longTitle,
              color: CustomColor.blackColor.withValues(alpha: 0.6),
              fontSize: Dimensions.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}
