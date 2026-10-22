import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../base/api/services/basic_services.dart';

class SplashImage extends StatelessWidget {
  const SplashImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => CachedNetworkImage(
        imageUrl: BasicServices.splashImage.value,
        placeholder: (context, url) => const Text(''),
        errorWidget: (context, url, error) => const Text(''),
        fit: BoxFit.cover,
      ),
    );
  }
}
