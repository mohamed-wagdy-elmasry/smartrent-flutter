part of '../screen/dashboard_screen.dart';

class CarCarouselSlider extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    final double sliderHeight = MediaQuery.of(context).size.height * 0.28;
    return Obx(() {
      return controller.cars.isNotEmpty
          ? CarouselSlider.builder(
              itemCount: controller.cars.length,
              itemBuilder: (context, index, realIndex) {
                final car = controller.cars[index];
                return InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    if (!LocalStorage.isLoggedIn) {
                      Get.toNamed(Routes.otpLoginScreen);
                      return;
                    }
                    controller.selectedCarId.value = car.id.toString();
                    Get.toNamed(Routes.bookingScreen);
                  },
                  child: AnimatedContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.defaultHorizontalSize,
                      vertical: Dimensions.verticalSize * 0.35,
                    ),
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.2,
                      maxHeight: sliderHeight,
                    ),
                    duration: Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      color: CustomColor.whiteColor,
                      borderRadius: BorderRadius.circular(
                        Dimensions.radius * 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius * 1.2,
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  (controller.carImgUrl.isNotEmpty &&
                                      car.image != null &&
                                      car.image!.trim().isNotEmpty &&
                                      car.image!.toLowerCase() != 'null')
                                  ? '${controller.carImgUrl}${car.image}'
                                  : (car.imagesOrPlaceholder.isNotEmpty
                                        ? car.imagesOrPlaceholder.first
                                        : 'https://via.placeholder.com/150'),
                              placeholder: (context, url) =>
                                  const Center(child: Loader()),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error, color: Colors.red),
                              height: MediaQuery.of(context).size.height * 0.11,
                            ),
                          ),
                        ),
                        Sizes.height.v5,
                        TextWidget(
                          color: CustomColor.blackColor,
                          fontSize: Dimensions.titleSmall,
                          car.carType +
                              ' ' +
                              car.carModel +
                              ' ' +
                              car.carYear.toString(),
                          maxLines: 1,
                          textOverflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                        Sizes.height.v5,
                        // Flexible(
                        //   child: _section(Strings.CarNumber, car.carNumber??'N/A'),
                        // ),
                        Flexible(
                          child: _section(
                            Strings.totalSeat,
                            '${car.seat} ${DynamicLanguage.key(Strings.seat)}',
                          ),
                        ),
                        Flexible(
                          child: _section(
                            Strings.kmCharge,
                            '${double.tryParse(car.fees)?.toStringAsFixed(2) ?? '0.00'} USD',
                          ),
                        ),
                        // Flexible(
                        //   child: _section(
                        //     Strings.experience,
                        //     '${car.experience} ${DynamicLanguage.key(Strings.year)}',
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                enableInfiniteScroll: false,
                height: sliderHeight,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 0.6,
                onPageChanged: (index, reason) {},
              ),
            )
          : Center(child: Lottie.asset('assets/background/ani.json'));
    });
  }

  _section(String title, String value) {
    return Row(
      children: [
        SvgPicture.asset(
          Assets.icons.verified,
          height: Dimensions.iconSizeLarge * 0.75,
          color: CustomColor.primary,
        ),
        Sizes.width.v5,
        Wrap(
          spacing: 5,
          children: [
            TextWidget(
              color: CustomColor.blackColor,
              title,
              fontWeight: FontWeight.w500,
              fontSize: Dimensions.titleSmall * 0.8,
            ),
            TextWidget(
              color: CustomColor.blackColor,
              value,
              fontWeight: FontWeight.w500,
              fontSize: Dimensions.titleSmall * 0.8,
            ),
          ],
        ),
      ],
    );
  }
}
