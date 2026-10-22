import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../generated/l10n/app_localizations.dart';
// Remote runtime translations are intentionally disabled. Use ARB (AppLocalizations) only.

/// I18n service that provides unified access to translations
/// Priority: 1) Runtime server translations, 2) Generated ARB translations, 3) Fallback to key
class I18nService extends GetxController {
  static const String _storageKey = 'selectedLanguage';
  final GetStorage _storage = GetStorage();
  
  // Observable current language
  final Rx<Locale> _currentLocale = const Locale('en').obs;
  Locale get currentLocale => _currentLocale.value;
  
  // Loading state
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  RxBool get isLoadingValue => _isLoading;
  
  // Runtime translations from server (cached) - not used in ARB-only mode
  final Map<String, Map<String, String>> _runtimeTranslations = {};

  // Available languages (populated from local ARB files)
  final RxList<LanguageModel> _languages = <LanguageModel>[].obs;
  List<LanguageModel> get languages => _languages;

  // Reactive accessor for UI bindings
  RxList<LanguageModel> get languagesRx => _languages;
  
  // Cache for AppLocalizations instance
  AppLocalizations? _cachedAppLocalizations;
  
  @override
  void onInit() {
    super.onInit();
    // Do not initialize remote language service — use ARB translations only.
    _loadSavedLanguage();

    // Populate supported local languages (derived from lib/l10n/*.arb)
    // Keep list minimal and deterministic to avoid relying on remote service.
    _languages.value = [
      LanguageModel(code: 'en', name: 'English', direction: 'ltr'),
      LanguageModel(code: 'ar', name: 'العربية', direction: 'rtl'),
    ];
  }
  
  /// Initialize kept for API compatibility. Remote fetches disabled — no-op.
  Future<void> init({required String url}) async {
    _isLoading.value = false;
    // Intentionally no-op: this app uses generated ARB translations only.
    return;
  }
  
  /// Get translation for a key using AppLocalizations getter map (ARB-only)
  String key(String translationKey, {BuildContext? context}) {
    // Use the generated ARB translations via AppLocalizations only.
    var currentLangCode = _currentLocale.value.languageCode;

    // Normalize / fallback
    if (currentLangCode.isEmpty) {
      currentLangCode = 'en';
    }

    try {
      // Create AppLocalizations for current locale if not cached
      if (_cachedAppLocalizations == null ||
          _cachedAppLocalizations!.localeName != currentLangCode) {
        _cachedAppLocalizations = lookupAppLocalizations(Locale(currentLangCode));
      }

      // Use the getter map to retrieve translation
      final translation = _translationGetters[translationKey]?.call(_cachedAppLocalizations!);
      if (translation != null && translation.isNotEmpty) {
        return translation;
      }

      // If a BuildContext is provided, try AppLocalizations.of(context)
      if (context != null) {
        try {
          final ctxLocal = AppLocalizations.of(context);
          if (ctxLocal != null) {
            final ctxTranslation = _translationGetters[translationKey]?.call(ctxLocal);
            if (ctxTranslation != null && ctxTranslation.isNotEmpty) {
              return ctxTranslation;
            }
          }
        } catch (_) {
          // ignore context fallback failures
        }
      }
    } catch (e) {
      debugPrint('AppLocalizations error for key $translationKey: $e');
    }

    // Final fallback: try English lookup directly
    try {
      final enLocal = lookupAppLocalizations(const Locale('en'));
      final enTranslation = _translationGetters[translationKey]?.call(enLocal);
      if (enTranslation != null && enTranslation.isNotEmpty) return enTranslation;
    } catch (_) {}

    // Fallback to key itself when translation not available
    return translationKey;
  }
  
  /// Getter map for all translations - maps key names to AppLocalizations getters
  static final Map<String, String Function(AppLocalizations)> _translationGetters = {
    'appLPleaseFillOutTheField': (l) => l.appLPleaseFillOutTheField,
    'appLFrom': (l) => l.appLFrom,
    'appLFromGallery': (l) => l.appLFromGallery,
    'appLFromCamera': (l) => l.appLFromCamera,
    'appLHistory': (l) => l.appLHistory,
    'appLPrivacyPolicy': (l) => l.appLPrivacyPolicy,
    'appLPreview': (l) => l.appLPreview,
    'appLLogOutAlert': (l) => l.appLLogOutAlert,
    'appLAboutUs': (l) => l.appLAboutUs,
    'appLBookingPreview': (l) => l.appLBookingPreview,
    'appLPayment': (l) => l.appLPayment,
    'appLConfirmation': (l) => l.appLConfirmation,
    'appLSuccess': (l) => l.appLSuccess,
    'appLBack': (l) => l.appLBack,
    'appLBackToHome': (l) => l.appLBackToHome,
    'appLServerError': (l) => l.appLServerError,
    'appLPaymentInstructions': (l) => l.appLPaymentInstructions,
    'appLNewToCarbo': (l) => l.appLNewToCarbo,
    'appLAgreeToTerms': (l) => l.appLAgreeToTerms,
    'appLSpeed': (l) => l.appLSpeed,
    'appLKmCharge': (l) => l.appLKmCharge,
    'appLHelpCenter': (l) => l.appLHelpCenter,
    'appLAcceleration': (l) => l.appLAcceleration,
    'appLTotalBooked': (l) => l.appLTotalBooked,
    'appLCompleteRide': (l) => l.appLCompleteRide,
    'appLRoundTrip': (l) => l.appLRoundTrip,
    'appLBookingReject': (l) => l.appLBookingReject,
    'appLTopSpeed': (l) => l.appLTopSpeed,
    'appLPeakPower': (l) => l.appLPeakPower,
    'appLPending': (l) => l.appLPending,
    'appLPleaseWait': (l) => l.appLPleaseWait,
    'appLSetting': (l) => l.appLSetting,
    'appLOngoing': (l) => l.appLOngoing,
    'appLComplete': (l) => l.appLComplete,
    'appLReject': (l) => l.appLReject,
    'appLRange': (l) => l.appLRange,
    'appLDetails': (l) => l.appLDetails,
    'appLReview': (l) => l.appLReview,
    'appLPerMonth': (l) => l.appLPerMonth,
    'appLBookNow': (l) => l.appLBookNow,
    'appLBookYorCarVendor': (l) => l.appLBookYorCarVendor,
    'appLBook': (l) => l.appLBook,
    'appLCarNumber': (l) => l.appLCarNumber,
    'appLTotalSeat': (l) => l.appLTotalSeat,
    'appLExperience': (l) => l.appLExperience,
    'appLCarModel': (l) => l.appLCarModel,
    'appLYourLocation': (l) => l.appLYourLocation,
    'appLLogin': (l) => l.appLLogin,
    'appLNotification': (l) => l.appLNotification,
    'appLNoNotification': (l) => l.appLNoNotification,
    'appLNoHistory': (l) => l.appLNoHistory,
    'appLLoginNow': (l) => l.appLLoginNow,
    'appLRegisterNow': (l) => l.appLRegisterNow,
    'appLEmail': (l) => l.appLEmail,
    'appLForgotPassword': (l) => l.appLForgotPassword,
    'appLAlreadyHaveAnAccount': (l) => l.appLAlreadyHaveAnAccount,
    'appLFirstName': (l) => l.appLFirstName,
    'appLLastName': (l) => l.appLLastName,
    'appLPickUpLocation': (l) => l.appLPickUpLocation,
    'appLWriteHere': (l) => l.appLWriteHere,
    'appLDestination': (l) => l.appLDestination,
    'appLDistance': (l) => l.appLDistance,
    'appLPickUpdate': (l) => l.appLPickUpdate,
    'appLStatus': (l) => l.appLStatus,
    'appLNoCarFindMessage': (l) => l.appLNoCarFindMessage,
    'appLTotalAmount': (l) => l.appLTotalAmount,
    'appLTotalRent': (l) => l.appLTotalRent,
    'appLRate': (l) => l.appLRate,
    'appLTotalPayable': (l) => l.appLTotalPayable,
    'appLPickUpTime': (l) => l.appLPickUpTime,
    'appLEmailAddress': (l) => l.appLEmailAddress,
    'appLPassword': (l) => l.appLPassword,
    'appLIHaveAgreedWith': (l) => l.appLIHaveAgreedWith,
    'appLTermsOfUse': (l) => l.appLTermsOfUse,
    'appLSendOtp': (l) => l.appLSendOtp,
    'appLError': (l) => l.appLError,
    'appLPleaseEnterTheCode': (l) => l.appLPleaseEnterTheCode,
    'appLWeSentADigitCode': (l) => l.appLWeSentADigitCode,
    'appLDidntGetTheCode': (l) => l.appLDidntGetTheCode,
    'appLResend': (l) => l.appLResend,
    'appLSubmit': (l) => l.appLSubmit,
    'appLLogInTitleText': (l) => l.appLLogInTitleText,
    'appLResetPasswordTitleText': (l) => l.appLResetPasswordTitleText,
    'appLResetPasswordDescriptionText': (l) => l.appLResetPasswordDescriptionText,
    'appLLogInDescriptionText': (l) => l.appLLogInDescriptionText,
    'appLYouCanResend': (l) => l.appLYouCanResend,
    'appLSkip': (l) => l.appLSkip,
    'appLNewPassword': (l) => l.appLNewPassword,
    'appLConfirmPassword': (l) => l.appLConfirmPassword,
    'appLChangePassword': (l) => l.appLChangePassword,
    'appLOldPassword': (l) => l.appLOldPassword,
    'appLResetPassword': (l) => l.appLResetPassword,
    'appLResetPasswordTile': (l) => l.appLResetPasswordTile,
    'appLResetPasswordDes': (l) => l.appLResetPasswordDes,
    'appLCountry': (l) => l.appLCountry,
    'appLSelectArea': (l) => l.appLSelectArea,
    'appLSelectADate': (l) => l.appLSelectADate,
    'appLSelectType': (l) => l.appLSelectType,
    'appLSelectModel': (l) => l.appLSelectModel,
    'appLSelectYear': (l) => l.appLSelectYear,
    'appLPhone': (l) => l.appLPhone,
    'appLAddress': (l) => l.appLAddress,
    'appLCity': (l) => l.appLCity,
    'appLAllCities': (l) => l.appLAllCities,
    'appLState': (l) => l.appLState,
    'appLZipCode': (l) => l.appLZipCode,
    'appLUpdate': (l) => l.appLUpdate,
    'appLEditProfile': (l) => l.appLEditProfile,
    'appLPersonalInformation': (l) => l.appLPersonalInformation,
    'appLContactInformation': (l) => l.appLContactInformation,
    'appLAddressInformation': (l) => l.appLAddressInformation,
    'appLDocumentUploads': (l) => l.appLDocumentUploads,
    'appLNationalId': (l) => l.appLNationalId,
    'appLDrivingLicense': (l) => l.appLDrivingLicense,
    'appLDelete': (l) => l.appLDelete,
    'appLSelectATime': (l) => l.appLSelectATime,
    'appLFindCar': (l) => l.appLFindCar,
    'appLNote': (l) => l.appLNote,
    'appLRoundTripDate': (l) => l.appLRoundTripDate,
    'appLRoundTripTime': (l) => l.appLRoundTripTime,
    'appLOptional': (l) => l.appLOptional,
    'appLNoDataFound': (l) => l.appLNoDataFound,
    'appLBookingSuccessfully': (l) => l.appLBookingSuccessfully,
    'appLConfirm': (l) => l.appLConfirm,
    'appLPayWIth': (l) => l.appLPayWIth,
    'appLNoContentAvailable': (l) => l.appLNoContentAvailable,
    'appLSelectCurrency': (l) => l.appLSelectCurrency,
    'appLSelectCountry': (l) => l.appLSelectCountry,
    'appLSelectMethod': (l) => l.appLSelectMethod,
    'appLConfirmBooking': (l) => l.appLConfirmBooking,
    'appLLanguage': (l) => l.appLLanguage,
    'appLAreYouSure': (l) => l.appLAreYouSure,
    'appLAreYouSureDelete': (l) => l.appLAreYouSureDelete,
    'appLLocationNotAbleAble': (l) => l.appLLocationNotAbleAble,
    'appLLogOut': (l) => l.appLLogOut,
    'appLLogOu': (l) => l.appLLogOu,
    'appLCancel': (l) => l.appLCancel,
    'appLLongTitle': (l) => l.appLLongTitle,
    'appLLongText': (l) => l.appLLongText,
    'appLContactUs': (l) => l.appLContactUs,
    'appLRestart': (l) => l.appLRestart,
    'appLSeats': (l) => l.appLSeats,
    'appLYears': (l) => l.appLYears,
    'appLEnter': (l) => l.appLEnter,
    'appLCashPayment': (l) => l.appLCashPayment,
    'appLOnlinePayment': (l) => l.appLOnlinePayment,
    'appLContinuee': (l) => l.appLContinuee,
    'appLCvv': (l) => l.appLCvv,
    'appLCardNumber': (l) => l.appLCardNumber,
    'appLExpirationDate': (l) => l.appLExpirationDate,
    'appLDebitCardPayment': (l) => l.appLDebitCardPayment,
    'appLPaymentSuccessful': (l) => l.appLPaymentSuccessful,
    'appLMobileNumber': (l) => l.appLMobileNumber,
    'appLEnterMobileNumber': (l) => l.appLEnterMobileNumber,
    'appLVerifyOtp': (l) => l.appLVerifyOtp,
    'appLOtpVerification': (l) => l.appLOtpVerification,
    'appLEnterOtp': (l) => l.appLEnterOtp,
    'appLVerifyAndLogin': (l) => l.appLVerifyAndLogin,
    'appLVerifyAndContinue': (l) => l.appLVerifyAndContinue,
    'appLLoginWithPassword': (l) => l.appLLoginWithPassword,
    'appLLoginWithOtp': (l) => l.appLLoginWithOtp,
    'appLInvalidPhoneNumber': (l) => l.appLInvalidPhoneNumber,
    'appLPleaseEnterValidPhone': (l) => l.appLPleaseEnterValidPhone,
    'appLInvalidOtp': (l) => l.appLInvalidOtp,
    'appLOtpSent': (l) => l.appLOtpSent,
    'appLCheckMobileForOtp': (l) => l.appLCheckMobileForOtp,
    'appLMobileVerified': (l) => l.appLMobileVerified,
    'appLMobileVerifiedSuccessfully': (l) => l.appLMobileVerifiedSuccessfully,
    'appLMobileNotVerified': (l) => l.appLMobileNotVerified,
    'appLVerifyMobileFirst': (l) => l.appLVerifyMobileFirst,
    'appLResendOtp': (l) => l.appLResendOtp,
    'appLCountryCode': (l) => l.appLCountryCode,
    'appLEnterSixDigitOtp': (l) => l.appLEnterSixDigitOtp,
    'appLAvailableCars': (l) => l.appLAvailableCars,
    'appLCarsAvailable': (l) => l.appLCarsAvailable,
    'appLLoadMore': (l) => l.appLLoadMore,
    'appLAvailable': (l) => l.appLAvailable,
    'appLLimited': (l) => l.appLLimited,
    'appLInsuranceIncluded': (l) => l.appLInsuranceIncluded,
    'appLAutomatic': (l) => l.appLAutomatic,
    'appLPetrol': (l) => l.appLPetrol,
    'appLTransmission': (l) => l.appLTransmission,
    'appLFuelType': (l) => l.appLFuelType,
    'appLNoCarsFound': (l) => l.appLNoCarsFound,
    'appLTryDifferentFilters': (l) => l.appLTryDifferentFilters,
    'appLSortBy': (l) => l.appLSortBy,
    'appLPriceLowToHigh': (l) => l.appLPriceLowToHigh,
    'appLPriceHighToLow': (l) => l.appLPriceHighToLow,
    'appLPopularity': (l) => l.appLPopularity,
    'appLRating': (l) => l.appLRating,
    'appLPullToRefresh': (l) => l.appLPullToRefresh,
    'appLRefreshing': (l) => l.appLRefreshing,
    'appLAll': (l) => l.appLAll,
    'appLAllCars': (l) => l.appLAllCars,
    'appLFilterBy': (l) => l.appLFilterBy,
    'appLShowResults': (l) => l.appLShowResults,
    'appLRentalDays': (l) => l.appLRentalDays,
    'appLDay': (l) => l.appLDay,
    'appLPricePerDay': (l) => l.appLPricePerDay,
    'appLPricePerKm': (l) => l.appLPricePerKm,
    'appLDeliveryCharge': (l) => l.appLDeliveryCharge,
    'appLDeliveryCar': (l) => l.appLDeliveryCar,
    'appLTax': (l) => l.appLTax,
    'appLTotal': (l) => l.appLTotal,
    'appLQuantity': (l) => l.appLQuantity,
    'appLSelectInsurance': (l) => l.appLSelectInsurance,
    'appLDailyInsurance': (l) => l.appLDailyInsurance,
    'appLExcessLiabilityInsurance': (l) => l.appLExcessLiabilityInsurance,
    'appLInsuranceType': (l) => l.appLInsuranceType,
    'appLInsuranceAmount': (l) => l.appLInsuranceAmount,
    'appLInsuranceWarning': (l) => l.appLInsuranceWarning,
    'appLSnappedOutsideAllowed': (l) => l.appLSnappedOutsideAllowed,
    'appLSnappedShort': (l) => l.appLSnappedShort,
    'appLCurrentLocation': (l) => l.appLCurrentLocation,
    'appLCenter': (l) => l.appLCenter,
    'appLSelectedLocation': (l) => l.appLSelectedLocation,
    // Parameterized translations (with placeholders) are invoked directly
    // via AppLocalizations in code, e.g. AppLocalizations.of(context).appLLatLngFormat(...)
    // Note: Keys present in ARB but not listed above are typically
    // parameterized and must be called with parameters. Current examples:
    // - appLLatLngFormat(lat, lng)
    // - appLDistanceLabel(km)
    // - appLPartialPaymentMessage(balance, currency, shortfall)
    'appLConfirmLocation': (l) => l.appLConfirmLocation,
    'appLLocationPermissionDenied': (l) => l.appLLocationPermissionDenied,
    'appLOpenSettings': (l) => l.appLOpenSettings,
    'appLEnterDays': (l) => l.appLEnterDays,
    'appLEnterDistance': (l) => l.appLEnterDistance,
    'appLEnterQuantity': (l) => l.appLEnterQuantity,
    // Wallet / Payments
    'appLMyWallet': (l) => l.appLMyWallet,
    'appLWalletBalance': (l) => l.appLWalletBalance,
    'appLAvailableBalance': (l) => l.appLAvailableBalance,
    'appLTopUpWallet': (l) => l.appLTopUpWallet,
    'appLTopUp': (l) => l.appLTopUp,
    'appLTransactions': (l) => l.appLTransactions,
    'appLRecentTransactions': (l) => l.appLRecentTransactions,
    'appLNoTransactions': (l) => l.appLNoTransactions,
    'appLLoadingTransactions': (l) => l.appLLoadingTransactions,
    'appLLoadingBalance': (l) => l.appLLoadingBalance,
    'appLTopUpSuccess': (l) => l.appLTopUpSuccess,
    'appLTopUpFailed': (l) => l.appLTopUpFailed,
    'appLPaymentProcessing': (l) => l.appLPaymentProcessing,
    'appLInsufficientBalance': (l) => l.appLInsufficientBalance,
    'appLInsufficientBalanceMessage': (l) => l.appLInsufficientBalanceMessage,
    'appLWalletChargedSuccess': (l) => l.appLWalletChargedSuccess,
    'appLWalletChargeFailed': (l) => l.appLWalletChargeFailed,
    'appLEnterAmount': (l) => l.appLEnterAmount,
    'appLAmount': (l) => l.appLAmount,
    'appLCurrency': (l) => l.appLCurrency,
    'appLPaymentType': (l) => l.appLPaymentType,
    'appLDebit': (l) => l.appLDebit,
    'appLRefund': (l) => l.appLRefund,
    'appLRefundToWallet': (l) => l.appLRefundToWallet,
    'appLRefundToCard': (l) => l.appLRefundToCard,
    'appLTransactionId': (l) => l.appLTransactionId,
    'appLTransactionStatus': (l) => l.appLTransactionStatus,
    'appLTransactionDate': (l) => l.appLTransactionDate,
    'appLProcessing': (l) => l.appLProcessing,
    'appLCompleted': (l) => l.appLCompleted,
    'appLFailed': (l) => l.appLFailed,
    'appLCancelled': (l) => l.appLCancelled,
    'appLRetry': (l) => l.appLRetry,
    'appLNoWalletBalance': (l) => l.appLNoWalletBalance,
    'appLPartialWalletPayment': (l) => l.appLPartialWalletPayment,
    // Note: parameterized translations like appLPartialPaymentMessage are
    // called directly where needed via AppLocalizations.appLPartialPaymentMessage(...)
    'appLYesContinue': (l) => l.appLYesContinue,
    'appLWalletPayment': (l) => l.appLWalletPayment,
    // KYC Verification related strings
    'appLKycRequired': (l) => l.appLKycRequired,
    'appLKycVerification': (l) => l.appLKycVerification,
    'appLCompleteKycToEnableBooking': (l) => l.appLCompleteKycToEnableBooking,
    'appLPleaseCompleteKycVerification': (l) => l.appLPleaseCompleteKycVerification,
    'appLKycPending': (l) => l.appLKycPending,
    'appLKycPendingReview': (l) => l.appLKycPendingReview,
    'appLKycPendingMessage': (l) => l.appLKycPendingMessage,
    // Profile Completion related strings
    'appLCompleteYourProfile': (l) => l.appLCompleteYourProfile,
    'appLPleaseCompleteYourProfile': (l) => l.appLPleaseCompleteYourProfile,
    'appLEnterYourFirstName': (l) => l.appLEnterYourFirstName,
    'appLEnterYourLastName': (l) => l.appLEnterYourLastName,
    'appLEnterYourEmailAddress': (l) => l.appLEnterYourEmailAddress,
    'appLFirstNameRequired': (l) => l.appLFirstNameRequired,
    'appLLastNameRequired': (l) => l.appLLastNameRequired,
    'appLEmailRequired': (l) => l.appLEmailRequired,
    'appLInvalidEmail': (l) => l.appLInvalidEmail,
    // Booking detail screen
    'appLBookingDetails': (l) => l.appLBookingDetails,
    'appLBookingId': (l) => l.appLBookingId,
    'appLReference': (l) => l.appLReference,
    'appLRentalSchedule': (l) => l.appLRentalSchedule,
    'appLPickUp': (l) => l.appLPickUp,
    'appLReturnLabel': (l) => l.appLReturnLabel,
    'appLLocationNotSpecified': (l) => l.appLLocationNotSpecified,
    'appLPriceBreakdown': (l) => l.appLPriceBreakdown,
    'appLInsuranceDaily': (l) => l.appLInsuranceDaily,
    'appLInsuranceExcessLiability': (l) => l.appLInsuranceExcessLiability,
    'appLReceipt': (l) => l.appLReceipt,
    'appLBaseRental': (l) => l.appLBaseRental,
    'appLDeliveryFee': (l) => l.appLDeliveryFee,
    'appLExtensionCharge': (l) => l.appLExtensionCharge,
    'appLPenalty': (l) => l.appLPenalty,
    'appLInvoiceTax': (l) => l.appLInvoiceTax,
    'appLInvoiceDiscount': (l) => l.appLInvoiceDiscount,
    'appLInvoiceTotal': (l) => l.appLInvoiceTotal,
    'appLPaymentMethod': (l) => l.appLPaymentMethod,
    'appLVendor': (l) => l.appLVendor,
    'appLBranchInfo': (l) => l.appLBranchInfo,
    'appLBranchName': (l) => l.appLBranchName,
    'appLOpenMap': (l) => l.appLOpenMap,
    'appLNotes': (l) => l.appLNotes,
    'appLRejectionReason': (l) => l.appLRejectionReason,
    'appLBookingNotFound': (l) => l.appLBookingNotFound,
    'appLExtendBooking': (l) => l.appLExtendBooking,
    'appLExtensionPending': (l) => l.appLExtensionPending,
    'appLAdditionalDays': (l) => l.appLAdditionalDays,
    'appLDailyRate': (l) => l.appLDailyRate,
    'appLExtraAmount': (l) => l.appLExtraAmount,
    'appLRequestExtension': (l) => l.appLRequestExtension,
    'appLRequiredAmount': (l) => l.appLRequiredAmount,
    'appLShortage': (l) => l.appLShortage,
    'appLCancelBooking': (l) => l.appLCancelBooking,
    'appLCancelBookingConfirm': (l) => l.appLCancelBookingConfirm,
    'appLNo': (l) => l.appLNo,
    'appLYesCancel': (l) => l.appLYesCancel,
    'appLDailyPrice': (l) => l.appLDailyPrice,
    'appLYes': (l) => l.appLYes,
    'appLBrowseVendorCars': (l) => l.appLBrowseVendorCars,
    'appLEnterMobileForOtp': (l) => l.appLEnterMobileForOtp,
    'appLEnterOtpCode': (l) => l.appLEnterOtpCode,
    'appLOtpSentToPhone': (l) => l.appLOtpSentToPhone,
    'appLLocationPermissionTitle': (l) => l.appLLocationPermissionTitle,
    'appLLocationPermissionMessage': (l) => l.appLLocationPermissionMessage,
    'appLAllow': (l) => l.appLAllow,
    'appLOutOfDeliveryRange': (l) => l.appLOutOfDeliveryRange,
    'appLKmAllowanceLabel': (l) => l.appLKmAllowanceLabel,
  };
  
  /// Change current language
  Future<void> changeLanguage(String languageCode) async {
    final newLocale = Locale(languageCode);
    _currentLocale.value = newLocale;
    
    // Save to local storage
    await _storage.write(_storageKey, languageCode);
    
    // Update GetX locale if using GetMaterialApp
    Get.updateLocale(newLocale);
    
    _currentLocale.refresh();
  }
  
  /// Get current text direction
  TextDirection get languageDirection {
    return _currentLocale.value.languageCode == 'ar' 
        ? TextDirection.rtl 
        : TextDirection.ltr;
  }
  
  /// Load saved language from storage
  void _loadSavedLanguage() {
    final savedLang = _storage.read<String>(_storageKey);
    if (savedLang != null && savedLang.isNotEmpty) {
      _currentLocale.value = Locale(savedLang);
    }
  }
  
  /// Update runtime translations from server
  void updateRuntimeTranslations(String languageCode, Map<String, String> translations) {
    _runtimeTranslations[languageCode] = translations;
  }
  
  /// Update available languages list
  void updateLanguages(List<LanguageModel> languagesList) {
    _languages.value = languagesList;
  }
}

/// Language model
class LanguageModel {
  final String code;
  final String name;
  final String direction;
  
  LanguageModel({
    required this.code,
    required this.name,
    this.direction = 'ltr',
  });
  
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] ?? json['language_code'] ?? '',
      name: json['name'] ?? json['language_name'] ?? '',
      direction: json['direction'] ?? 'ltr',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'direction': direction,
    };
  }
}

/// Global singleton instance
final I18n = Get.put(I18nService(), permanent: true);
