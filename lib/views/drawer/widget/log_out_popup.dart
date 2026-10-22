part of '../screen/drawer_screen.dart';

class LogoutDialog extends StatelessWidget {
  LogoutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Dimensions.radius * 1.5),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              width: Dimensions.widthSize * 4.2,
              height: Dimensions.heightSize * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius),
                color: Colors.black,
              ),
            ),
          ),
          Sizes.height.v20,
          TextWidget(
            Strings.logOutAlert,
            typographyStyle: TypographyStyle.titleSmall,
            fontWeight: FontWeight.bold,
            padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.15),
          ),
          TextWidget(
            Strings.areYouSure,
            typographyStyle: TypographyStyle.bodyMedium,
          ),
          Sizes.height.betweenInputBox,
          PrimaryButton(
            title: Strings.cancel,
            onPressed: () {
              Get.close(1);
            },
            buttonColor: Colors.white,
            borderColor: Colors.white,
            buttonTextColor: Colors.black,
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.verticalSize * 0.6,
            ),
            child: Obx(
              () => PrimaryButton(
                title: Strings.logOut,
                isLoading: Get.put(LoginController()).isLoading,
                onPressed: () {
                  Get.put(LoginController()).logOutProcess();
                },
                buttonColor: Colors.red,
                borderColor: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
