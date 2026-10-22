import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/api/model/common_success_model.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../../congratulations/model/congratulations_model.dart';
import '../../congratulations/screen/congratulations_screen.dart';
import '../model/notification_model.dart';
import '../model/re_payment_input_fields_model.dart';
import '../widget/get_manual_dynamic_input_field.dart';

class NotificationController extends GetxController {
  @override
  void onInit() {
    getNotificationInfo();
    super.onInit();
  }

  RxString trxId = ''.obs;
  final _isLoading = false.obs;
  final _hasError = false.obs;

  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;

  NotificationModel? _notificationModel;

  NotificationModel? get notificationModel => _notificationModel;
  bool get hasNotifications => _notificationModel?.data.notification.isNotEmpty ?? false;

  Future<NotificationModel?> getNotificationInfo() async {
    _hasError.value = false;
    return RequestProcess().request<NotificationModel>(
      fromJson: NotificationModel.fromJson,
      apiEndpoint: ApiEndpoint.notification,
      isLoading: _isLoading,
      onSuccess: (value) {
        if (value != null) {
          _notificationModel = value;
          // Only set trxId if notifications list is not empty
          if (_notificationModel!.data.notification.isNotEmpty) {
            trxId.value = _notificationModel!.data.notification.first.message.trxId ?? '';
          }
        }
      },
      onError: (error) {
        _hasError.value = true;
        _notificationModel = null;
      },
    );
  }

  List<TextEditingController> inputFieldControllers = [];
  RxList inputFields = [].obs;
  RxList inputFileFields = [].obs;
  RxBool hasFile = false.obs;
  RxString selectType = "".obs;
  List<String> listImagePath = [];
  List<String> listFieldName = [];

  final _isRepaymentLoading = false.obs;

  bool get isRepaymentLoading => _isRepaymentLoading.value;

  RePaymentInputFields? _rePaymentInputFields;

  RePaymentInputFields? get rePaymentInputFields => _rePaymentInputFields;

  Future<RePaymentInputFields?> rePaymentManualInsert() async {
    // Validate trxId before proceeding
    if (trxId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Transaction ID is missing. Cannot process repayment.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    return RequestProcess().request<RePaymentInputFields>(
      fromJson: RePaymentInputFields.fromJson,
      apiEndpoint: ApiEndpoint.rePayment,
      isLoading: _isRepaymentLoading,
      showSuccessMessage: false,
      showResult: true,
      queryParams: {'trx_id': trxId.value},
      onSuccess: (value) {
        if (value != null) {
          _rePaymentInputFields = value;
          getManualReDynamicInputField(
            data: _rePaymentInputFields!.data.inputFields,
            inputFieldControllers: inputFieldControllers,
            inputFields: inputFields,
            inputFileFields: inputFileFields,
            hasFile: hasFile,
            selectType: selectType,
          );
          Get.toNamed(Routes.RePaymentManualField);
        }
      },
      onError: (error) {
        Get.snackbar(
          'Repayment Error',
          'Failed to load repayment form. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
  }

  late CommonSuccessModel _commonSuccessModel;

  CommonSuccessModel get commonSuccessModel => _commonSuccessModel;

  Future<CommonSuccessModel?> rePaymentProcess() async {
    // Validate that input fields are loaded before processing
    if (_rePaymentInputFields == null) {
      Get.snackbar(
        'Error',
        'Repayment form not loaded. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    Map<String, String> inputBody = {'trx_id': trxId.value};
    final data = _rePaymentInputFields!.data.inputFields;

    for (int i = 0; i < data.length; i += 1) {
      if (data[i].type != 'file') {
        inputBody[data[i].name] = inputFieldControllers[i].text;
      }
    }
    inputFileFields.clear();
    inputFields.clear();
    listImagePath.clear();
    listFieldName.clear();
    inputFieldControllers.clear();
    update();

    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.manualRePayment,
      isLoading: _isRepaymentLoading,
      method: HttpMethod.POST,
      body: inputBody,
      fieldList: listFieldName,
      pathList: listImagePath,
      onSuccess: (value) {
        inputFields.clear();
        listImagePath.clear();
        listFieldName.clear();
        inputFieldControllers.clear();
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  }

  void _confirmation(CommonSuccessModel commonSuccessModel) {
    Congratulation congratulation = Congratulation(
      details: commonSuccessModel.message.success.first,
      route: Routes.dashboardScreen,
      buttonText: Strings.backToHome,
      type: Strings.payment,
    );

    Get.to(() => CongratulationsScreen(), arguments: congratulation);
  }
}
