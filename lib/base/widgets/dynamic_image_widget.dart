import 'dart:io';
import 'package:carbo/views/preview/controller/preview_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:r_dotted_line_border/r_dotted_line_border.dart';

import '../../../../base/utils/basic_import.dart';

File? imageFile;

class DynamicImageWidget extends StatefulWidget {
  const DynamicImageWidget({
    super.key,
    required this.labelName,
    required this.fieldName,
  });

  final String labelName;
  final String fieldName;

  @override
  State<DynamicImageWidget> createState() => _DropFileState();
}

class _DropFileState extends State<DynamicImageWidget> {
  final controller = Get.put(PreviewController());

  Future pickImage(imageSource) async {
    try {
      final image = await ImagePicker().pickImage(
        source: imageSource,
        imageQuality: 50,
      );
      if (image == null) return;

      imageFile = File(image.path);

      if (controller.listFieldName.isNotEmpty) {
        if (controller.listFieldName.contains(widget.fieldName)) {
          int itemIndex = controller.listFieldName.indexOf(widget.fieldName);
          controller.listFieldName[itemIndex] = widget.fieldName;
          controller.listImagePath[itemIndex] = imageFile!.path;
        } else {
          controller.listImagePath.add(imageFile!.path);
          controller.listFieldName.add(widget.fieldName);
        }
      } else {
        controller.listImagePath.add(imageFile!.path);
        controller.listFieldName.add(widget.fieldName);
      }
      setState(() {
        controller.updateImageData(widget.fieldName, imageFile!.path);
      });
      Get.back();
      // CustomSnackBar.success('$labelName Added');
    } on PlatformException catch (_) {
      // CustomSnackBar.error('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        _showImagePickerBottomSheet(context);
      },
      child: Container(
        decoration: BoxDecoration(
          border: RDottedLineBorder.all(
            color: Get.isDarkMode
                ? CustomColor.whiteColor.withValues(alpha: 0.2)
                : CustomColor.blackColor.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(Dimensions.radius),
        ),
        child: Container(
          height: Dimensions.heightSize * 12,
          alignment: Alignment.center,
          margin: EdgeInsets.all(Dimensions.horizontalSize * 0.25),
          decoration: controller.getImagePath(widget.fieldName) == null
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(
                      File(controller.getImagePath(widget.fieldName) ?? ''),
                    ),
                  ),
                ),
          child: imageFile == null
              ? Column(
                  mainAxisAlignment: mainCenter,
                  mainAxisSize: mainMin,
                  children: [
                    Icon(
                      Iconsax.gallery_import5,
                      color: Get.isDarkMode
                          ? CustomColor.whiteColor.withValues(alpha: 0.3)
                          : CustomColor.blackColor.withValues(alpha: 0.3),
                    ),
                    TextWidget(
                      'Upload',
                      textOverflow: TextOverflow.fade,
                      color: Get.isDarkMode
                          ? CustomColor.whiteColor.withValues(alpha: 0.2)
                          : CustomColor.blackColor.withValues(alpha: 0.2),
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  _showImagePickerBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          width: double.infinity,
          child: ImagePickerSheet(
            fromCamera: () {
              pickImage(ImageSource.camera);
            },
            fromGallery: () {
              pickImage(ImageSource.gallery);
            },
          ),
        );
      },
    );
  }
}
