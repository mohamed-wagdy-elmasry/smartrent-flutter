import 'package:flutter/material.dart';
import '../../../base/utils/basic_import.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../controller/profile_completion_controller.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class ProfileCompletionScreen extends StatelessWidget {
  const ProfileCompletionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: ProfileCompletionMobileScreen(),
      tablet: ProfileCompletionMobileScreen(),
    );
  }
}

class ProfileCompletionMobileScreen extends StatelessWidget {
  const ProfileCompletionMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileCompletionController>();

    return Scaffold(
      backgroundColor: CustomColor.whiteColor,
      appBar: AppBar(
        title: Text(
          DynamicLanguage.key(Strings.completeYourProfile),
          style: TextStyle(
            fontSize: Dimensions.titleLarge,
            color: CustomColor.typography,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(controller),
    );
  }

  Widget _buildBody(ProfileCompletionController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Dimensions.paddingSize),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: Dimensions.heightSize * 2),
            
            Text(
              DynamicLanguage.key(Strings.pleaseCompleteYourProfile),
              style: TextStyle(
                fontSize: Dimensions.titleMedium,
                color: CustomColor.typographyShade[40],
              ),
            ),

            SizedBox(height: Dimensions.heightSize * 3),

            _buildLabel(DynamicLanguage.key(Strings.firstName)),
            SizedBox(height: Dimensions.heightSize * 0.5),
            TextFormField(
              controller: controller.firstnameController,
              decoration: InputDecoration(
                hintText: DynamicLanguage.key(Strings.enterYourFirstName),
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
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: DynamicLanguage.key(Strings.firstNameRequired)),
                FormBuilderValidators.minLength(2, errorText: 'Must be at least 2 characters'),
                FormBuilderValidators.maxLength(50, errorText: 'Maximum 50 characters'),
              ]),
            ),

            SizedBox(height: Dimensions.heightSize * 2),

            _buildLabel(DynamicLanguage.key(Strings.lastName)),
            SizedBox(height: Dimensions.heightSize * 0.5),
            TextFormField(
              controller: controller.lastnameController,
              decoration: InputDecoration(
                hintText: DynamicLanguage.key(Strings.enterYourLastName),
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
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: DynamicLanguage.key(Strings.lastNameRequired)),
                FormBuilderValidators.minLength(2, errorText: 'Must be at least 2 characters'),
                FormBuilderValidators.maxLength(50, errorText: 'Maximum 50 characters'),
              ]),
            ),

            SizedBox(height: Dimensions.heightSize * 2),

            _buildLabel(DynamicLanguage.key(Strings.email)),
            SizedBox(height: Dimensions.heightSize * 0.5),
            TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: DynamicLanguage.key(Strings.enterYourEmailAddress),
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
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: DynamicLanguage.key(Strings.emailRequired)),
                FormBuilderValidators.email(errorText: DynamicLanguage.key(Strings.invalidEmail)),
              ]),
            ),

            SizedBox(height: Dimensions.heightSize * 4),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: Dimensions.buttonHeight,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.primary,
                    disabledBackgroundColor: CustomColor.primary.withOpacity(0.6),
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
                          DynamicLanguage.key(Strings.continuee),
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: Dimensions.titleSmall,
        fontWeight: FontWeight.w600,
        color: CustomColor.typography,
      ),
    );
  }
}
