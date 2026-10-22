part of '../screen/register_screen.dart';

class CustomCheckboxWidget extends GetView<RegisterController> {
  CustomCheckboxWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => BasicServices.agreePolicy.value == 1
          ? Container(
              margin: EdgeInsets.only(top: Dimensions.heightSize * 0.66),
              child: Row(
                children: [
                  Obx(
                    () => SizedBox(
                      height: 24.0.h,
                      width: 24.0.w,
                      child: Checkbox(
                        value: controller.agree.value,
                        onChanged: (value) {
                          controller.agree.value = value!;
                          print(controller.agree.value);
                        },
                        activeColor: CustomColor.primary,
                        checkColor: controller.agree.value
                            ? Theme.of(context).colorScheme.surface
                            : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius * 0.2,
                          ),
                        ),
                        side: BorderSide(
                          color: Get.isDarkMode
                              ? CustomColor.typographyDark.withValues(
                                  alpha: 0.50,
                                )
                              : CustomColor.typography.withValues(alpha: 0.50),
                        ),
                      ),
                    ),
                  ),
                  Sizes.width.v5,
                  TextWidget(
                    Strings.iHaveAgreedWith,
                    fontSize: Dimensions.titleSmall * 0.9,
                  ),
                  TextWidget(
                    padding: EdgeInsets.only(
                      left: Dimensions.horizontalSize * 0.2,
                    ),
                    Strings.termsOfUse,
                    color: CustomColor.primary,
                    fontSize: Dimensions.titleSmall * 0.9,
                    onTap: () => Get.to(
                      () => WebViewScreen(title: Strings.privacyPolicy),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
