import 'package:carbo/views/history/screen/history_screen.dart';
import 'package:carbo/views/history_detail/screen/history_detail_screen.dart';
import 'package:carbo/views/notification_screen.dart';
import 'package:get/get.dart';
import '../screens/booking_payment_screen.dart';
import '../bindings/booking_binding.dart';
import '../bindings/booking_detail_binding.dart';
import '../bindings/change_password_binding.dart';
import '../bindings/dashboard_binding.dart';
import '../bindings/all_vendors_dashboard_binding.dart';
import '../bindings/vendor_cars_binding.dart';
import '../bindings/wallet_binding.dart';
import '../bindings/history_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/otp_login_binding.dart';
import '../bindings/profile_completion_binding.dart';
import '../bindings/kyc_submission_binding.dart';
import '../bindings/new_password_binding.dart';
import '../bindings/notification_binding.dart';
import '../bindings/onboard_binding.dart';
import '../bindings/otp_verification_binding.dart';
import '../bindings/preview_binding.dart';
import '../bindings/product_details_binding.dart';
import '../bindings/register_binding.dart';
// register_otp_verification binding removed
import '../bindings/reset_password_binding.dart';
import '../bindings/setting_binding.dart';
import '../bindings/splash_binding.dart';
import '../bindings/update_profile_binding.dart';
// mobile_otp binding removed
import '../views/auth/change_password/screen/change_password_screen.dart';
import '../views/auth/login/screen/login_screen.dart';
import '../views/auth/otp_login/screen/otp_login_screen.dart';
import '../views/auth/new_password/screen/new_password_screen.dart';
import '../views/auth/otp_verification/screen/otp_verification_screen.dart';
import '../views/auth/register/screen/register_screen.dart';
// register_otp_verification views removed
import '../views/auth/reset_password/screen/reset_password_screen.dart';
// mobile_otp_verification views removed
import '../views/booking/screen/booking_screen.dart';
import '../views/dashboard/screen/dashboard_screen.dart';
import '../views/all_vendors_dashboard/screen/all_vendors_dashboard_screen.dart';
import '../views/vendor_cars/screen/vendor_cars_screen.dart';
import '../views/notification/screen/notification_screen.dart';
import '../views/onboard/screen/onboard_screen.dart';
import '../views/preview/screen/preview_screen.dart';
import '../views/product_details/screen/product_details_screen.dart';
import '../views/setting/screen/setting_screen.dart';
import '../views/splash/screen/splash_screen.dart';
import '../views/update_profile/screen/update_profile_screen.dart';
import '../views/profile_completion/screen/profile_completion_screen.dart';
import '../views/kyc_submission/screen/kyc_submission_screen.dart';
import '../views/wallet/wallet_screen.dart';

part '../routes/route_pages.dart';

class Routes {
  // Page List
  static var list = RoutePageList.list;

  // Route Names
  static const String splashScreen = '/splashScreen';
  static const String onboardScreen = '/onboardScreen';
  static const String cartScreen = '/cartScreen';
  static const String dashboardScreen = '/dashboardScreen';
  static const String allVendorsDashboardScreen = '/allVendorsDashboardScreen';
  static const String product_detailsScreen = '/product_detailsScreen';
  static const String authScreen = '/authScreen';
  static const String registerScreen = '/registerScreen';
  static const String resetPassword = '/reset_password';
  static const String reset_passwordScreen = '/reset_passwordScreen';
  static const String otp_verificationScreen = '/otp_verificationScreen';
  static const String loginScreen = '/loginScreen';
  static const String otpLoginScreen = '/otpLoginScreen';
  static const String new_passwordScreen = '/new_passwordScreen';
  static const String bookingScreen = '/bookingScreen';
  static const String update_profileScreen = '/update_profileScreen';
  static const String previewScreen = '/previewScreen';
  static const String change_passwordScreen = '/change_passwordScreen';
  static const String congratulationScreen = '/congratulationScreen';
  // register_otp_verificationScreen removed
  // mobile_otp_verificationScreen removed
  static const String notificationScreen = '/notificationScreen';
  static const String drawerScreen = '/drawerScreen';
  static const String historyScreen = '/historyScreen';
  static const String historyDetailScreen = '/historyDetailScreen';
  static const String walletScreen = '/walletScreen';
  static const String paymentManualField = '/paymentManualField';
  static const String RePaymentManualField = '/RePaymentManualField';
  static const String settingScreen = '/settingScreen';
  static const String profileCompletionScreen = '/profileCompletionScreen';
  static const String kycSubmissionScreen = '/kycSubmissionScreen';
  static const String vendorCarsScreen = '/vendorCarsScreen';
  static const String notificationScreentest = '/notificationScreentest';
  static const String bookingPaymentScreen = '/bookingPaymentScreen';
}
