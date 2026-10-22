import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carbo/base/utils/dimensions.dart';

class DocumentImagePicker extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? imagePath;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final VoidCallback onRemove;
  final bool isRequired;

  const DocumentImagePicker({
    super.key,
    required this.title,
    this.imageUrl,
    this.imagePath,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.onRemove,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = (imagePath != null && imagePath!.isNotEmpty) || 
                     (imageUrl != null && imageUrl!.isNotEmpty);

    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.heightSize),
      padding: EdgeInsets.all(Dimensions.paddingSize),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
             
            ],
          ),
          SizedBox(height: Dimensions.heightSize * 1.2),
          
          // Image Preview
          if (hasImage)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radius),
                child: imagePath != null && imagePath!.isNotEmpty
                    ? Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 50,
                              color: Theme.of(context).disabledColor,
                            ),
                          );
                        },
                      ),
              ),
            ),
          
          SizedBox(height: Dimensions.heightSize * 1.2),
          
          // Action Buttons
          if (!hasImage)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickFromCamera,
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.heightSize * 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.widthSize * 1.2),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickFromGallery,
                    icon: const Icon(Icons.photo_library, size: 18),
                    label: const Text('Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.heightSize * 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showChangeOptions(context);
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Change'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.heightSize * 1.2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.widthSize * 1.2),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        vertical: Dimensions.heightSize * 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showChangeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                onPickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                onPickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}
