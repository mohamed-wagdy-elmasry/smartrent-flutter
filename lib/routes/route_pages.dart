part of '../routes/routes.dart';

class RoutePageList {
  static var list = [
    GetPage(
      name: Routes.settingScreen,
      page: () => const SettingScreen(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: Routes.notificationScreen,
      page: () => const NotificationScreen(),
      binding: NotificationBinding(),
    ),
    // Profile Completion & KYC Routes
    GetPage(
      name: Routes.profileCompletionScreen,
      page: () => const ProfileCompletionScreen(),
      binding: ProfileCompletionBinding(),
    ),
    GetPage(
      name: Routes.kycSubmissionScreen,
      page: () => const KycSubmissionScreen(),
      binding: KycSubmissionBinding(),
    ),
    // OTP verification routes removed
    GetPage(
      name: Routes.change_passwordScreen,
      page: () => const ChangePasswordScreen(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: Routes.previewScreen,
      page: () => const PreviewScreen(),
      binding: PreviewBinding(),
    ),
    GetPage(
      name: Routes.update_profileScreen,
      page: () => const UpdateProfileScreen(),
      binding: UpdateProfileBinding(),
    ),
    GetPage(
      name: Routes.bookingScreen,
      page: () => BookingScreen(),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.new_passwordScreen,
      page: () => const NewPasswordScreen(),
      binding: NewPasswordBinding(),
    ),
    GetPage(
      name: Routes.loginScreen,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.otpLoginScreen,
      page: () => const OtpLoginScreen(),
      binding: OtpLoginBinding(),
    ),
    GetPage(
      name: Routes.otp_verificationScreen,
      page: () => const OtpVerificationScreen(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: Routes.reset_passwordScreen,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: Routes.registerScreen,
      page: () => const RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.product_detailsScreen,
      page: () => const ProductDetailsScreen(),
      binding: ProductDetailsBinding(),
    ),
    GetPage(
      name: Routes.dashboardScreen,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.allVendorsDashboardScreen,
      page: () => const AllVendorsDashboardScreen(),
      binding: AllVendorsDashboardBinding(),
    ),
    GetPage(
      name: Routes.splashScreen,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboardScreen,
      page: () => OnboardScreen(),
      binding: OnboardBinding(),
    ),
    GetPage(
      name: Routes.historyScreen,
      page: () => HistoryScreen(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: Routes.historyDetailScreen,
      page: () => const HistoryDetailScreen(),
      binding: BookingDetailBinding(),
    ),
    GetPage(
      name: Routes.walletScreen,
      page: () => const WalletScreen(),
      binding: WalletBinding(),
    ),
    // Vendor Cars Screen
    GetPage(
      name: Routes.vendorCarsScreen,
      page: () => const VendorCarsScreen(),
      binding: VendorCarsBinding(),
    ),
      GetPage(
      name: Routes.notificationScreentest,
      page: () => const NotificationScreenTest(),
    ),
    GetPage(
      name: Routes.bookingPaymentScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return BookingPaymentScreen(
          bookingId: args['bookingId'],
          amount: args['amount'],
        );
      },
    ),
  ];
}
