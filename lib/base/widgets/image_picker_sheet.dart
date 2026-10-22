import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/basic_import.dart';

class ImagePickerSheet extends StatelessWidget {
  final VoidCallback fromCamera, fromGallery;
  const ImagePickerSheet({
    super.key,
    required this.fromCamera,
    required this.fromGallery,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.horizontalSize),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: InkWell(
                  onTap: fromGallery,
                  child: Animate(
                    effects: const [FadeEffect(), ScaleEffect()],
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(Dimensions.paddingSize * 0.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius * 1.4,
                        ),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.image,
                              color: CustomColor.primary,
                              size: Dimensions.iconSizeLarge,
                            ),
                          ),
                          TextWidget(
                            Strings.fromGallery,
                            color: CustomColor.primary,
                            fontSize: Dimensions.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: InkWell(
                  onTap: fromCamera,
                  child: Animate(
                    effects: const [FadeEffect(), ScaleEffect()],
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(Dimensions.paddingSize * 0.5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius * 1.4,
                        ),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.camera_alt,
                              color: CustomColor.primary,
                              size: Dimensions.iconSizeLarge,
                            ),
                          ),
                          TextWidget(
                            Strings.fromCamera,
                            color: CustomColor.primary,
                            fontSize: Dimensions.titleSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ).paddingSymmetric(vertical: Dimensions.verticalSize * 1.2),
        ),
      ],
    );
  }
}
