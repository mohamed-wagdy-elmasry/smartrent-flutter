part of '../screen/all_vendors_dashboard_screen.dart';

class AllVendorsCarCarousel extends GetView<AllVendorsDashboardController> {
  const AllVendorsCarCarousel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double sliderHeight = MediaQuery.of(context).size.height * 0.28;

    return Obx(() {
      return controller.vendorCars.isNotEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize,
                  ),
                  child: Text(
                    'Available Cars (${controller.vendorCars.length})',
                    style: TextStyle(
                      fontSize: Dimensions.titleLarge,
                      fontWeight: FontWeight.bold,
                      color: CustomColor.typography.withOpacity(0.8),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.verticalSize),
                CarouselSlider.builder(
                  itemCount: controller.vendorCars.length,
                  itemBuilder: (context, index, realIndex) {
                    final car = controller.vendorCars[index];
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        // Store selected car ID for booking
                        controller.selectedCarId.value = car.id.toString();
                        try {
                          final dashController =
                              Get.find<DashboardController>();
                          dashController.selectedCarId.value = car.id
                              .toString();
                          dashController.carToken.value =
                              controller.carToken.value;
                        } catch (e) {
                          // DashboardController may not be loaded yet
                        }
                        
                        // Initialize booking controller with selected car
                        try {
                          final bookingController = Get.find<BookingController>();
                          bookingController.initializeWithCar(car);
                        } catch (e) {
                          // BookingController not yet initialized
                        }
                        
                        if (!LocalStorage.isLoggedIn) {
                          Get.toNamed(Routes.otpLoginScreen);
                          return;
                        }
                        Get.toNamed(Routes.bookingScreen, arguments: {'car': car});
                      },
                      child: Container(
                        padding: EdgeInsets.all(
                          Dimensions.defaultHorizontalSize,
                        ),
                        margin: EdgeInsets.symmetric(
                          horizontal: Dimensions.horizontalSize * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: CustomColor.whiteColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Car Image
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  Dimensions.radius * 0.5,
                                ),
                                child: Builder(
                                  builder: (context) {
                                    final imageUrl = car.modelImage?.trim() ?? '';
                                    
                                    return AppCachedImage(
                                      imageUrl: imageUrl,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.contain,
                                      borderRadius: BorderRadius.circular(
                                        Dimensions.radius * 0.5,
                                      ),
                                      useShimmer: true,
                                      fadeIn: true,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: Dimensions.verticalSize * 0.5),

                            // Car Title
                            Text(
                              car.displayName,
                              style: TextStyle(
                                fontSize: Dimensions.titleMedium,
                                fontWeight: FontWeight.bold,
                                color: CustomColor.typography,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: Dimensions.verticalSize * 0.3),

                            // Car Details
                            Row(
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: Dimensions.iconSizeDefault * 0.7,
                                  color: CustomColor.primary,
                                ),
                                SizedBox(
                                  width: Dimensions.horizontalSize * 0.3,
                                ),
                                Text(
                                  '${car.type} • ${car.year}',
                                  style: TextStyle(
                                    fontSize: Dimensions.bodySmall,
                                    color: CustomColor.typography.withOpacity(
                                      0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimensions.verticalSize * 0.3),

                            // Seats and Fee
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.event_seat,
                                      size: Dimensions.iconSizeDefault * 0.7,
                                      color: CustomColor.primary,
                                    ),
                                    SizedBox(
                                      width: Dimensions.horizontalSize * 0.3,
                                    ),
                                    Text(
                                      '${car.seats} ${DynamicLanguage.key(Strings.seats)}',
                                      style: TextStyle(
                                        fontSize: Dimensions.bodySmall,
                                        color: CustomColor.typography
                                            .withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  car.formattedPrice,
                                  style: TextStyle(
                                    fontSize: Dimensions.titleMedium,
                                    fontWeight: FontWeight.bold,
                                    color: CustomColor.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: sliderHeight,
                    viewportFraction: 0.85,
                    enlargeCenterPage: true,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      controller.currentIndex.value = index;
                      controller.selectedCarIndex.value = index;
                    },
                  ),
                ),
                SizedBox(height: Dimensions.verticalSize),

                // Book Now Button
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.defaultHorizontalSize * 2,
                  ),
                  child: PrimaryButton(
                    title: DynamicLanguage.key(Strings.bookNow),
                    onPressed: () {
                      if (controller.vendorCars.isNotEmpty) {
                        final car = controller
                            .vendorCars[controller.selectedCarIndex.value];
                        controller.selectedCarId.value = car.id.toString();
                        try {
                          final dashController =
                              Get.find<DashboardController>();
                          dashController.selectedCarId.value = car.id
                              .toString();
                          dashController.carToken.value =
                              controller.carToken.value;
                        } catch (e) {
                          // DashboardController may not be loaded yet
                        }
                        
                        // Initialize booking controller with selected car
                        try {
                          final bookingController = Get.find<BookingController>();
                          bookingController.initializeWithCar(car);
                        } catch (e) {
                          // BookingController not yet initialized
                        }
                        
                        if (!LocalStorage.isLoggedIn) {
                          Get.toNamed(Routes.otpLoginScreen);
                          return;
                        }
                        Get.toNamed(Routes.bookingScreen, arguments: {'car': car});
                      }
                    },
                  ),
                ),
              ],
            )
          : SizedBox();
    });
  }
}
