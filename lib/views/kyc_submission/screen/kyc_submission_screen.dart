import 'package:flutter/material.dart';
import '../../../base/api/model/kyc_model.dart';
import '../../../base/utils/basic_import.dart';
import '../controller/kyc_submission_controller.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class KycSubmissionScreen extends StatelessWidget {
  const KycSubmissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: KycSubmissionMobileScreen(),
      tablet: KycSubmissionMobileScreen(),
    );
  }
}

class KycSubmissionMobileScreen extends StatelessWidget {
  const KycSubmissionMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<KycSubmissionController>();

    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        title: Text(
          'Submit KYC Documents',
          style: TextStyle(
            fontSize: Dimensions.titleLarge,
            color: CustomColor.typography,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingFields.value) {
          return Center(
            child: CircularProgressIndicator(color: CustomColor.primary),
          );
        }

        if (controller.kycFields.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: CustomColor.typographyShade[40],
                ),
                SizedBox(height: Dimensions.heightSize),
                Text(
                  'KYC fields not available',
                  style: TextStyle(
                    fontSize: Dimensions.titleMedium,
                    color: CustomColor.typographyShade[40],
                  ),
                ),
              ],
            ),
          );
        }

        return _buildBody(controller);
      }),
    );
  }

  Widget _buildBody(KycSubmissionController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.paddingSize),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Dimensions.heightSize * 2),

            Text(
              'Please upload required documents for verification',
              style: TextStyle(
                fontSize: Dimensions.titleMedium,
                color: CustomColor.typographyShade[40],
              ),
            ),

            SizedBox(height: Dimensions.heightSize * 3),

            // Dynamic form fields
            ...controller.kycFields.map((field) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDynamicField(field, controller),
                  SizedBox(height: Dimensions.heightSize * 2),
                ],
              );
            }).toList(),

            // Submit Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: Dimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitKyc,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.primary,
                    disabledBackgroundColor: CustomColor.primary.withOpacity(
                      0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Dimensions.radius),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Submit KYC',
                          style: TextStyle(
                            fontSize: Dimensions.titleMedium,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),

            SizedBox(height: Dimensions.heightSize * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicField(
    KycField field,
    KycSubmissionController controller,
  ) {
    switch (field.type) {
      case KycFieldType.text:
      case KycFieldType.number:
        return _buildTextField(field, controller);

      case KycFieldType.textarea:
        return _buildTextAreaField(field, controller);

      case KycFieldType.date:
        return _buildDateField(field, controller);

      case KycFieldType.select:
        return _buildSelectField(field, controller);

      case KycFieldType.file:
        return _buildFileField(field, controller);

      default:
        return _buildTextField(field, controller);
    }
  }

  Widget _buildTextField(KycField field, KycSubmissionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        TextFormField(
          controller: controller.textControllers[field.name],
          keyboardType: field.type == KycFieldType.number
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.label}',
            filled: true,
            fillColor: CustomColor.typographyShade[0]!.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSize,
              vertical: Dimensions.paddingSize * 0.75,
            ),
          ),
          validator: field.required
              ? FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: '${field.label} is required',
                  ),
                  if (field.maxLength != null)
                    FormBuilderValidators.maxLength(
                      field.maxLength!,
                      errorText: 'Maximum ${field.maxLength} characters',
                    ),
                ])
              : null,
        ),
      ],
    );
  }

  Widget _buildTextAreaField(
    KycField field,
    KycSubmissionController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        TextFormField(
          controller: controller.textControllers[field.name],
          maxLines: 4,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Enter ${field.label}',
            filled: true,
            fillColor: CustomColor.typographyShade[0]!.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.all(Dimensions.paddingSize),
          ),
          validator: field.required
              ? FormBuilderValidators.required(
                  errorText: '${field.label} is required',
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildDateField(KycField field, KycSubmissionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        TextFormField(
          controller: controller.textControllers[field.name],
          readOnly: true,
          decoration: InputDecoration(
            hintText: field.placeholder ?? 'Select ${field.label}',
            filled: true,
            fillColor: CustomColor.typographyShade[0]!.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Dimensions.radius),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSize,
              vertical: Dimensions.paddingSize * 0.75,
            ),
            suffixIcon: Icon(Icons.calendar_today),
          ),
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.textControllers[field.name]!.text =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            }
          },
          validator: field.required
              ? FormBuilderValidators.required(
                  errorText: '${field.label} is required',
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildSelectField(KycField field, KycSubmissionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.selectedValues[field.name],
            decoration: InputDecoration(
              hintText: field.placeholder ?? 'Select ${field.label}',
              filled: true,
              fillColor: CustomColor.typographyShade[0]!.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Dimensions.radius),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSize,
                vertical: Dimensions.paddingSize * 0.75,
              ),
            ),
            items: field.options?.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                controller.selectDropdownValue(field.name, value);
              }
            },
            validator: field.required
                ? FormBuilderValidators.required(
                    errorText: '${field.label} is required',
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFileField(KycField field, KycSubmissionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(field.label, field.required),
        SizedBox(height: Dimensions.heightSize * 0.5),
        Obx(() {
          final hasFile = controller.fileNames.containsKey(field.name);

          return Container(
            decoration: BoxDecoration(
              color: CustomColor.typographyShade[0]!.withOpacity(0.5),
              borderRadius: BorderRadius.circular(Dimensions.radius),
            ),
            padding: EdgeInsets.all(Dimensions.paddingSize),
            child: Column(
              children: [
                if (hasFile) ...[
                  Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: Dimensions.widthSize),
                      Expanded(
                        child: Text(
                          controller.fileNames[field.name]!,
                          style: TextStyle(
                            fontSize: Dimensions.titleSmall,
                            color: CustomColor.typography,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          controller.removeFile(field.name);
                        },
                        icon: Icon(Icons.close, color: Colors.red),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.heightSize),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.pickFile(field.name),
                        icon: Icon(Icons.upload_file),
                        label: Text(hasFile ? 'Change File' : 'Choose File'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomColor.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSize * 0.6,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: Dimensions.widthSize),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => controller.pickImage(field.name),
                        icon: Icon(Icons.camera_alt),
                        label: Text(hasFile ? 'Change Photo' : 'Take Photo'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomColor.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: Dimensions.paddingSize * 0.6,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLabel(String text, bool required) {
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: Dimensions.titleSmall,
          fontWeight: FontWeight.w600,
          color: CustomColor.typography,
        ),
        children: [
          if (required)
            TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }
}
