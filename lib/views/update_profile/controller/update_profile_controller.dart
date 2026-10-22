import 'dart:io';
import 'package:carbo/base/utils/basic_import.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/api/model/common_success_model.dart';
import '../../../base/utils/local_storage.dart';
import '../../auth/register/controller/register_controller.dart';
import '../model/profile_info_model.dart';

class UpdateProfileController extends GetxController {
  final regController = Get.put(RegisterController());
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipCodeController = TextEditingController();
  final addressController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  RxBool isFormValid = false.obs;
  RxString displayName = ''.obs;
  List<Country> countryList = [];

  RxString countrySelectMethod = ''.obs;
  RxString userEmail = ''.obs;
  RxString userCountry = Strings.locationNotAbleAble.obs;
  RxString userCity = ''.obs;
  RxString mobileCode = ''.obs;
  RxBool isAvailableUserImage = false.obs;
  RxString userImage = ''.obs;
  RxString nationalIdImageUrl = ''.obs;
  RxString drivingLicenseImageUrl = ''.obs;
  
  // Image paths for upload
  RxString imagePath = ''.obs;
  RxBool isImagePathSet = false.obs;
  RxString nationalIdPath = ''.obs;
  RxBool isNationalIdPathSet = false.obs;
  RxString drivingLicensePath = ''.obs;
  RxBool isDrivingLicensePathSet = false.obs;

  @override
  void onInit() {
    super.onInit();
    firstNameController.addListener(_updateFormValidity);
    lastNameController.addListener(_updateFormValidity);
    getProfileInfo();
  }

  void _updateFormValidity() {
    isFormValid.value =
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty;
    displayName.value =
        '${firstNameController.text} ${lastNameController.text}'.trim();
  }

  // Get Profile Info
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  late ProfileInfoModel _profileInfoModel;

  ProfileInfoModel get profileInfoModel => _profileInfoModel;

  Future<ProfileInfoModel?> getProfileInfo() async {
    try {
      return await RequestProcess().request<ProfileInfoModel>(
        fromJson: ProfileInfoModel.fromJson,
        apiEndpoint: ApiEndpoint.profileInfo,
        isLoading: _isLoading,
        onSuccess: (value) {
          if (value == null) {
            return;
          }
          _profileInfoModel = value;
          _setProfileData();
        },
        onError: (error) {
          // Error handled by RequestProcess
        },
      );
    } catch (e) {
      return null;
    }
  }

  void _setProfileData() {
    var userInfo = _profileInfoModel.data.userInfo;
    var imagePaths = _profileInfoModel.data.imagePaths;
    
    firstNameController.text = userInfo.firstname;
    lastNameController.text = userInfo.lastname;
    zipCodeController.text = userInfo.postalCode;
    addressController.text = userInfo.address;
    cityController.text = userInfo.city;
    mobileController.text = userInfo.mobile ?? '';
    stateController.text = userInfo.state;
    countrySelectMethod.value = userInfo.country;
    userCity.value = userInfo.city;
    mobileCode.value = userInfo.mobileCode ?? '';
    
    LocalStorage.save(email: userInfo.email);
    if (userInfo.image != null && userInfo.image != '') {
      userImage.value =
          "${imagePaths.baseUrl}/${imagePaths.pathLocation}/${userInfo.image}";

      isAvailableUserImage.value = true;
    } else {
      userImage.value = "${imagePaths.baseUrl}/${imagePaths.defaultImage}";
    }

    // Set document image URLs
    if (userInfo.nationalIdImage != null && userInfo.nationalIdImage!.isNotEmpty) {
      nationalIdImageUrl.value = "${imagePaths.baseUrl}/${imagePaths.pathLocation}/${userInfo.nationalIdImage}";
    }
    if (userInfo.drivingLicenseImage != null && userInfo.drivingLicenseImage!.isNotEmpty) {
      drivingLicenseImageUrl.value = "${imagePaths.baseUrl}/${imagePaths.pathLocation}/${userInfo.drivingLicenseImage}";
    }

    _profileInfoModel.data.countries?.forEach((element) {
      countryList.add(
        Country(
          id: element.id,
          name: element.name,
          mobileCode: element.mobileCode,
          currencyName: element.currencyName,
          currencyCode: element.currencyCode,
          currencySymbol: element.currencySymbol,
        ),
      );
    });
  }

  // Profile Update

  final _isUpdateLoading = false.obs;

  bool get isUpdateLoading => _isUpdateLoading.value;

  late CommonSuccessModel _commonSuccessModel;

  CommonSuccessModel get commonSuccessModel => _commonSuccessModel;

  Future<CommonSuccessModel?> updateProfile() async {
    Map<String, dynamic> inputBody = {
      'firstname': firstNameController.text,
      'lastname': lastNameController.text,
      'mobile_code': mobileCode.value,
      'mobile': mobileController.text,
      'city': cityController.text,
      'state': stateController.text,
      'zip_code': zipCodeController.text,
      'address': addressController.text,
      'country': countrySelectMethod.value,
    };

    // Prepare file fields and paths
    List<String> fieldList = [];
    List<String> pathList = [];
    
    if (isImagePathSet.value) {
      fieldList.add('image');
      pathList.add(imagePath.value);
    }
    if (isNationalIdPathSet.value) {
      fieldList.add('national_id_image');
      pathList.add(nationalIdPath.value);
    }
    if (isDrivingLicensePathSet.value) {
      fieldList.add('driving_license_image');
      pathList.add(drivingLicensePath.value);
    }

    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.updateProfile,
      isLoading: _isUpdateLoading,
      method: HttpMethod.POST,
      fieldList: fieldList.isNotEmpty ? fieldList : null,
      pathList: pathList.isNotEmpty ? pathList : null,
      body: inputBody,
      showSuccessMessage: true,
      onSuccess: (value) {
        if (value == null) return;
        _commonSuccessModel = value;
        LocalStorage.save(number: mobileController.text);
        getProfileInfo();
      },
    );
  }

  // Profile Image Picker
  final ImagePicker _picker = ImagePicker();

  Future<void> pickProfileImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();
      
      if (fileSize > 5 * 1024 * 1024) {
        CustomSnackBar.error('File size must be less than 5MB');
        return;
      }
      
      imagePath.value = image.path;
      isImagePathSet.value = true;
    }
  }

  void removeProfileImage() {
    imagePath.value = '';
    isImagePathSet.value = false;
  }

  // National ID Image Picker
  Future<void> pickNationalIdImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();
      
      if (fileSize > 5 * 1024 * 1024) {
        CustomSnackBar.error('File size must be less than 5MB');
        return;
      }
      
      nationalIdPath.value = image.path;
      isNationalIdPathSet.value = true;
    }
  }

  void removeNationalId() {
    nationalIdPath.value = '';
    isNationalIdPathSet.value = false;
  }

  // Driving License Image Picker
  Future<void> pickDrivingLicenseImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (image != null) {
      final file = File(image.path);
      final fileSize = await file.length();
      
      if (fileSize > 5 * 1024 * 1024) {
        CustomSnackBar.error('File size must be less than 5MB');
        return;
      }
      
      drivingLicensePath.value = image.path;
      isDrivingLicensePathSet.value = true;
    }
  }

  void removeDrivingLicense() {
    drivingLicensePath.value = '';
    isDrivingLicensePathSet.value = false;
  }

  @override
  void onClose() {
    // Remove listeners and dispose controllers to avoid callbacks after dispose
    try {
      firstNameController.removeListener(_updateFormValidity);
    } catch (_) {}
    try {
      lastNameController.removeListener(_updateFormValidity);
    } catch (_) {}
    try {
      mobileController.removeListener(_updateFormValidity);
    } catch (_) {}

    firstNameController.dispose();
    lastNameController.dispose();
    mobileController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipCodeController.dispose();
    addressController.dispose();

    super.onClose();
  }

  // Set Image - Legacy support
  File? pickedFile;
  ImagePicker imagePicker = ImagePicker();

  void setImagePath(String path) {
    imagePath.value = path;
    isImagePathSet.value = true;
  }

  // Legacy image picker function - use pickProfileImage instead
  Future pickImage(imageSource) async {
    await pickProfileImage(imageSource);
  }
}
