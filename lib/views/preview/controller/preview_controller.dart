import 'package:carbo/base/utils/local_storage.dart';
import 'package:carbo/views/booking/controller/booking_controller.dart';
import 'package:carbo/views/dashboard/controller/dashboard_controller.dart';
import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/views/preview/model/booking_preview_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../base/widgets/logger.dart';
import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/api/model/common_success_model.dart';
import '../../../languages/strings.dart';
import '../../../routes/routes.dart';
import '../../congratulations/model/congratulations_model.dart';
import '../../congratulations/screen/congratulations_screen.dart';
import '../model/booking_confirm_model.dart';
import '../model/manual_input_model.dart';
import '../screen/preview_screen.dart';
import '../../checkout/checkout_screen.dart';
import '../../../screens/payment/moyasar_payment_handler.dart';
import '../../../services/moyasar_payment_service.dart';

class PreviewController extends GetxController {
  final log = logger(PreviewController);
  final dashboardController = Get.find<DashboardController>();

  List<TextEditingController> inputFieldControllers = [];
  RxList inputFields = [].obs;
  RxList inputFileFields = [].obs;
  RxBool hasFile = false.obs;
  RxString selectType = "".obs;
  List<String> listImagePath = [];
  List<String> listFieldName = [];

  var identifier = "".obs;
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCVCController = TextEditingController();

  updateImageData(String fieldName, String imagePath) {
    if (listFieldName.contains(fieldName)) {
      int itemIndex = listFieldName.indexOf(fieldName);
      listImagePath[itemIndex] = imagePath;
    } else {
      listFieldName.add(fieldName);
      listImagePath.add(imagePath);
    }
    update();
  }

  String? getImagePath(String fieldName) {
    if (listFieldName.contains(fieldName)) {
      int itemIndex = listFieldName.indexOf(fieldName);
      return listImagePath[itemIndex];
    }
    return null;
  }

  Rxn<PaymentGateway> selectPaymentGateway = Rxn<PaymentGateway>();
  final List<PaymentGateway> paymentGatewayList = [];
  Rxn<Currency> selectedCurrency = Rxn<Currency>();
  final List<Currency> currencyList = [];
  
  // Store booking data from new pricing-based booking flow
  Rxn<Map<String, dynamic>> bookingData = Rxn<Map<String, dynamic>>();
  
  // Temporary mobile field for testing
  RxString tempMobile = '01025252525'.obs;

  @override
  void onInit() {
    super.onInit();
    // Check if booking data was passed from booking screen
    if (Get.arguments != null && Get.arguments is Map) {
      bookingData.value = Get.arguments;
      log.i('📥 BookingData received from Get.arguments');
      log.i('  - pickup_date: ${bookingData.value?['pickup_date']}');
      log.i('  - pickup_time: ${bookingData.value?['pickup_time']}');
      log.i('  - Full data keys: ${bookingData.value?.keys.toList()}');
      
      // Initialize totalPayable from booking data
      if (bookingData.value != null && bookingData.value!.containsKey('total')) {
        totalPayable.value = (bookingData.value!['total'] ?? 0).toDouble();
        log.i('Initialized totalPayable from bookingData: ${totalPayable.value}');
      }
      // Initialize car ID from booking data if available
      if (bookingData.value != null) {
        final carId = bookingData.value!['car_id'] ?? bookingData.value!['id'];
        if (carId != null) {
          Id.value = carId.toString();
          log.i('Initialized car ID from bookingData: ${Id.value}');
        }
      }
    } else {
      // Fallback: retrieve booking data from BookingController if not passed via Get.arguments
      try {
        final bookingController = Get.find<BookingController>();
        bookingData.value = bookingController.getBookingData();
        log.i('📥 BookingData retrieved from BookingController');
        log.i('  - pickup_date: ${bookingData.value?['pickup_date']}');
        log.i('  - pickup_time: ${bookingData.value?['pickup_time']}');
        
        totalPayable.value = (bookingData.value?['total'] ?? 0).toDouble();
        
        // Extract car ID from booking data
        final carId = bookingData.value?['car_id'] ?? bookingData.value?['id'];
        if (carId != null) {
          Id.value = carId.toString();
          log.i('Retrieved car ID from BookingController: ${Id.value}');
        }
        
        log.i('Retrieved bookingData from BookingController: ${totalPayable.value}');
      } catch (e) {
        log.w('Could not retrieve booking data from BookingController: $e');
      }
    }
    // Set online payment as default (method = 1)
    selectedMethod.value = 1;
    
    // Fetch wallet balance on preview screen load
    try {
      final walletController = Get.find<WalletController>();
      walletController.fetchBalance();
    } catch (e) {
      log.w('Could not fetch wallet balance: $e');
    }
    
    getPreviewData();
  }

  var selectedMethod = RxInt(1); // Default to online payment

  var paymentType = Rx<PaymentType>(
    PaymentType(onlinePayment: "paytabs", cash: 'cash'),
  );

  String get selectedMethodText {
    totalPayable.value = 0.00;
    // Always return online payment since cash is removed
    return paymentType.value.onlinePayment;
  }

  void changePaymentMethod(int method) {
    selectedMethod.value = method;
  }

  void handlePaymentProcess() {
    // DEBUG: Log the current state
    log.i('=== CONFIRM BOOKING CLICKED ===');
    log.i('alias.value: "${alias.value}"');
    log.i('paymentTypes.value: "${paymentTypes.value}"');
    log.i('Id.value: "${Id.value}"');
    log.i('bookingData.value: ${bookingData.value}');
    log.i('Car ID: ${Id.value}');
    log.i('selectPaymentGateway.value: ${selectPaymentGateway.value}');
    log.i('selectedCurrency.value: ${selectedCurrency.value}');
    log.i('================================');
    
    // Check if car ID is initialized or selected
    if (Id.value.isEmpty || Id.value == '0' || Id.value == 'null') {
      // Defer snackbar to be safe
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'Error',
          'No car selected. Please select a car before booking.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      log.e('ERROR: No car selected - Id: "${Id.value}"');
      return;
    }
    
    // Validate mobile is available
    final String mobileValue = LocalStorage.mobile.isNotEmpty 
        ? LocalStorage.mobile 
        : (bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text);
    
    // Use fallback mobile if empty
    final String finalMobileValue = mobileValue.isNotEmpty ? mobileValue : '01011221122';
    
    if (finalMobileValue.isEmpty) {
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'Error',
          'Mobile number is required to proceed with booking.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      log.e('ERROR: Mobile number is empty');
      return;
    }
    
    // Use wallet payment for all bookings
    log.i('Processing wallet payment');
    bookingProcessWallet();
  }

  Future<void> _processMoyasarPayment() async {
    final result = await Get.to(() => CheckoutScreen(), arguments: {
      'amount': totalPayable.value,
      'description': 'Booking Payment for Car #${Id.value}',
      'mode': 'tokenization',
    });

    if (result != null && result is Map && result.containsKey('token')) {
      final token = result['token'];
      
      if (Get.context != null) {
        final handler = MoyasarPaymentHandler(
          context: Get.context!,
          paymentService: MoyasarPaymentService(
            baseUrl: ApiConfig.mainDomain,
            userToken: LocalStorage.token,
          ),
        );
        
        final bookingToken = bookingData.value?['token'] ?? '';
        final data = _prepareBookingDataForMoyasar(token);
        
        if (data != null) {
          await handler.processPayment(
            bookingToken: bookingToken,
            moyasarCardToken: token,
            bookingData: data,
          );
        }
      }
    }
  }

  Map<String, dynamic>? _prepareBookingDataForMoyasar(String token) {
    // Validate car ID is selected
    if (Id.value.isEmpty || Id.value == '0' || Id.value == 'null') {
      Get.snackbar(
        'Error',
        'No car selected. Please select a car before booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Get token from bookingData
    final String bookingToken = bookingData.value?['token'] ?? '';
    if (bookingToken.isEmpty) {
      Get.snackbar(
        'Error',
        'Booking session expired. Please go back and refresh your booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Prepare email
    final String emailValue = LocalStorage.email.isNotEmpty 
        ? LocalStorage.email 
        : (bookingData.value?['email'] ?? '');

    // Prepare mobile
    final String mobileValue = LocalStorage.mobile.isNotEmpty 
        ? LocalStorage.mobile 
        : (bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text);
    final String finalMobileValue = mobileValue.isNotEmpty ? mobileValue : '01011221122';

    // Safe parsing helpers
    int parseInt(dynamic value, {int def = 0}) {
      if (value == null) return def;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? def;
    }
    
    double parseDouble(dynamic value, {double def = 0.0}) {
      if (value == null) return def;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? def;
    }

    // Determine is_deliver as int (1 or 0)
    int isDeliver = 0;
    final deliveryReq = bookingData.value?['delivery_required'];
    if (deliveryReq != null) {
      if (deliveryReq is bool) {
        isDeliver = deliveryReq ? 1 : 0;
      } else {
        isDeliver = (parseInt(deliveryReq) > 0) ? 1 : 0;
      }
    }

    return {
      'car_id': parseInt(Id.value),
      'car_slug': slug.value.isNotEmpty ? slug.value : 'car-${Id.value}',
      'fees': parseDouble(bookingData.value?['total']),
      'email': emailValue,
      'mobile': finalMobileValue,
      'rental_days': parseInt(bookingData.value?['quantity'], def: 1),
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text,
      'is_deliver': isDeliver,
      'pickup_lat': parseDouble(bookingData.value?['delivery_latitude'] ?? Get.find<BookingController>().pickupLatitude.value),
      'pickup_lng': parseDouble(bookingData.value?['delivery_longitude'] ?? Get.find<BookingController>().pickupLongitude.value),
      'destination': bookingData.value?['destination'] ?? '',
      'distance': parseDouble(bookingData.value?['delivery_distance']),
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text,
      // Invoice breakdown fields
      if (_parseOptionalDouble(bookingData.value?['subtotal']) != null)
        'subtotal': _parseOptionalDouble(bookingData.value?['subtotal']),
      if ((_parseOptionalDouble(bookingData.value?['delivery_charge']) ?? 0) > 0)
        'delivery_fee': _parseOptionalDouble(bookingData.value?['delivery_charge']),
      if ((_parseOptionalDouble(bookingData.value?['tax_amount']) ?? 0) > 0)
        'tax_amount': _parseOptionalDouble(bookingData.value?['tax_amount']),
      if ((_parseOptionalDouble(bookingData.value?['discount_amount']) ?? 0) > 0)
        'discount_amount': _parseOptionalDouble(bookingData.value?['discount_amount']),
    };
  }


  Future<BookingConfirmModel?> bookingProcessMoyasar(String token) async {
    // Validate car ID is selected
    if (Id.value.isEmpty || Id.value == '0' || Id.value == 'null') {
      Get.snackbar(
        'Error',
        'No car selected. Please select a car before booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // include car_area when possible to satisfy backend validation
    final int? _selectedCarAreaId = _getSelectedCarAreaId();
    
    // Get token from bookingData (from preview API response)
    final String bookingToken = bookingData.value?['token'] ?? '';
    
    if (bookingToken.isEmpty) {
      Get.snackbar(
        'Error',
        'Booking session expired. Please go back and refresh your booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Extract pickup date and time safely
    final String pickupDateValue = (bookingData.value?['pickup_date'] is String) ? (bookingData.value?['pickup_date'] as String) : '';
    final String pickupTimeValue = (bookingData.value?['pickup_time'] is String) ? (bookingData.value?['pickup_time'] as String) : '';

    // Prepare email: prioritize LocalStorage, fallback to bookingData, make truly optional
    final String emailValue = LocalStorage.email.isNotEmpty 
        ? LocalStorage.email 
        : (bookingData.value?['email'] ?? '');

    // Prepare mobile: prioritize LocalStorage, use fallback if empty
    final String mobileValue = LocalStorage.mobile.isNotEmpty 
        ? LocalStorage.mobile 
        : (bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text);
    final String finalMobileValue = mobileValue.isNotEmpty ? mobileValue : '01011221122';

    Map<String, dynamic> inputBody = {
      'car_id': int.parse(Id.value), // Required: integer
      'car_slug': slug.value.isNotEmpty ? slug.value : 'car-${Id.value}', // Required: string
      'token': bookingToken, // Required: string
      'mobile': finalMobileValue,
      'pickup_date': pickupDateValue, // Required: date format (YYYY-MM-DD)
      'pickup_time': pickupTimeValue, // Required: string (HH:mm)
      'fees': double.parse((bookingData.value?['total'] ?? 0).toString()), // Required: numeric
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text, // Nullable: string
      'is_deliver': bookingData.value?['delivery_required'] ?? false, // Nullable: boolean
      'destination': bookingData.value?['destination'] ?? '', // Nullable: string
      'distance': bookingData.value?['delivery_distance'] ?? 0, // Nullable: numeric
      'rental_days': bookingData.value?['quantity'], // Nullable: integer
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text, // Nullable: string
      'payment': 'moyasar', // Payment method
      'source_id': token, // Moyasar token
      'transaction_id': token, // Passing token as transaction_id as required by backend
      'gateway_currency': selectedCurrency.value?.alias ?? alias.value, // Use currency alias from API
      'gateway_type': selectPaymentGateway.value?.type ?? 'moyasar',
      'pickup_lat': bookingData.value?['delivery_latitude'] ?? Get.find<BookingController>().pickupLatitude.value,
      'pickup_lng': bookingData.value?['delivery_longitude'] ?? Get.find<BookingController>().pickupLongitude.value,
    };

    // Invoice breakdown fields (sent when known from pricing calculation)
    final double? _subtotal = _parseOptionalDouble(bookingData.value?['subtotal']);
    final double? _deliveryFee = _parseOptionalDouble(bookingData.value?['delivery_charge']);
    final double? _taxAmount = _parseOptionalDouble(bookingData.value?['tax_amount']);
    final double? _discountAmount = _parseOptionalDouble(bookingData.value?['discount_amount']);
    if (_subtotal != null) inputBody['subtotal'] = _subtotal;
    if (_deliveryFee != null && _deliveryFee > 0) inputBody['delivery_fee'] = _deliveryFee;
    if (_taxAmount != null && _taxAmount > 0) inputBody['tax_amount'] = _taxAmount;
    if (_discountAmount != null && _discountAmount > 0) inputBody['discount_amount'] = _discountAmount;
    // Only include credentials if email is available
    if (emailValue.isNotEmpty) inputBody['credentials'] = emailValue;
    if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId;
    
    return RequestProcess().request<BookingConfirmModel>(
      fromJson: BookingConfirmModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        if (value == null) {
          Get.snackbar(
            'Error',
            'Failed to process booking. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        
        _bookingConfirmModel = value;
        
        // Check if this is an error response
        if (_bookingConfirmModel.type == 'error' || _bookingConfirmModel.data == null) {
          String errorMessage = 'Booking confirmation failed.';
          
          // Extract error message from response
          if (_bookingConfirmModel.message?.error != null && 
              _bookingConfirmModel.message!.error!.isNotEmpty) {
            errorMessage = _bookingConfirmModel.message!.error!.first;
          }
          
          Get.snackbar(
            'Booking Error',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
          return;
        }
        
        // Safely check if identifier exists
        if (_bookingConfirmModel.data?.identifier == null || 
            (_bookingConfirmModel.data?.identifier ?? '').isEmpty) {
           // Some successful responses might not have identifier but are still valid
           // Check status or type
           if (_bookingConfirmModel.type == 'success') {
             Get.offAllNamed(
               Routes.congratulationScreen,
               arguments: Congratulation(
                 details: 'Your booking has been confirmed successfully!',
                 route: Routes.historyScreen,
                 buttonText: 'My Bookings',
                 type: 'success',
               ),
             );
             return;
           }
        }
        
        identifier.value = _bookingConfirmModel.data?.identifier ?? '';
        Get.offAllNamed(
          Routes.congratulationScreen,
          arguments: Congratulation(
            details: 'Your booking has been confirmed successfully!',
            route: Routes.historyScreen,
            buttonText: 'My Bookings',
            type: 'success',
          ),
        );
      },
    );
  }

  ///=> WALLET PAYMENT BOOKING PROCESS
  Future<BookingConfirmModel?> bookingProcessWallet() async {
    // Validate car ID is selected
    if (Id.value.isEmpty || Id.value == '0' || Id.value == 'null') {
      Get.snackbar(
        'Error',
        'No car selected. Please select a car before booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Get WalletController instance
    WalletController walletController;
    try {
      walletController = Get.find<WalletController>();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Wallet not initialized. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Get booking token from bookingData (from preview API response)
    final String bookingToken = bookingData.value?['token'] ?? '';
    
    if (bookingToken.isEmpty) {
      Get.snackbar(
        'Error',
        'Booking session expired. Please go back and refresh your booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Get the total amount from booking data
    final double totalAmount = double.parse((bookingData.value?['total'] ?? 0).toString());
    
    // Get currency from selectedCurrency or default to SAR
    final String currency = selectedCurrency.value?.alias ?? (alias.value.isNotEmpty ? alias.value : 'SAR');
    
    // Check if user has sufficient balance
    if (!walletController.hasSufficientBalance(totalAmount, currency)) {
      Get.snackbar(
        'Insufficient Balance',
        'You do not have enough balance in your wallet. Current balance: ${walletController.getBalanceForCurrency(currency)} $currency. Required: $totalAmount $currency.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return null;
    }

    // Extract pickup date and time safely with fallback to BookingController
    String pickupDateValue = '';
    String pickupTimeValue = '';
    
    // Try to get from bookingData first
    if (bookingData.value != null) {
      var pickupDateRaw = bookingData.value!['pickup_date'];
      var pickupTimeRaw = bookingData.value!['pickup_time'];
      
      if (pickupDateRaw != null) {
        pickupDateValue = pickupDateRaw.toString().trim();
      }
      if (pickupTimeRaw != null) {
        pickupTimeValue = pickupTimeRaw.toString().trim();
      }
      
      log.i('From bookingData - pickup_date: "$pickupDateValue", pickup_time: "$pickupTimeValue"');
    }
    
    // Fallback to BookingController if values are still empty
    if (pickupDateValue.isEmpty || pickupTimeValue.isEmpty) {
      try {
        final bookingController = Get.find<BookingController>();
        if (pickupDateValue.isEmpty && bookingController.pickupDate.value.isNotEmpty) {
          pickupDateValue = bookingController.pickupDate.value.trim();
          log.i('Using BookingController pickup_date: "$pickupDateValue"');
        }
        if (pickupTimeValue.isEmpty && bookingController.pickupTime.value.isNotEmpty) {
          pickupTimeValue = bookingController.pickupTime.value.trim();
          log.i('Using BookingController pickup_time: "$pickupTimeValue"');
        }
      } catch (e) {
        log.e('Could not get pickup date/time from BookingController: $e');
      }
    }
    
    // Final validation - must have both values
    if (pickupDateValue.isEmpty || pickupTimeValue.isEmpty) {
      log.e('VALIDATION FAILED - pickup_date: "$pickupDateValue", pickup_time: "$pickupTimeValue"');
      Get.snackbar(
        'Missing Information',
        'Pickup date and time are required. Please go back and complete the booking form.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return null;
    }
    
    log.i('✅ Validated - pickup_date: "$pickupDateValue", pickup_time: "$pickupTimeValue"');

    // Prepare email: prioritize LocalStorage, fallback to bookingData
    final String emailValue = LocalStorage.email.isNotEmpty 
        ? LocalStorage.email 
        : (bookingData.value?['email'] ?? '');

    // Prepare mobile: prioritize LocalStorage, use fallback if empty
    final String mobileValue = LocalStorage.mobile.isNotEmpty 
        ? LocalStorage.mobile 
        : (bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text);
    final String finalMobileValue = mobileValue.isNotEmpty ? mobileValue : '01011221122';

    // Include car_area when possible to satisfy backend validation
    final int? _selectedCarAreaId = _getSelectedCarAreaId();

    Map<String, dynamic> inputBody = {
      'car_id': int.parse(Id.value), // Required: integer
      'car_slug': slug.value.isNotEmpty ? slug.value : 'car-${Id.value}', // Required: string
      'token': bookingToken, // Required: booking token from preview API
      'mobile': finalMobileValue,
      'pickup_date': pickupDateValue, // Required: date format (YYYY-MM-DD)
      'pickup_time': pickupTimeValue, // Required: string (HH:mm)
      'fees': totalAmount, // Required: numeric
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text, // Nullable: string
      'is_deliver': bookingData.value?['delivery_required'] ?? false, // Nullable: boolean
      'destination': bookingData.value?['destination'] ?? '', // Nullable: string
      'distance': bookingData.value?['delivery_distance'] ?? 0, // Nullable: numeric
      'rental_days': bookingData.value?['quantity'], // Nullable: integer
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text, // Nullable: string
      'payment': 'wallet', // Payment method: wallet
      'pickup_lat': bookingData.value?['delivery_latitude'] ?? Get.find<BookingController>().pickupLatitude.value,
      'pickup_lng': bookingData.value?['delivery_longitude'] ?? Get.find<BookingController>().pickupLongitude.value,
      // Insurance type
      if (bookingData.value?['insurance_type'] != null && (bookingData.value!['insurance_type'] as String).isNotEmpty)
        'insurance_type': bookingData.value!['insurance_type'],
    };

    // Invoice breakdown fields (sent when known from pricing calculation)
    final double? subtotal = _parseOptionalDouble(bookingData.value?['subtotal']);
    final double? deliveryFee = _parseOptionalDouble(bookingData.value?['delivery_charge']);
    final double? taxAmount = _parseOptionalDouble(bookingData.value?['tax_amount']);
    // discount_amount sent as positive to backend
    final double? discountAmount = _parseOptionalDouble(bookingData.value?['discount_amount']);
    if (subtotal != null) inputBody['subtotal'] = subtotal;
    if (deliveryFee != null && deliveryFee > 0) inputBody['delivery_fee'] = deliveryFee;
    if (taxAmount != null && taxAmount > 0) inputBody['tax_amount'] = taxAmount;
    if (discountAmount != null && discountAmount > 0) inputBody['discount_amount'] = discountAmount;
    
    // Only include credentials if email is available
    if (emailValue.isNotEmpty) inputBody['credentials'] = emailValue;
    if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId;
    
    // Double-check the values in the body before sending
    log.i('=== WALLET PAYMENT BOOKING REQUEST ===');
    log.i('Endpoint: ${ApiEndpoint.bookingConfirm}');
    log.i('Payment Type: wallet');
    log.i('Amount: $totalAmount $currency');
    log.i('Booking Token: $bookingToken');
    log.i('Car ID: ${Id.value}');
    log.i('Pickup Date in body: "${inputBody['pickup_date']}"');
    log.i('Pickup Time in body: "${inputBody['pickup_time']}"');
    log.i('Mobile: $finalMobileValue');
    log.i('Full Request Body: $inputBody');
    log.i('=====================================');
    
    // Final safety check - ensure pickup_date and pickup_time are not null or empty in the body
    if (inputBody['pickup_date'] == null || inputBody['pickup_date'].toString().isEmpty ||
        inputBody['pickup_time'] == null || inputBody['pickup_time'].toString().isEmpty) {
      log.e('⛔ CRITICAL: pickup_date or pickup_time is null/empty in request body!');
      log.e('pickup_date: ${inputBody['pickup_date']}');
      log.e('pickup_time: ${inputBody['pickup_time']}');
      Get.snackbar(
        'Booking Error',
        'Unable to process booking - missing pickup date/time. Please go back and select a pickup date and time.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      return null;
    }
    
    return RequestProcess().request<BookingConfirmModel>(
      fromJson: BookingConfirmModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        if (value == null) {
          log.e('Wallet Booking Error: Null response from API');
          Get.snackbar(
            'Error',
            'Failed to process booking. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        
        _bookingConfirmModel = value;
        log.i('Wallet Booking Response Type: ${_bookingConfirmModel.type}');
        
        // Check type first - if success, proceed regardless of data
        if (_bookingConfirmModel.type == 'success') {
          // Success - wallet has been charged, refresh balance
          log.i('Wallet Booking Success - Refreshing wallet balance');
          walletController.fetchBalance();
          
          // Extract identifier for reference (may be null for some APIs)
          identifier.value = _bookingConfirmModel.data?.identifier ?? '';
          
          // Get success message from API or use default
          String successMessage = 'Your booking has been confirmed successfully! Payment of $totalAmount $currency has been deducted from your wallet.';
          if (_bookingConfirmModel.message?.success != null && 
              _bookingConfirmModel.message!.success!.isNotEmpty) {
            successMessage = _bookingConfirmModel.message!.success!.first;
          }
          
          // Navigate to success screen with proper arguments
          log.i('Booking successful - Navigating to success screen');
          Get.offAll(
            () => CongratulationsScreen(),
            arguments: Congratulation(
              details: successMessage,
              route: Routes.historyScreen,
              buttonText: 'My Bookings',
              type: 'success',
            ),
          );
          return;
        }
        
        // Check if this is an error response
        if (_bookingConfirmModel.type == 'error') {
          String errorMessage = 'Booking confirmation failed.';
          
          // Extract error message from response
          if (_bookingConfirmModel.message?.error != null && 
              _bookingConfirmModel.message!.error!.isNotEmpty) {
            errorMessage = _bookingConfirmModel.message!.error!.first;
          }
          
          log.e('Wallet Booking Error: $errorMessage');
          
          // Navigate to failure screen
          Get.offAll(
            () => CongratulationsScreen(),
            arguments: Congratulation(
              details: errorMessage,
              route: Routes.dashboardScreen,
              buttonText: 'Home',
              type: 'Booking Failed',
            ),
          );
          return;
        }
        
        // Unknown response type - treat as potential success if no explicit error
        log.w('Unknown booking response type: ${_bookingConfirmModel.type}');
        walletController.fetchBalance();
        identifier.value = _bookingConfirmModel.data?.identifier ?? '';
        
        Get.offAll(
          () => CongratulationsScreen(),
          arguments: Congratulation(
            details: 'Your booking has been processed.',
            route: Routes.historyScreen,
            buttonText: 'My Bookings',
            type: 'success',
          ),
        );
      },
      onError: (error) {
        log.e('Wallet Booking API Error: $error');
        
        // Navigate to failure screen for API errors
        Get.offAll(
          () => CongratulationsScreen(),
          arguments: Congratulation(
            details: 'An error occurred while processing your booking. Please try again later.',
            route: Routes.dashboardScreen,
            buttonText: 'Home',
            type: 'Booking Failed',
          ),
        );
      },
    );
  }

  ///=> GET ALL BOOKING PREVIEW INFO

  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  late BookingPreviewModel _bookingPreviewModel;

  BookingPreviewModel get bookingPreviewModel => _bookingPreviewModel;

  Future<BookingPreviewModel?> getPreviewData() async {
    // Validate that car ID is available before requesting
    if (dashboardController.selectedCarId.value.isEmpty) {
      // Defer snackbar to after build is complete
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'Error',
          'No car selected. Please select a car first.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return null;
    }

    // Get booking token from dashboard controller (vendor cars token)
    final String bookingToken = dashboardController.carToken.value;
    if (bookingToken.isEmpty) {
      // Defer snackbar to after build is complete
      Future.delayed(Duration.zero, () {
        Get.snackbar(
          'Error',
          'Booking token is missing. Please select a car again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      });
      return null;
    }

    // Await the request so we can detect failures and provide a local fallback
    BookingPreviewModel? result = await RequestProcess().request<BookingPreviewModel>(
      queryParams: {
        'token': bookingToken,
        'car_id': dashboardController.selectedCarId.value,
      },
      fromJson: BookingPreviewModel.fromJson,
      apiEndpoint: ApiEndpoint.getBookingPreview,
      isLoading: _isLoading,
      showErrorMessage: true,
      onSuccess: (value) {
        _bookingPreviewModel = value!;
        
  // Debug logging to check API response
  log.i('=== PREVIEW DATA DEBUG ===');
  log.i('Car ID from API: ${_bookingPreviewModel.data.car.id}');
  log.i('Car Slug from API: ${_bookingPreviewModel.data.car.slug}');
  log.i('Car Model from API: ${_bookingPreviewModel.data.car.carModel}');
  log.i('Full car data: ${_bookingPreviewModel.data.car.toJson()}');
  log.i('========================');
        
        // IMPORTANT: Populate payment gateways BEFORE calling _getPreviewALlData()
        // Clear existing list before adding new gateways to prevent duplicates
        paymentGatewayList.clear();
        _bookingPreviewModel.data.paymentGateways.forEach((v) {
          paymentGatewayList.add(
            PaymentGateway(
              status: v.status,
              type: v.type,
              desc: v.desc,
              currencies: v.currencies,
              crypto: v.crypto,
              id: v.id,
              name: v.name,
            ),
          );
        });
        log.i('Payment gateways populated: ${paymentGatewayList.length} gateways');
        for (final g in paymentGatewayList) {
          log.i('  - Gateway: ${g.name} (${g.type})');
        }
        
        // Now call _getPreviewALlData() AFTER gateways are populated
        _getPreviewALlData();
      },
    );

    // If the API failed (returned null) try to fill minimal required data from
    // the locally cached car list (dashboardController.cars). This prevents
    // immediate booking failure when preview API is temporarily returning
    // malformed JSON (see logs). It's a best-effort fallback.
    if (result == null) {
      log.e('🚨 getPreviewData API FAILED! Using local fallback...');
      try {
        final selectedId = dashboardController.selectedCarId.value;
        final localCar = dashboardController.cars.firstWhere(
          (c) => c.id.toString() == selectedId,
        );

        // Map available local fields to preview controller values
        slug.value = localCar.slug;
        Id.value = localCar.id.toString();
        carModel.value = localCar.carModel;
        // Local model doesn't contain carNumber in all responses — leave empty
        carNumber.value = '';
        
        log.i('✓ Loaded fallback car data:');
        log.i('  slug: ${slug.value}');
        log.i('  id: ${Id.value}');
        log.i('  carModel: ${carModel.value}');

        // Set default payment gateway (Moyasar) since API failed
        log.i('Setting default payment gateway (Moyasar)...');
        PaymentGateway moyasarDefault = PaymentGateway(
          id: 1,
          type: 'moyasar',
          name: 'Moyasar',
          crypto: 0,
          desc: 'Moyasar Payment Gateway',
          status: 1,
          currencies: [
            Currency(
              id: 1,
              paymentGatewayId: 1,
              name: 'Saudi Riyal',
              alias: 'moyasar-SAR-automatic',
              currencyCode: 'SAR',
              currencySymbol: 'ر.س',
              image: '',
              rate: 1.0,
              minLimit: 0,
              maxLimit: 999999,
              fixedCharge: 0,
              percentCharge: 0,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          ],
        );
        
        selectPaymentGateway.value = moyasarDefault;
        paymentTypes.value = 'moyasar';
        selectedCurrency.value = moyasarDefault.currencies.first;
        alias.value = moyasarDefault.currencies.first.alias;
        currencyName.value = moyasarDefault.currencies.first.name;
        
        log.i('✓ Default Moyasar gateway set:');
        log.i('  alias: ${alias.value}');
        log.i('  currency: ${currencyName.value}');

        // Defer snackbar to after build is complete
        Future.delayed(Duration.zero, () {
          Get.snackbar(
            'Notice',
            'Preview data unavailable from server — using cached car data.' + (kDebugMode ? '\n(Dev: raw response logged)' : ''),
            snackPosition: SnackPosition.BOTTOM,
          );
        });
      } catch (e) {
  // No local fallback available — bubble up nothing and allow UI to show
  // validation when user tries to proceed with booking.
  log.e('Preview fallback: no local car found for id ${dashboardController.selectedCarId.value}');
      }
    }

    return result;
  }

  void _getPreviewALlData() {
    carModel.value = _bookingPreviewModel.data.car.carModel;
    carNumber.value = _bookingPreviewModel.data.car.carNumber;
    pickupTime.value = _bookingPreviewModel.data.bookingDetails.pickupTime;
    slug.value = _bookingPreviewModel.data.car.slug;
    Id.value = _bookingPreviewModel.data.car.id.toString();
    cashBalance.value = _bookingPreviewModel.data.paymentType.cash;
    onlinePayment.value = _bookingPreviewModel.data.paymentType.onlinePayment;
    
  // Debug: Check if values were actually set
  log.i('=== AFTER SETTING VALUES ===');
  log.i('slug.value: "${slug.value}"');
  log.i('Id.value: "${Id.value}"');
  log.i('carModel.value: "${carModel.value}"');
    
    // Fallback: If API didn't return valid car ID, use selectedCarId
    if (Id.value.isEmpty || Id.value == 'null') {
      log.e('WARNING: Car ID is empty/null, using fallback from dashboardController');
      Id.value = dashboardController.selectedCarId.value;
      log.i('Fallback Id.value: "${Id.value}"');
    }
    
    // Auto-select Moyasar payment gateway
    log.i('Looking for Moyasar gateway in ${paymentGatewayList.length} gateways...');
    PaymentGateway? moyasarGateway;
    for (final g in paymentGatewayList) {
      log.i('Checking gateway: ${g.name} (type: ${g.type})');
      if (g.type.toLowerCase().contains('moyasar')) {
        moyasarGateway = g;
        log.i('✓ Found Moyasar gateway!');
        break;
      }
    }
    
    if (moyasarGateway != null) {
      selectPaymentGateway.value = moyasarGateway;
      paymentTypes.value = moyasarGateway.type;
      log.i('Moyasar gateway selected - Type: ${paymentTypes.value}');
      
      // Populate currencies from selected gateway
      log.i('Populating currencies from Moyasar gateway...');
      currencyList.clear();
      moyasarGateway.currencies.forEach((v) {
        currencyList.add(
          Currency(
            id: v.id,
            name: v.name,
            updatedAt: v.updatedAt,
            createdAt: v.createdAt,
            image: v.image,
            alias: v.alias,
            currencyCode: v.currencyCode,
            currencySymbol: v.currencySymbol,
            fixedCharge: v.fixedCharge,
            maxLimit: v.maxLimit,
            minLimit: v.minLimit,
            paymentGatewayId: v.paymentGatewayId,
            percentCharge: v.percentCharge,
            rate: v.rate,
          ),
        );
      });
      log.i('Currencies populated: ${currencyList.length} currencies');
      
      // Auto-select first currency (preferably SAR)
      Currency? selectedCurr;
      for (final c in currencyList) {
        if (c.currencyCode == 'SAR') {
          selectedCurr = c;
          log.i('✓ Found SAR currency');
          break;
        }
      }
      
      if (selectedCurr == null && currencyList.isNotEmpty) {
        selectedCurr = currencyList.first;
        log.i('SAR not found, using first currency: ${selectedCurr.name}');
      }
      
      if (selectedCurr != null) {
        selectedCurrency.value = selectedCurr;
        alias.value = selectedCurr.alias;
        currencyName.value = selectedCurr.name;
        log.i('✓ Currency selected: ${currencyName.value} (alias: ${alias.value})');
      } else {
        log.i('ERROR: No currency found for Moyasar');
      }
      
      log.i('Moyasar gateway auto-selected with currency: ${currencyName.value}');
    } else {
      log.e('ERROR: Moyasar gateway not found in payment gateways list!');
      log.e('Available gateways: ${paymentGatewayList.map((g) => g.name).toList()}');
      
      // Fallback: Try to use first gateway if Moyasar not found
      if (paymentGatewayList.isNotEmpty) {
        log.w('Using fallback: ${paymentGatewayList.first.name}');
        selectPaymentGateway.value = paymentGatewayList.first;
        paymentTypes.value = paymentGatewayList.first.type;
      }
    }
    
    log.i('===========================');
  }

  /// Return the selected car's area id if available.
  /// This helps satisfy backend validation that may require `car_area`.
  int? _getSelectedCarAreaId() {
    try {
      final selId = dashboardController.selectedCarId.value.isNotEmpty
          ? dashboardController.selectedCarId.value
          : Id.value;
    final matches = dashboardController.cars
      .where((c) => c.id.toString() == selId)
      .toList(growable: false);
    if (matches.isEmpty) return null;
    return matches.first.carAreaId;
    } catch (e) {
      log.w('Could not determine selected car area id: $e');
      return null;
    }
  }

  /// Safe nullable double parser for optional invoice breakdown fields.
  double? _parseOptionalDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  RxString paymentTypes = ''.obs;
  RxString alias = ''.obs;
  RxString currencyName = ''.obs;

  // RxString rate = ''.obs;
  RxString carModel = ''.obs;
  RxString carNumber = ''.obs;
  RxString pickupTime = ''.obs;
  RxString pickupDate = ''.obs;
  RxString slug = ''.obs;
  RxString Id = ''.obs;
  RxString cashBalance = ''.obs;
  RxString onlinePayment = ''.obs;

  ///=> CONFIRM BOOKING PROCESS

  final _isBookingLoading = false.obs;

  bool get isBookingLoading => _isBookingLoading.value;

  late BookingConfirmModel _bookingConfirmModel;

  BookingConfirmModel get bookingConfirmModel => _bookingConfirmModel;

  Future<BookingConfirmModel?> bookingProcessAuto() async {
    // Validate car ID is selected
    if (Id.value.isEmpty || Id.value == '0' || Id.value == 'null') {
      Get.snackbar(
        'Error',
        'No car selected. Please select a car before booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // include car_area when possible to satisfy backend validation
    final int? _selectedCarAreaId = _getSelectedCarAreaId();
    
    // Get token from bookingData (from preview API response)
    final String bookingToken = bookingData.value?['token'] ?? '';
    
    if (bookingToken.isEmpty) {
      Get.snackbar(
        'Error',
        'Booking session expired. Please go back and refresh your booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Extract pickup date and time safely
    final String pickupDateValue = (bookingData.value?['pickup_date'] is String) ? (bookingData.value?['pickup_date'] as String) : '';
    final String pickupTimeValue = (bookingData.value?['pickup_time'] is String) ? (bookingData.value?['pickup_time'] as String) : '';

    // Prepare email: prioritize LocalStorage, fallback to bookingData, make truly optional
    final String emailValue = LocalStorage.email.isNotEmpty 
        ? LocalStorage.email 
        : (bookingData.value?['email'] ?? '');

    // Prepare mobile: prioritize LocalStorage, use fallback if empty
    final String mobileValue = LocalStorage.mobile.isNotEmpty 
        ? LocalStorage.mobile 
        : (bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text);
    final String finalMobileValue = mobileValue.isNotEmpty ? mobileValue : '01011221122';

    Map<String, dynamic> inputBody = {
      'car_id': int.parse(Id.value), // Required: integer
      'car_slug': slug.value.isNotEmpty ? slug.value : 'car-${Id.value}', // Required: string
      'token': bookingToken, // Required: string
      'mobile': finalMobileValue,
      'pickup_date': pickupDateValue, // Required: date format (YYYY-MM-DD)
      'pickup_time': pickupTimeValue, // Required: string (HH:mm)
      'fees': double.parse((bookingData.value?['total'] ?? 0).toString()), // Required: numeric
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text, // Nullable: string
      'is_deliver': bookingData.value?['delivery_required'] ?? false, // Nullable: boolean
      'destination': bookingData.value?['destination'] ?? '', // Nullable: string
      'distance': bookingData.value?['delivery_distance'] ?? 0, // Nullable: numeric
      'rental_days': bookingData.value?['quantity'], // Nullable: integer
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text, // Nullable: string
      'payment': 'moyasar', // Default to Moyasar payment
      'pickup_lat': bookingData.value?['delivery_latitude'] ?? Get.find<BookingController>().pickupLatitude.value,
      'pickup_lng': bookingData.value?['delivery_longitude'] ?? Get.find<BookingController>().pickupLongitude.value,
    };
    // Only include credentials if email is available
    if (emailValue.isNotEmpty) inputBody['credentials'] = emailValue;
    if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId;
    return RequestProcess().request<BookingConfirmModel>(
      fromJson: BookingConfirmModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        if (value == null) {
          Get.snackbar(
            'Error',
            'Failed to process booking. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        
        _bookingConfirmModel = value;
        
        // Check if this is an error response
        if (_bookingConfirmModel.type == 'error' || _bookingConfirmModel.data == null) {
          String errorMessage = 'Booking confirmation failed.';
          
          // Extract error message from response
          if (_bookingConfirmModel.message?.error != null && 
              _bookingConfirmModel.message!.error!.isNotEmpty) {
            errorMessage = _bookingConfirmModel.message!.error!.first;
          }
          
          Get.snackbar(
            'Booking Error',
            errorMessage,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 4),
          );
          return;
        }
        
        // Safely check if identifier exists
        if (_bookingConfirmModel.data?.identifier == null || 
            _bookingConfirmModel.data!.identifier!.isEmpty) {
          Get.snackbar(
            'Error',
            'Invalid booking response. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
        
        identifier.value = _bookingConfirmModel.data!.identifier!;
        // Payment screen navigation will be handled by the new payment flow
        // if (alias.value.contains('authorize')) {
        //   Get.to(AuthorizeGatewayScreen());
        // } else {
        //   Get.to(() => WebPaymentScreen());
        // }
      },
    );
  }

  // Cash payment removed - online payment only
  /* Future<CommonSuccessModel?> cashBookedProcess() async {
    // Validate car identifiers before sending booking request
    if (slug.value.isEmpty || Id.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Car information is missing. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

  final int? _selectedCarAreaId = _getSelectedCarAreaId();

  Map<String, dynamic> inputBody = {
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text,
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text,
      'mobile': bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text,
      'credentials': bookingData.value?['email'] ?? LocalStorage.email,
      'car_slug': slug.value,
      'car_id': Id.value,
      'payment': selectedMethodText,
      'token': dashboardController.carToken.value,
      'fees': (bookingData.value?['total'] ?? 0).toString(),
      // New pricing fields
      'quantity': bookingData.value?['quantity'],
      'pricing_type': bookingData.value?['pricing_type'],
      'delivery_required': bookingData.value?['delivery_required'] ?? false,
    };
  if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId;
    return RequestProcess().request<CommonSuccessModel>(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      onSuccess: (value) {
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  } */

  ///=> Get manual payment input field

  late ManualInputModel _manualInputModel;

  ManualInputModel get manualInputModel => _manualInputModel;

  Future<ManualInputModel?> paymentManualInsert() async {
    return RequestProcess().request<ManualInputModel>(
      fromJson: ManualInputModel.fromJson,
      apiEndpoint: ApiEndpoint.getManualPaymentField,
      isLoading: _isBookingLoading,
      showSuccessMessage: false,
      showResult: true,
      queryParams: {'alias': alias.value},
      onSuccess: (value) {
        _manualInputModel = value!;
        var data = _manualInputModel.data.inputFields;
        getManualDynamicInputField(
          data: data,
          inputFieldControllers: inputFieldControllers,
          inputFields: inputFields,
          inputFileFields: inputFileFields,
          hasFile: hasFile,
          selectType: selectType,
        );
        Get.toNamed(Routes.paymentManualField);
      },
    );
  }

  ///=> manual payment process

  late CommonSuccessModel _commonSuccessModel;

  CommonSuccessModel get commonSuccessModel => _commonSuccessModel;

  Future<CommonSuccessModel?> bookingManualProcess() async {
    // Validate car ID is selected
    if (Id.value.isEmpty || Id.value == '0' || Id.value == 'null') {
      Get.snackbar(
        'Error',
        'No car selected. Please select a car before booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    final int? _selectedCarAreaId = _getSelectedCarAreaId();
    
    // Get token from bookingData (from preview API response)
    final String bookingToken = bookingData.value?['token'] ?? '';
    
    if (bookingToken.isEmpty) {
      Get.snackbar(
        'Error',
        'Booking session expired. Please go back and refresh your booking.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }

    // Extract pickup date and time safely
    final String pickupDateValue = (bookingData.value?['pickup_date'] is String) ? (bookingData.value?['pickup_date'] as String) : '';
    final String pickupTimeValue = (bookingData.value?['pickup_time'] is String) ? (bookingData.value?['pickup_time'] as String) : '';

    // Prepare email: prioritize LocalStorage, fallback to bookingData, make truly optional
    final String emailValue = LocalStorage.email.isNotEmpty 
        ? LocalStorage.email 
        : (bookingData.value?['email'] ?? '');

    // Prepare mobile: prioritize LocalStorage, use fallback if empty
    final String mobileValue = LocalStorage.mobile.isNotEmpty 
        ? LocalStorage.mobile 
        : (bookingData.value?['phone'] ?? Get.find<BookingController>().mobileController.text);
    final String finalMobileValue = mobileValue.isNotEmpty ? mobileValue : '01011221122';

    Map<String, String> inputBody = {
      'car_id': Id.value, // Required: integer (as string for Map<String, String>)
      'car_slug': slug.value.isNotEmpty ? slug.value : 'car-${Id.value}', // Required: string
      'token': bookingToken, // Required: string
      'mobile': finalMobileValue, // Required: string
      'pickup_date': pickupDateValue, // Required: date format (YYYY-MM-DD)
      'pickup_time': pickupTimeValue, // Required: string (HH:mm)
      'fees': (bookingData.value?['total'] ?? 0).toString(), // Required: numeric
      'location': bookingData.value?['delivery_location'] ?? Get.find<BookingController>().locationController.text, // Nullable: string
      'is_deliver': (bookingData.value?['delivery_required'] ?? false).toString(), // Nullable: boolean
      'destination': bookingData.value?['destination'] ?? '', // Nullable: string
      'distance': (bookingData.value?['delivery_distance'] ?? 0).toString(), // Nullable: numeric
      'rental_days': (bookingData.value?['quantity'] ?? 0).toString(), // Nullable: integer
      'message': bookingData.value?['notes'] ?? Get.find<BookingController>().noteController.text, // Nullable: string
      'payment': selectedMethodText,
      'pickup_lat': (bookingData.value?['delivery_latitude'] ?? Get.find<BookingController>().pickupLatitude.value).toString(),
      'pickup_lng': (bookingData.value?['delivery_longitude'] ?? Get.find<BookingController>().pickupLongitude.value).toString(),
    };
    // Only include credentials if email is available
    if (emailValue.isNotEmpty) inputBody['credentials'] = emailValue;
    if (_selectedCarAreaId != null) inputBody['car_area'] = _selectedCarAreaId.toString();
    final data = _manualInputModel.data.inputFields;

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
      apiEndpoint: ApiEndpoint.bookingConfirm,
      isLoading: _isBookingLoading,
      method: HttpMethod.POST,
      body: inputBody,
      fieldList: listFieldName,
      pathList: listImagePath,
      onSuccess: (value) {
        inputFileFields.clear();
        inputFields.clear();
        listImagePath.clear();
        listFieldName.clear();
        inputFieldControllers.clear();
        update();
        _commonSuccessModel = value!;
        _confirmation(_commonSuccessModel);
      },
    );
  }

  void _confirmation(CommonSuccessModel commonSuccessModel) {
    Congratulation congratulation = Congratulation(
      details: Strings.bookingSuccessfully,
      route: Routes.historyScreen,
      buttonText: 'My Bookings',
      type: Strings.payment,
    );

    Get.to(() => CongratulationsScreen(), arguments: congratulation);
  }

  RxDouble totalPayable = 0.0.obs;

  RxDouble exRent = 0.0.obs;
  RxDouble percentCharge = 0.0.obs;
  RxDouble fixeCharge = 0.0.obs;
  RxDouble conversionAmount = 0.0.obs;
  RxDouble totalCharge = 0.0.obs;

  void calculateAllCharges() {
    conversionAmount.value =
        exRent.value * (bookingData.value?['total'] ?? Get.find<BookingController>().total.value);

    // Calculate the percent charge based on the conversion amount
    percentCharge.value = percentCharge.value / 100 * conversionAmount.value;

    // Calculate the total charge
    totalCharge.value = fixeCharge.value + percentCharge.value;

    // Calculate the total payable amount
    totalPayable.value = conversionAmount.value + totalCharge.value;
  }

  // Authorize Submit
  final _isAuthorizeLoading = false.obs;
  bool get isAuthorizeLoading => _isAuthorizeLoading.value;

  late CommonSuccessModel _authorizeModel;
  CommonSuccessModel get authorizeModel => _authorizeModel;

  Future<CommonSuccessModel?> authorizeSubmitProcess() async {
    Map<String, dynamic> inputBody = {
      "identifier": identifier.value,
      "card_number": cardNumberController.text,
      "date": cardExpiryController.text,
      "code": cardCVCController.text,
    };
    return RequestProcess().request(
      fromJson: CommonSuccessModel.fromJson,
      apiEndpoint: ApiEndpoint.authorizeSubmit,
      body: inputBody,
      method: HttpMethod.POST,
      isLoading: _isAuthorizeLoading,
      onSuccess: (value) {
        _authorizeModel = value!;
        Congratulation congratulation = Congratulation(
          details: Strings.paymentSuccessful,
          route: Routes.historyScreen,
          buttonText: 'My Bookings',
          type: Strings.payment,
        );
        Get.offAll(() => CongratulationsScreen(), arguments: congratulation);
      },
    );
  }
}
