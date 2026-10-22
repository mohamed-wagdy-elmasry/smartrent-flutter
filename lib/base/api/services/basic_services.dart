import '../../../views/auth/auth_model/bassic_setting_model.dart';
import '../../themes/model.dart';
import '../../utils/basic_import.dart';
import '../endpoint/api_endpoint.dart';
import '../method/request_process.dart';

class BasicServices {
  static final List<OnboardScreen> onboardScreen = [];
  static RxString splashImage = ''.obs;
  static RxString appBasicLogoWhite = ''.obs;
  static RxString appBasicLogoDark = ''.obs;
  static RxString appLauncher = ''.obs;
  static RxString privacyPolicy = ''.obs;
  static RxString contactUs = ''.obs;
  static RxString aboutUs = ''.obs;
  static RxString basePath = ''.obs;
  static RxString pathLocation = ''.obs;
  static RxString siteName = ''.obs;
  static RxInt agreePolicy = (1).obs;
  static RxInt userIsRegister = (1).obs;
  static RxInt precision = (1).obs;
  static RxString baseColor = ''.obs;
  static RxString baseCurCode = ''.obs;

  // GET BASIC SETTING INFO - - - - - - - - - - - - - - - - -
  static final _isLoading = false.obs;

  static bool get isLoading => _isLoading.value;

  static late BasicSettingsModel _basicSettingsModel;

  static BasicSettingsModel get basicSettingsModel => _basicSettingsModel;

  static Future<BasicSettingsModel?> getBasicSettingsInfo() async {
    return RequestProcess().request<BasicSettingsModel>(
      fromJson: BasicSettingsModel.fromJson,
      apiEndpoint: ApiEndpoint.basicSettings,
      isLoading: _isLoading,
      showSuccessMessage: false,
      onSuccess: (value) {
        _basicSettingsModel = value!;

        // SET ALL DATA - - - - - - - - - - - - - - - - -
        agreePolicy.value = _basicSettingsModel.data.basicSettings.agreePolicy;
        precision.value = _basicSettingsModel.data.basicSettings.precision;
        userIsRegister.value =
            _basicSettingsModel.data.basicSettings.userRegister;
        onboardScreen.clear();
        basePath.value = _basicSettingsModel.data.imagePaths.basePath;
        pathLocation.value =
            _basicSettingsModel.data.appImagePaths.pathLocation;
        var splash = _basicSettingsModel.data.splashScreen.image;
        splashImage.value = "${basePath.value}/$pathLocation/$splash";

        privacyPolicy.value = _basicSettingsModel.data.webLinks.privacyPolicy;
        contactUs.value = _basicSettingsModel.data.webLinks.contactUs;
        aboutUs.value = _basicSettingsModel.data.webLinks.aboutUs;
        baseCurCode.value = _basicSettingsModel.data.baseCur.code;

        var imagePaths = _basicSettingsModel.data.imagePaths;
        var siteLogo = _basicSettingsModel.data.basicSettings.siteLogo;
        var siteLogoDark = _basicSettingsModel.data.basicSettings.siteLogoDark;

        siteName.value = _basicSettingsModel.data.basicSettings.siteName;
        appBasicLogoWhite.value =
            '${imagePaths.basePath}/${imagePaths.pathLocation}/${siteLogo}';
        appBasicLogoDark.value =
            '${imagePaths.basePath}/${imagePaths.pathLocation}/${siteLogoDark}';
        appLauncher.value =
            '${imagePaths.basePath}/${imagePaths.pathLocation}/${siteLogo}';

        Strings.appName = siteName.value;

        if (_basicSettingsModel.data.onboardScreens.isNotEmpty) {
          for (var element in _basicSettingsModel.data.onboardScreens) {
            onboardScreen.add(
              OnboardScreen(
                title: element.title,
                subTitle: element.subTitle,
                image: element.image,
                status: element.status,
              ),
            );
          }
        }
        if (baseColor.value.isNotEmpty &&
            RegExp(
              r'^#?([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$',
            ).hasMatch(baseColor.value)) {
          CustomColor.primary = HexColor(baseColor.value);
          CustomColor.primaryDark = HexColor(baseColor.value);
        } else {
          // Default primary color updated to match app logo (deep blue)
          CustomColor.primary = HexColor('#0B5FA5');
          // Keep an appropriate dark variant
          CustomColor.primaryDark = HexColor('#083661');
        }
      },
    );
  }
}
