import 'package:get/get.dart';

class ProductDetailsController extends GetxController {
  var imageList = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProductImages();
  }

  var selectedTab = "Details".obs;

  void fetchProductImages() async {
    await Future.delayed(const Duration(seconds: 2));
    imageList.value = [
      'https://www.pngall.com/wp-content/uploads/2018/04/Sedan-Transparent.png',
      'https://img.freepik.com/free-psd/silver-sedan-car_53876-84522.jpg',
    ];
  }
}
