import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appLPleaseFillOutTheField.
  ///
  /// In en, this message translates to:
  /// **'Please fill out the field'**
  String get appLPleaseFillOutTheField;

  /// No description provided for @appLAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get appLAll;

  /// No description provided for @appLFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get appLFrom;

  /// No description provided for @appLFromGallery.
  ///
  /// In en, this message translates to:
  /// **'From Gallery'**
  String get appLFromGallery;

  /// No description provided for @appLFromCamera.
  ///
  /// In en, this message translates to:
  /// **'From Camera'**
  String get appLFromCamera;

  /// No description provided for @appLHistory.
  ///
  /// In en, this message translates to:
  /// **'My History'**
  String get appLHistory;

  /// No description provided for @appLPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get appLPrivacyPolicy;

  /// No description provided for @appLPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get appLPreview;

  /// No description provided for @appLLogOutAlert.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get appLLogOutAlert;

  /// No description provided for @appLAboutUs.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get appLAboutUs;

  /// No description provided for @appLBookingPreview.
  ///
  /// In en, this message translates to:
  /// **'Booking Preview'**
  String get appLBookingPreview;

  /// No description provided for @appLPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get appLPayment;

  /// No description provided for @appLConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get appLConfirmation;

  /// No description provided for @appLSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get appLSuccess;

  /// No description provided for @appLBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get appLBack;

  /// No description provided for @appLBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get appLBackToHome;

  /// No description provided for @appLServerError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get appLServerError;

  /// No description provided for @appLPaymentInstructions.
  ///
  /// In en, this message translates to:
  /// **'Payment Instructions'**
  String get appLPaymentInstructions;

  /// No description provided for @appLNewToCarbo.
  ///
  /// In en, this message translates to:
  /// **'New to Carbo'**
  String get appLNewToCarbo;

  /// No description provided for @appLAgreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'Agree to Terms'**
  String get appLAgreeToTerms;

  /// No description provided for @appLSpeed.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get appLSpeed;

  /// No description provided for @appLKmCharge.
  ///
  /// In en, this message translates to:
  /// **'KM Charge'**
  String get appLKmCharge;

  /// No description provided for @appLHelpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get appLHelpCenter;

  /// No description provided for @appLAcceleration.
  ///
  /// In en, this message translates to:
  /// **'Acceleration'**
  String get appLAcceleration;

  /// No description provided for @appLTotalBooked.
  ///
  /// In en, this message translates to:
  /// **'Total Booked'**
  String get appLTotalBooked;

  /// No description provided for @appLCompleteRide.
  ///
  /// In en, this message translates to:
  /// **'Complete Ride'**
  String get appLCompleteRide;

  /// No description provided for @appLRoundTrip.
  ///
  /// In en, this message translates to:
  /// **'Round Trip'**
  String get appLRoundTrip;

  /// No description provided for @appLBookingReject.
  ///
  /// In en, this message translates to:
  /// **'Booking Rejected'**
  String get appLBookingReject;

  /// No description provided for @appLTopSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top Speed'**
  String get appLTopSpeed;

  /// No description provided for @appLPeakPower.
  ///
  /// In en, this message translates to:
  /// **'Peak Power'**
  String get appLPeakPower;

  /// No description provided for @appLPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get appLPending;

  /// No description provided for @appLPleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please Wait'**
  String get appLPleaseWait;

  /// No description provided for @appLSetting.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appLSetting;

  /// No description provided for @appLOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get appLOngoing;

  /// No description provided for @appLComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get appLComplete;

  /// No description provided for @appLReject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get appLReject;

  /// No description provided for @appLRange.
  ///
  /// In en, this message translates to:
  /// **'Range'**
  String get appLRange;

  /// No description provided for @appLDetails.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get appLDetails;

  /// No description provided for @appLReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get appLReview;

  /// No description provided for @appLPerMonth.
  ///
  /// In en, this message translates to:
  /// **'Per Month'**
  String get appLPerMonth;

  /// No description provided for @appLBookNow.
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get appLBookNow;

  /// No description provided for @appLBookYorCarVendor.
  ///
  /// In en, this message translates to:
  /// **'Book Your Car'**
  String get appLBookYorCarVendor;

  /// No description provided for @appLBook.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get appLBook;

  /// No description provided for @appLCarNumber.
  ///
  /// In en, this message translates to:
  /// **'Car Number'**
  String get appLCarNumber;

  /// No description provided for @appLTotalSeat.
  ///
  /// In en, this message translates to:
  /// **'Total Seats'**
  String get appLTotalSeat;

  /// No description provided for @appLExperience.
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get appLExperience;

  /// No description provided for @appLCarModel.
  ///
  /// In en, this message translates to:
  /// **'Car Model'**
  String get appLCarModel;

  /// No description provided for @appLYourLocation.
  ///
  /// In en, this message translates to:
  /// **'Your Location'**
  String get appLYourLocation;

  /// No description provided for @appLLogin.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get appLLogin;

  /// No description provided for @appLNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get appLNotification;

  /// No description provided for @appLNoNotification.
  ///
  /// In en, this message translates to:
  /// **'No Notification'**
  String get appLNoNotification;

  /// No description provided for @appLNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No History'**
  String get appLNoHistory;

  /// No description provided for @appLLoginNow.
  ///
  /// In en, this message translates to:
  /// **'Login Now'**
  String get appLLoginNow;

  /// No description provided for @appLRegisterNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get appLRegisterNow;

  /// No description provided for @appLEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get appLEmail;

  /// No description provided for @appLForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get appLForgotPassword;

  /// No description provided for @appLAlreadyHaveAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get appLAlreadyHaveAnAccount;

  /// No description provided for @appLFirstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get appLFirstName;

  /// No description provided for @appLLastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get appLLastName;

  /// No description provided for @appLPickUpLocation.
  ///
  /// In en, this message translates to:
  /// **'Pick Up Location'**
  String get appLPickUpLocation;

  /// No description provided for @appLWriteHere.
  ///
  /// In en, this message translates to:
  /// **'Write here'**
  String get appLWriteHere;

  /// No description provided for @appLDestination.
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get appLDestination;

  /// No description provided for @appLDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get appLDistance;

  /// No description provided for @appLPickUpdate.
  ///
  /// In en, this message translates to:
  /// **'Pick Up Date'**
  String get appLPickUpdate;

  /// No description provided for @appLStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get appLStatus;

  /// No description provided for @appLNoCarFindMessage.
  ///
  /// In en, this message translates to:
  /// **'No cars found'**
  String get appLNoCarFindMessage;

  /// No description provided for @appLTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get appLTotalAmount;

  /// No description provided for @appLTotalRent.
  ///
  /// In en, this message translates to:
  /// **'Total Rent'**
  String get appLTotalRent;

  /// No description provided for @appLRate.
  ///
  /// In en, this message translates to:
  /// **'Rate'**
  String get appLRate;

  /// No description provided for @appLTotalPayable.
  ///
  /// In en, this message translates to:
  /// **'Total Payable'**
  String get appLTotalPayable;

  /// No description provided for @appLPickUpTime.
  ///
  /// In en, this message translates to:
  /// **'Pick Up Time'**
  String get appLPickUpTime;

  /// No description provided for @appLEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get appLEmailAddress;

  /// No description provided for @appLPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get appLPassword;

  /// No description provided for @appLIHaveAgreedWith.
  ///
  /// In en, this message translates to:
  /// **'I have agreed with'**
  String get appLIHaveAgreedWith;

  /// No description provided for @appLTermsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get appLTermsOfUse;

  /// No description provided for @appLSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get appLSendOtp;

  /// No description provided for @appLError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get appLError;

  /// No description provided for @appLPleaseEnterTheCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the code'**
  String get appLPleaseEnterTheCode;

  /// No description provided for @appLWeSentADigitCode.
  ///
  /// In en, this message translates to:
  /// **'We sent a digit code'**
  String get appLWeSentADigitCode;

  /// No description provided for @appLDidntGetTheCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t get the code?'**
  String get appLDidntGetTheCode;

  /// No description provided for @appLResend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get appLResend;

  /// No description provided for @appLSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get appLSubmit;

  /// No description provided for @appLLogInTitleText.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get appLLogInTitleText;

  /// No description provided for @appLResetPasswordTitleText.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get appLResetPasswordTitleText;

  /// No description provided for @appLResetPasswordDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to reset password'**
  String get appLResetPasswordDescriptionText;

  /// No description provided for @appLLogInDescriptionText.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please login to continue'**
  String get appLLogInDescriptionText;

  /// No description provided for @appLYouCanResend.
  ///
  /// In en, this message translates to:
  /// **'You can resend'**
  String get appLYouCanResend;

  /// No description provided for @appLSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get appLSkip;

  /// No description provided for @appLNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get appLNewPassword;

  /// No description provided for @appLConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get appLConfirmPassword;

  /// No description provided for @appLChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get appLChangePassword;

  /// No description provided for @appLOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old Password'**
  String get appLOldPassword;

  /// No description provided for @appLResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get appLResetPassword;

  /// No description provided for @appLResetPasswordTile.
  ///
  /// In en, this message translates to:
  /// **'Reset Your Password'**
  String get appLResetPasswordTile;

  /// No description provided for @appLResetPasswordDes.
  ///
  /// In en, this message translates to:
  /// **'Enter your new password below'**
  String get appLResetPasswordDes;

  /// No description provided for @appLCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get appLCountry;

  /// No description provided for @appLSelectArea.
  ///
  /// In en, this message translates to:
  /// **'Select Area'**
  String get appLSelectArea;

  /// No description provided for @appLSelectADate.
  ///
  /// In en, this message translates to:
  /// **'Select a Date'**
  String get appLSelectADate;

  /// No description provided for @appLSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select Type'**
  String get appLSelectType;

  /// No description provided for @appLSelectModel.
  ///
  /// In en, this message translates to:
  /// **'Select Model'**
  String get appLSelectModel;

  /// No description provided for @appLSelectYear.
  ///
  /// In en, this message translates to:
  /// **'Select Year'**
  String get appLSelectYear;

  /// No description provided for @appLPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get appLPhone;

  /// No description provided for @appLAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get appLAddress;

  /// No description provided for @appLCity.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get appLCity;

  /// No description provided for @appLAllCities.
  ///
  /// In en, this message translates to:
  /// **'All Cities'**
  String get appLAllCities;

  /// No description provided for @appLState.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get appLState;

  /// No description provided for @appLZipCode.
  ///
  /// In en, this message translates to:
  /// **'Zip Code'**
  String get appLZipCode;

  /// No description provided for @appLUpdate.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get appLUpdate;

  /// No description provided for @appLEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get appLEditProfile;

  /// No description provided for @appLPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get appLPersonalInformation;

  /// No description provided for @appLContactInformation.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get appLContactInformation;

  /// No description provided for @appLAddressInformation.
  ///
  /// In en, this message translates to:
  /// **'Address Information'**
  String get appLAddressInformation;

  /// No description provided for @appLDocumentUploads.
  ///
  /// In en, this message translates to:
  /// **'Document Uploads'**
  String get appLDocumentUploads;

  /// No description provided for @appLNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get appLNationalId;

  /// No description provided for @appLDrivingLicense.
  ///
  /// In en, this message translates to:
  /// **'Driving License'**
  String get appLDrivingLicense;

  /// No description provided for @appLDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get appLDelete;

  /// No description provided for @appLSelectATime.
  ///
  /// In en, this message translates to:
  /// **'Select a Time'**
  String get appLSelectATime;

  /// No description provided for @appLFindCar.
  ///
  /// In en, this message translates to:
  /// **'Find Car'**
  String get appLFindCar;

  /// No description provided for @appLNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get appLNote;

  /// No description provided for @appLRoundTripDate.
  ///
  /// In en, this message translates to:
  /// **'Round Trip Date'**
  String get appLRoundTripDate;

  /// No description provided for @appLRoundTripTime.
  ///
  /// In en, this message translates to:
  /// **'Round Trip Time'**
  String get appLRoundTripTime;

  /// No description provided for @appLOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get appLOptional;

  /// No description provided for @appLNoDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data Found'**
  String get appLNoDataFound;

  /// No description provided for @appLBookingSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Booking Successful'**
  String get appLBookingSuccessfully;

  /// No description provided for @appLConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get appLConfirm;

  /// No description provided for @appLPayWIth.
  ///
  /// In en, this message translates to:
  /// **'Pay With'**
  String get appLPayWIth;

  /// No description provided for @appLNoContentAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Content Available'**
  String get appLNoContentAvailable;

  /// No description provided for @appLSelectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get appLSelectCurrency;

  /// No description provided for @appLSelectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get appLSelectCountry;

  /// No description provided for @appLSelectMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Method'**
  String get appLSelectMethod;

  /// No description provided for @appLConfirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get appLConfirmBooking;

  /// No description provided for @appLLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appLLanguage;

  /// No description provided for @appLAreYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get appLAreYouSure;

  /// No description provided for @appLAreYouSureDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete?'**
  String get appLAreYouSureDelete;

  /// No description provided for @appLLocationNotAbleAble.
  ///
  /// In en, this message translates to:
  /// **'Location not available'**
  String get appLLocationNotAbleAble;

  /// No description provided for @appLLogOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get appLLogOut;

  /// No description provided for @appLLogOu.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get appLLogOu;

  /// No description provided for @appLCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get appLCancel;

  /// No description provided for @appLLongTitle.
  ///
  /// In en, this message translates to:
  /// **'Long Title'**
  String get appLLongTitle;

  /// No description provided for @appLLongText.
  ///
  /// In en, this message translates to:
  /// **'Long Text'**
  String get appLLongText;

  /// No description provided for @appLContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get appLContactUs;

  /// No description provided for @appLRestart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get appLRestart;

  /// No description provided for @appLSeats.
  ///
  /// In en, this message translates to:
  /// **'Seats'**
  String get appLSeats;

  /// No description provided for @appLYears.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get appLYears;

  /// No description provided for @appLEnter.
  ///
  /// In en, this message translates to:
  /// **'Enter'**
  String get appLEnter;

  /// No description provided for @appLCashPayment.
  ///
  /// In en, this message translates to:
  /// **'Cash Payment'**
  String get appLCashPayment;

  /// No description provided for @appLOnlinePayment.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get appLOnlinePayment;

  /// No description provided for @appLContinuee.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get appLContinuee;

  /// No description provided for @appLCvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get appLCvv;

  /// No description provided for @appLCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get appLCardNumber;

  /// No description provided for @appLExpirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get appLExpirationDate;

  /// No description provided for @appLDebitCardPayment.
  ///
  /// In en, this message translates to:
  /// **'Debit Card Payment'**
  String get appLDebitCardPayment;

  /// No description provided for @appLPaymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get appLPaymentSuccessful;

  /// No description provided for @appLMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get appLMobileNumber;

  /// No description provided for @appLEnterMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter Mobile Number'**
  String get appLEnterMobileNumber;

  /// No description provided for @appLVerifyOtp.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get appLVerifyOtp;

  /// No description provided for @appLOtpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get appLOtpVerification;

  /// No description provided for @appLEnterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get appLEnterOtp;

  /// No description provided for @appLVerifyAndLogin.
  ///
  /// In en, this message translates to:
  /// **'Verify and Login'**
  String get appLVerifyAndLogin;

  /// No description provided for @appLVerifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify and Continue'**
  String get appLVerifyAndContinue;

  /// No description provided for @appLLoginWithPassword.
  ///
  /// In en, this message translates to:
  /// **'Login with Password'**
  String get appLLoginWithPassword;

  /// No description provided for @appLLoginWithOtp.
  ///
  /// In en, this message translates to:
  /// **'Login with OTP'**
  String get appLLoginWithOtp;

  /// No description provided for @appLInvalidPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid Phone Number'**
  String get appLInvalidPhoneNumber;

  /// No description provided for @appLPleaseEnterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get appLPleaseEnterValidPhone;

  /// No description provided for @appLInvalidOtp.
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get appLInvalidOtp;

  /// No description provided for @appLOtpSent.
  ///
  /// In en, this message translates to:
  /// **'OTP Sent'**
  String get appLOtpSent;

  /// No description provided for @appLCheckMobileForOtp.
  ///
  /// In en, this message translates to:
  /// **'Check your mobile for OTP'**
  String get appLCheckMobileForOtp;

  /// No description provided for @appLMobileVerified.
  ///
  /// In en, this message translates to:
  /// **'Mobile Verified'**
  String get appLMobileVerified;

  /// No description provided for @appLMobileVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Mobile verified successfully'**
  String get appLMobileVerifiedSuccessfully;

  /// No description provided for @appLMobileNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Mobile Not Verified'**
  String get appLMobileNotVerified;

  /// No description provided for @appLVerifyMobileFirst.
  ///
  /// In en, this message translates to:
  /// **'Verify mobile first'**
  String get appLVerifyMobileFirst;

  /// No description provided for @appLResendOtp.
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get appLResendOtp;

  /// No description provided for @appLCountryCode.
  ///
  /// In en, this message translates to:
  /// **'Country Code'**
  String get appLCountryCode;

  /// No description provided for @appLEnterSixDigitOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP'**
  String get appLEnterSixDigitOtp;

  /// No description provided for @appLAvailableCars.
  ///
  /// In en, this message translates to:
  /// **'Available Cars'**
  String get appLAvailableCars;

  /// No description provided for @appLCarsAvailable.
  ///
  /// In en, this message translates to:
  /// **'Cars Available'**
  String get appLCarsAvailable;

  /// No description provided for @appLLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get appLLoadMore;

  /// No description provided for @appLAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get appLAvailable;

  /// No description provided for @appLLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited'**
  String get appLLimited;

  /// No description provided for @appLInsuranceIncluded.
  ///
  /// In en, this message translates to:
  /// **'Insurance Included'**
  String get appLInsuranceIncluded;

  /// No description provided for @appLAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get appLAutomatic;

  /// No description provided for @appLPetrol.
  ///
  /// In en, this message translates to:
  /// **'Petrol'**
  String get appLPetrol;

  /// No description provided for @appLTransmission.
  ///
  /// In en, this message translates to:
  /// **'Transmission'**
  String get appLTransmission;

  /// No description provided for @appLFuelType.
  ///
  /// In en, this message translates to:
  /// **'Fuel Type'**
  String get appLFuelType;

  /// No description provided for @appLNoCarsFound.
  ///
  /// In en, this message translates to:
  /// **'No Cars Found'**
  String get appLNoCarsFound;

  /// No description provided for @appLTryDifferentFilters.
  ///
  /// In en, this message translates to:
  /// **'Try different filters'**
  String get appLTryDifferentFilters;

  /// No description provided for @appLSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get appLSortBy;

  /// No description provided for @appLPriceLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: Low to High'**
  String get appLPriceLowToHigh;

  /// No description provided for @appLPriceHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Price: High to Low'**
  String get appLPriceHighToLow;

  /// No description provided for @appLPopularity.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get appLPopularity;

  /// No description provided for @appLRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get appLRating;

  /// No description provided for @appLPullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to Refresh'**
  String get appLPullToRefresh;

  /// No description provided for @appLRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Refreshing'**
  String get appLRefreshing;

  /// No description provided for @appLAllCars.
  ///
  /// In en, this message translates to:
  /// **'All Cars'**
  String get appLAllCars;

  /// No description provided for @appLFilterBy.
  ///
  /// In en, this message translates to:
  /// **'Filter By'**
  String get appLFilterBy;

  /// No description provided for @appLShowResults.
  ///
  /// In en, this message translates to:
  /// **'Show Results'**
  String get appLShowResults;

  /// No description provided for @appLRentalDays.
  ///
  /// In en, this message translates to:
  /// **'Rental Days'**
  String get appLRentalDays;

  /// No description provided for @appLDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get appLDay;

  /// No description provided for @appLPricePerDay.
  ///
  /// In en, this message translates to:
  /// **'Daily Price'**
  String get appLPricePerDay;

  /// No description provided for @appLPricePerKm.
  ///
  /// In en, this message translates to:
  /// **'Daily Price'**
  String get appLPricePerKm;

  /// No description provided for @appLDeliveryCharge.
  ///
  /// In en, this message translates to:
  /// **'Delivery Charge'**
  String get appLDeliveryCharge;

  /// No description provided for @appLDeliveryCar.
  ///
  /// In en, this message translates to:
  /// **'Deliver Car'**
  String get appLDeliveryCar;

  /// No description provided for @appLTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get appLTax;

  /// No description provided for @appLTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get appLTotal;

  /// No description provided for @appLQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get appLQuantity;

  /// No description provided for @appLSelectInsurance.
  ///
  /// In en, this message translates to:
  /// **'Select Insurance'**
  String get appLSelectInsurance;

  /// No description provided for @appLDailyInsurance.
  ///
  /// In en, this message translates to:
  /// **'Daily Insurance'**
  String get appLDailyInsurance;

  /// No description provided for @appLExcessLiabilityInsurance.
  ///
  /// In en, this message translates to:
  /// **'Excess Liability Insurance'**
  String get appLExcessLiabilityInsurance;

  /// No description provided for @appLInsuranceType.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get appLInsuranceType;

  /// No description provided for @appLInsuranceAmount.
  ///
  /// In en, this message translates to:
  /// **'Insurance Amount'**
  String get appLInsuranceAmount;

  /// No description provided for @appLInsuranceWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: You selected Excess Liability Insurance'**
  String get appLInsuranceWarning;

  /// No description provided for @appLSnappedOutsideAllowed.
  ///
  /// In en, this message translates to:
  /// **'Selected location was outside the allowed area — snapped to nearest allowed point.'**
  String get appLSnappedOutsideAllowed;

  /// No description provided for @appLSnappedShort.
  ///
  /// In en, this message translates to:
  /// **'Snapped to allowed area'**
  String get appLSnappedShort;

  /// No description provided for @appLCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current Location'**
  String get appLCurrentLocation;

  /// No description provided for @appLCenter.
  ///
  /// In en, this message translates to:
  /// **'Center'**
  String get appLCenter;

  /// No description provided for @appLLatLngFormat.
  ///
  /// In en, this message translates to:
  /// **'Lat: {lat}, Lng: {lng}'**
  String appLLatLngFormat(Object lat, Object lng);

  /// No description provided for @appLSelectedLocation.
  ///
  /// In en, this message translates to:
  /// **'Selected Location:'**
  String get appLSelectedLocation;

  /// No description provided for @appLKmAllowanceLabel.
  ///
  /// In en, this message translates to:
  /// **'KM Allowance'**
  String get appLKmAllowanceLabel;

  /// No description provided for @appLKmAllowanceMessage.
  ///
  /// In en, this message translates to:
  /// **'The allowed kilometers are {km} km, and if exceeded, will be charged {charge} SAR/km for each additional kilometer.'**
  String appLKmAllowanceMessage(Object charge, Object km);

  /// No description provided for @appLDistanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance: {km} km'**
  String appLDistanceLabel(Object km);

  /// No description provided for @appLConfirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Location'**
  String get appLConfirmLocation;

  /// No description provided for @appLLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission denied. Open settings to enable location.'**
  String get appLLocationPermissionDenied;

  /// No description provided for @appLOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get appLOpenSettings;

  /// No description provided for @appLEnterDays.
  ///
  /// In en, this message translates to:
  /// **'Enter Days'**
  String get appLEnterDays;

  /// No description provided for @appLEnterDistance.
  ///
  /// In en, this message translates to:
  /// **'Enter Distance'**
  String get appLEnterDistance;

  /// No description provided for @appLEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter Quantity'**
  String get appLEnterQuantity;

  /// No description provided for @appLMyWallet.
  ///
  /// In en, this message translates to:
  /// **'My Wallet'**
  String get appLMyWallet;

  /// No description provided for @appLWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet Balance'**
  String get appLWalletBalance;

  /// No description provided for @appLAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get appLAvailableBalance;

  /// No description provided for @appLTopUpWallet.
  ///
  /// In en, this message translates to:
  /// **'Top Up Wallet'**
  String get appLTopUpWallet;

  /// No description provided for @appLTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top Up'**
  String get appLTopUp;

  /// No description provided for @appLTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get appLTransactions;

  /// No description provided for @appLRecentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get appLRecentTransactions;

  /// No description provided for @appLNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get appLNoTransactions;

  /// No description provided for @appLLoadingTransactions.
  ///
  /// In en, this message translates to:
  /// **'Loading transactions...'**
  String get appLLoadingTransactions;

  /// No description provided for @appLLoadingBalance.
  ///
  /// In en, this message translates to:
  /// **'Loading balance...'**
  String get appLLoadingBalance;

  /// No description provided for @appLTopUpSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet top-up successful!'**
  String get appLTopUpSuccess;

  /// No description provided for @appLTopUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Wallet top-up failed'**
  String get appLTopUpFailed;

  /// No description provided for @appLPaymentProcessing.
  ///
  /// In en, this message translates to:
  /// **'Payment processing - please check transactions later'**
  String get appLPaymentProcessing;

  /// No description provided for @appLInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient wallet balance'**
  String get appLInsufficientBalance;

  /// No description provided for @appLInsufficientBalanceMessage.
  ///
  /// In en, this message translates to:
  /// **'Your wallet has insufficient funds. Please top up.'**
  String get appLInsufficientBalanceMessage;

  /// No description provided for @appLWalletChargedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Wallet charged successfully'**
  String get appLWalletChargedSuccess;

  /// No description provided for @appLWalletChargeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to charge wallet'**
  String get appLWalletChargeFailed;

  /// No description provided for @appLEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get appLEnterAmount;

  /// No description provided for @appLAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get appLAmount;

  /// No description provided for @appLCurrency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get appLCurrency;

  /// No description provided for @appLPaymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment Type'**
  String get appLPaymentType;

  /// No description provided for @appLDebit.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get appLDebit;

  /// No description provided for @appLRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get appLRefund;

  /// No description provided for @appLRefundToWallet.
  ///
  /// In en, this message translates to:
  /// **'Refund to Wallet'**
  String get appLRefundToWallet;

  /// No description provided for @appLRefundToCard.
  ///
  /// In en, this message translates to:
  /// **'Refund to Card'**
  String get appLRefundToCard;

  /// No description provided for @appLTransactionId.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get appLTransactionId;

  /// No description provided for @appLTransactionStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get appLTransactionStatus;

  /// No description provided for @appLTransactionDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get appLTransactionDate;

  /// No description provided for @appLProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get appLProcessing;

  /// No description provided for @appLCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get appLCompleted;

  /// No description provided for @appLFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get appLFailed;

  /// No description provided for @appLCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get appLCancelled;

  /// No description provided for @appLRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get appLRetry;

  /// No description provided for @appLNoWalletBalance.
  ///
  /// In en, this message translates to:
  /// **'No wallet balance available'**
  String get appLNoWalletBalance;

  /// No description provided for @appLPartialWalletPayment.
  ///
  /// In en, this message translates to:
  /// **'Partial Wallet Payment'**
  String get appLPartialWalletPayment;

  /// No description provided for @appLPartialPaymentMessage.
  ///
  /// In en, this message translates to:
  /// **'Your wallet has {balance} {currency}. Pay {shortfall} {currency} via card?'**
  String appLPartialPaymentMessage(
    Object balance,
    Object currency,
    Object shortfall,
  );

  /// No description provided for @appLYesContinue.
  ///
  /// In en, this message translates to:
  /// **'Yes, Continue'**
  String get appLYesContinue;

  /// No description provided for @appLWalletPayment.
  ///
  /// In en, this message translates to:
  /// **'Wallet Payment'**
  String get appLWalletPayment;

  /// No description provided for @appLKycRequired.
  ///
  /// In en, this message translates to:
  /// **'KYC Required'**
  String get appLKycRequired;

  /// No description provided for @appLKycVerification.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get appLKycVerification;

  /// No description provided for @appLCompleteKycToEnableBooking.
  ///
  /// In en, this message translates to:
  /// **'Complete KYC to enable booking'**
  String get appLCompleteKycToEnableBooking;

  /// No description provided for @appLPleaseCompleteKycVerification.
  ///
  /// In en, this message translates to:
  /// **'Please complete KYC verification to book cars.'**
  String get appLPleaseCompleteKycVerification;

  /// No description provided for @appLKycPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get appLKycPending;

  /// No description provided for @appLKycPendingReview.
  ///
  /// In en, this message translates to:
  /// **'Your KYC is being reviewed'**
  String get appLKycPendingReview;

  /// No description provided for @appLKycPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Your KYC is pending review. We will notify you once it is verified.'**
  String get appLKycPendingMessage;

  /// No description provided for @appLCompleteYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get appLCompleteYourProfile;

  /// No description provided for @appLPleaseCompleteYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Please complete your profile to continue'**
  String get appLPleaseCompleteYourProfile;

  /// No description provided for @appLEnterYourFirstName.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get appLEnterYourFirstName;

  /// No description provided for @appLEnterYourLastName.
  ///
  /// In en, this message translates to:
  /// **'Enter your last name'**
  String get appLEnterYourLastName;

  /// No description provided for @appLEnterYourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get appLEnterYourEmailAddress;

  /// No description provided for @appLFirstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get appLFirstNameRequired;

  /// No description provided for @appLLastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get appLLastNameRequired;

  /// No description provided for @appLEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get appLEmailRequired;

  /// No description provided for @appLInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get appLInvalidEmail;

  /// No description provided for @appLContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get appLContinue;

  /// No description provided for @appLBookingDetails.
  ///
  /// In en, this message translates to:
  /// **'Booking Details'**
  String get appLBookingDetails;

  /// No description provided for @appLBookingInformation.
  ///
  /// In en, this message translates to:
  /// **'Booking Information'**
  String get appLBookingInformation;

  /// No description provided for @appLCarDetails.
  ///
  /// In en, this message translates to:
  /// **'Car Details'**
  String get appLCarDetails;

  /// No description provided for @appLTripDetails.
  ///
  /// In en, this message translates to:
  /// **'Trip Details'**
  String get appLTripDetails;

  /// No description provided for @appLContactDetails.
  ///
  /// In en, this message translates to:
  /// **'Contact Details'**
  String get appLContactDetails;

  /// No description provided for @appLMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get appLMessage;

  /// No description provided for @appLDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get appLDraft;

  /// No description provided for @appLApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get appLApproved;

  /// No description provided for @appLCancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Booking'**
  String get appLCancelBooking;

  /// No description provided for @appLCancelBookingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this booking? This action cannot be undone.'**
  String get appLCancelBookingConfirm;

  /// No description provided for @appLExtendBooking.
  ///
  /// In en, this message translates to:
  /// **'Extend Booking'**
  String get appLExtendBooking;

  /// No description provided for @appLExtensionPending.
  ///
  /// In en, this message translates to:
  /// **'Extension Pending'**
  String get appLExtensionPending;

  /// No description provided for @appLPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get appLPay;

  /// No description provided for @appLInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get appLInfo;

  /// No description provided for @appLLedger.
  ///
  /// In en, this message translates to:
  /// **'Ledger'**
  String get appLLedger;

  /// No description provided for @appLExtensions.
  ///
  /// In en, this message translates to:
  /// **'Extensions'**
  String get appLExtensions;

  /// No description provided for @appLTotalCharges.
  ///
  /// In en, this message translates to:
  /// **'Total Charges'**
  String get appLTotalCharges;

  /// No description provided for @appLTotalCredits.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get appLTotalCredits;

  /// No description provided for @appLBalanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get appLBalanceDue;

  /// No description provided for @appLNoTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get appLNoTransactionsYet;

  /// No description provided for @appLBaseRental.
  ///
  /// In en, this message translates to:
  /// **'Base Rental'**
  String get appLBaseRental;

  /// No description provided for @appLDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get appLDelivery;

  /// No description provided for @appLExtensionCharge.
  ///
  /// In en, this message translates to:
  /// **'Extension'**
  String get appLExtensionCharge;

  /// No description provided for @appLPenalty.
  ///
  /// In en, this message translates to:
  /// **'Penalty'**
  String get appLPenalty;

  /// No description provided for @appLPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get appLPaid;

  /// No description provided for @appLCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get appLCash;

  /// No description provided for @appLCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get appLCard;

  /// No description provided for @appLWallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get appLWallet;

  /// No description provided for @appLBankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get appLBankTransfer;

  /// No description provided for @appLNoExtensionsRequested.
  ///
  /// In en, this message translates to:
  /// **'No extensions requested'**
  String get appLNoExtensionsRequested;

  /// No description provided for @appLAdditionalDays.
  ///
  /// In en, this message translates to:
  /// **'Additional Days'**
  String get appLAdditionalDays;

  /// No description provided for @appLDailyRate.
  ///
  /// In en, this message translates to:
  /// **'Daily Rate'**
  String get appLDailyRate;

  /// No description provided for @appLExtraAmount.
  ///
  /// In en, this message translates to:
  /// **'Extra Amount'**
  String get appLExtraAmount;

  /// No description provided for @appLCurrentReturn.
  ///
  /// In en, this message translates to:
  /// **'Current Return'**
  String get appLCurrentReturn;

  /// No description provided for @appLNewReturn.
  ///
  /// In en, this message translates to:
  /// **'New Return'**
  String get appLNewReturn;

  /// No description provided for @appLNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get appLNotes;

  /// No description provided for @appLRequestExtension.
  ///
  /// In en, this message translates to:
  /// **'Request Extension'**
  String get appLRequestExtension;

  /// No description provided for @appLPreviewExtension.
  ///
  /// In en, this message translates to:
  /// **'Preview Extension'**
  String get appLPreviewExtension;

  /// No description provided for @appLExtensionApproved.
  ///
  /// In en, this message translates to:
  /// **'Extension Approved'**
  String get appLExtensionApproved;

  /// No description provided for @appLExtensionRejected.
  ///
  /// In en, this message translates to:
  /// **'Extension Rejected'**
  String get appLExtensionRejected;

  /// No description provided for @appLRejectionReason.
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get appLRejectionReason;

  /// No description provided for @appLRequiredAmount.
  ///
  /// In en, this message translates to:
  /// **'Required Amount'**
  String get appLRequiredAmount;

  /// No description provided for @appLShortage.
  ///
  /// In en, this message translates to:
  /// **'Shortage'**
  String get appLShortage;

  /// No description provided for @appLDeliveryMode.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get appLDeliveryMode;

  /// No description provided for @appLPickupMode.
  ///
  /// In en, this message translates to:
  /// **'Pickup'**
  String get appLPickupMode;

  /// No description provided for @appLInvoiceRental.
  ///
  /// In en, this message translates to:
  /// **'Rental'**
  String get appLInvoiceRental;

  /// No description provided for @appLInvoiceDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get appLInvoiceDelivery;

  /// No description provided for @appLInvoiceTax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get appLInvoiceTax;

  /// No description provided for @appLInvoiceDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get appLInvoiceDiscount;

  /// No description provided for @appLInvoiceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get appLInvoiceTotal;

  /// No description provided for @appLPriceBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Price Breakdown'**
  String get appLPriceBreakdown;

  /// No description provided for @appLInsuranceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Insurance'**
  String get appLInsuranceDaily;

  /// No description provided for @appLInsuranceExcessLiability.
  ///
  /// In en, this message translates to:
  /// **'Excess Liability Insurance'**
  String get appLInsuranceExcessLiability;

  /// No description provided for @appLRentalSchedule.
  ///
  /// In en, this message translates to:
  /// **'Rental Schedule'**
  String get appLRentalSchedule;

  /// No description provided for @appLPickUp.
  ///
  /// In en, this message translates to:
  /// **'PICK-UP'**
  String get appLPickUp;

  /// No description provided for @appLReturnLabel.
  ///
  /// In en, this message translates to:
  /// **'RETURN'**
  String get appLReturnLabel;

  /// No description provided for @appLLocationNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Location not specified'**
  String get appLLocationNotSpecified;

  /// No description provided for @appLBookingId.
  ///
  /// In en, this message translates to:
  /// **'BOOKING ID'**
  String get appLBookingId;

  /// No description provided for @appLReference.
  ///
  /// In en, this message translates to:
  /// **'REFERENCE'**
  String get appLReference;

  /// No description provided for @appLPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get appLPaymentMethod;

  /// No description provided for @appLVendor.
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get appLVendor;

  /// No description provided for @appLBranchInfo.
  ///
  /// In en, this message translates to:
  /// **'Branch Info'**
  String get appLBranchInfo;

  /// No description provided for @appLBranchName.
  ///
  /// In en, this message translates to:
  /// **'Branch Name'**
  String get appLBranchName;

  /// No description provided for @appLOpenMap.
  ///
  /// In en, this message translates to:
  /// **'Open Map'**
  String get appLOpenMap;

  /// No description provided for @appLReceipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get appLReceipt;

  /// No description provided for @appLBookingNotFound.
  ///
  /// In en, this message translates to:
  /// **'Booking not found'**
  String get appLBookingNotFound;

  /// No description provided for @appLNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get appLNo;

  /// No description provided for @appLYesCancel.
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get appLYesCancel;

  /// No description provided for @appLDeliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery Fee'**
  String get appLDeliveryFee;

  /// No description provided for @appLDailyPrice.
  ///
  /// In en, this message translates to:
  /// **'Daily Price'**
  String get appLDailyPrice;

  /// No description provided for @appLYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get appLYes;

  /// No description provided for @appLBrowseVendorCars.
  ///
  /// In en, this message translates to:
  /// **'Browse Cars'**
  String get appLBrowseVendorCars;

  /// No description provided for @appLEnterMobileForOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter your mobile number to receive a verification code via SMS'**
  String get appLEnterMobileForOtp;

  /// No description provided for @appLEnterOtpCode.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP Code'**
  String get appLEnterOtpCode;

  /// No description provided for @appLOtpSentToPhone.
  ///
  /// In en, this message translates to:
  /// **'A 6-digit code was sent to your phone via SMS'**
  String get appLOtpSentToPhone;

  /// No description provided for @appLLocationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get appLLocationPermissionTitle;

  /// No description provided for @appLLocationPermissionMessage.
  ///
  /// In en, this message translates to:
  /// **'Allow location access to show you the closest cars first'**
  String get appLLocationPermissionMessage;

  /// No description provided for @appLAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get appLAllow;

  /// No description provided for @appLOutOfDeliveryRange.
  ///
  /// In en, this message translates to:
  /// **'Out of delivery range'**
  String get appLOutOfDeliveryRange;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
