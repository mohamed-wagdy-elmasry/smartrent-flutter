import 'package:carbo/views/update_profile/controller/update_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../base/widgets/country_drop_down.dart';
import '../../../base/utils/local_storage.dart';
import '../../../base/utils/size.dart';
import '../../../base/widgets/primary_input_widget.dart';
import '../../../languages/strings.dart';
import 'document_image_picker_widget.dart';

class ProfileInputWidget extends GetView<UpdateProfileController> {
  ProfileInputWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.firstNameController,
                  label: Strings.firstName,
                  hintText: Strings.firstName,
                  textInputType: TextInputType.name,
                  showBorderSide: true,
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.lastNameController,
                  label: Strings.lastName,
                  hintText: Strings.lastName,
                  textInputType: TextInputType.name,
                  showBorderSide: true,
                ),
              ),
            ],
          ),
          Sizes.height.betweenInputBox,
          CountryDropDown(
            label: Strings.Country,
            itemsList: controller.countryList,
            selectMethod: controller.countrySelectMethod,
            onChanged: (v) {
              controller.countrySelectMethod.value = v!.name;
              controller.mobileCode.value = v.mobileCode;
              LocalStorage.save(userCountryCode: v.mobileCode);
              print(controller.mobileCode);
            },
          ),
          Sizes.height.betweenInputBox,
          PrimaryInputWidget(
            controller: controller.mobileController,
            label: Strings.Phone,
            hintText: Strings.Phone,
            textInputType: TextInputType.phone,
            showBorderSide: true,
          ),
          Sizes.height.betweenInputBox,
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.addressController,
                  label: Strings.Address,
                  hintText: Strings.Address,
                  textInputType: TextInputType.streetAddress,
                  showBorderSide: true,
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.cityController,
                  label: Strings.City,
                  hintText: Strings.City,
                  textInputType: TextInputType.text,
                  showBorderSide: true,
                ),
              ),
            ],
          ),
          Sizes.height.betweenInputBox,
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.stateController,
                  label: Strings.State,
                  hintText: Strings.State,
                  textInputType: TextInputType.text,
                  showBorderSide: true,
                ),
              ),
              Sizes.width.v10,
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.zipCodeController,
                  label: Strings.ZipCode,
                  hintText: Strings.ZipCode,
                  textInputType: TextInputType.number,
                  showBorderSide: true,
                ),
              ),
            ],
          ),
          // Document Uploads Section
          Sizes.height.betweenInputBox,
          _buildDocumentUploadsSection(),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Document Uploads',
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          'Upload your documents for faster verification',
          style: Get.textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
        Sizes.height.betweenInputBox,
        
        // National ID Image Picker
        Obx(() => DocumentImagePicker(
          title: 'National ID',
          imageUrl: controller.nationalIdImageUrl.value.isNotEmpty 
              ? controller.nationalIdImageUrl.value 
              : null,
          imagePath: controller.nationalIdPath.value.isNotEmpty 
              ? controller.nationalIdPath.value 
              : null,
          onPickFromCamera: () => controller.pickNationalIdImage(ImageSource.camera),
          onPickFromGallery: () => controller.pickNationalIdImage(ImageSource.gallery),
          onRemove: controller.removeNationalId,
          isRequired: false,
        )),
        
        // Driving License Image Picker
        Obx(() => DocumentImagePicker(
          title: 'Driving License',
          imageUrl: controller.drivingLicenseImageUrl.value.isNotEmpty 
              ? controller.drivingLicenseImageUrl.value 
              : null,
          imagePath: controller.drivingLicensePath.value.isNotEmpty 
              ? controller.drivingLicensePath.value 
              : null,
          onPickFromCamera: () => controller.pickDrivingLicenseImage(ImageSource.camera),
          onPickFromGallery: () => controller.pickDrivingLicenseImage(ImageSource.gallery),
          onRemove: controller.removeDrivingLicense,
          isRequired: false,
        )),
      ],
    );
  }

}
