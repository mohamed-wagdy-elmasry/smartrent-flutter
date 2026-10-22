part of '../screen/drawer_screen.dart';

class ProfileHeaderWidget extends GetView<DashboardController> {
  const ProfileHeaderWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Get.back();
        Get.toNamed(Routes.update_profileScreen);
      },
      child: Column(
        children: [
          Sizes.height.v30,
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 2, color: CustomColor.primary),
          ),
          child: AppCachedImage(
            imageUrl: controller.userProfileImage.value,
            width: Dimensions.radius * 9,
            height: Dimensions.radius * 9,
            fit: BoxFit.cover,
            shape: BoxShape.circle,
            useShimmer: true,
            errorWidget: AppCachedImage(
              imageUrl: controller.userDefaultImageUrl.value,
              width: Dimensions.radius * 9,
              height: Dimensions.radius * 9,
              fit: BoxFit.cover,
              shape: BoxShape.circle,
              useShimmer: false,
            ),
          ),
        ),
        Sizes.height.v10,
        Column(
          crossAxisAlignment: crossStart,
          children: [
            TextWidget(
              controller.userFullName.value,
              fontSize: Dimensions.titleLarge,
              fontWeight: FontWeight.w500,
            ),
            TextWidget(
              controller.userEmail.value,
              fontSize: Dimensions.titleSmall,
            ),
          ],
        ),
      ],
    ),
  );
}
}
