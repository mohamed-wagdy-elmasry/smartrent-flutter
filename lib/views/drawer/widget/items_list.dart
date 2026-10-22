part of '../screen/drawer_screen.dart';

class OthersWidgets extends StatelessWidget {
  const OthersWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = LocalStorage.isLoggedIn;
    return Column(
      children: [
        Sizes.height.v20,
        if (isLoggedIn)
          _itemCard(
            Icons.lock_open_outlined,
            Strings.changePassword,
            () => Get.toNamed(Routes.change_passwordScreen),
          ),
        if (isLoggedIn)
          _itemCard(
            Icons.notifications_none,
            Strings.notification,
            () => Get.toNamed(Routes.notificationScreen),
          ),
        if (isLoggedIn)
          _itemCard(
            Icons.history,
            Strings.history,
            () => Get.toNamed(Routes.historyScreen),
          ),
        if (isLoggedIn)
          _itemCard(
            Icons.account_balance_wallet_outlined,
            Strings.myWallet,
            () => Get.toNamed(Routes.walletScreen),
          ),
        _itemCard(
          Icons.language,
          Strings.language,
          () => Get.toNamed(Routes.settingScreen),
        ),
        _itemCard(
          Icons.headphones,

          DynamicLanguage.isLoading
              ? ""
              : DynamicLanguage.key(Strings.contactUs),
          () => _openContact(),
        ),
        _itemCard(
          Icons.privacy_tip_outlined,
          DynamicLanguage.isLoading
              ? ""
              : DynamicLanguage.key(Strings.privacyPolicy),
          () => _openPrivacyPolicy(),
        ),
        _itemCard(
          Icons.info_outline,
          Strings.aboutUs,
          () => _openAbout(),
        ),
        if (isLoggedIn)
          _itemCard(
            Icons.delete_forever_outlined,
            DynamicLanguage.selectedLanguage.value.startsWith('en')
                ? 'Delete Account'
                : 'حذف الحساب',
            () {
              Get.back();
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (BuildContext context) {
                  return const DeletePop();
                },
              );
            },
            Colors.red,
          ),
        if (isLoggedIn)
          _itemCard(
            Icons.logout,
            Strings.logOut,
            () {
              Get.back();
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(Dimensions.radius * 1.5),
                  ),
                ),
                builder: (BuildContext context) {
                  return LogoutDialog();
                },
              );
            },
            Colors.red,
          ),
        if (!isLoggedIn)
          _itemCard(
            Icons.login,
            Strings.login,
            () => Get.offAllNamed(Routes.otpLoginScreen),
          ),
      ],
    );
  }

  void _openPrivacyPolicy() {
    final lang = DynamicLanguage.selectedLanguage.value;
    final asset = (lang.startsWith('en'))
        ? 'assets/html/privacy-policy-en.html'
        : 'assets/html/privacy-policy-ar.html';
    Get.to(() => HtmlScreen(title: Strings.privacyPolicy, asset: asset));
  }

  void _openAbout() {
    final lang = DynamicLanguage.selectedLanguage.value;
    final asset = (lang.startsWith('en'))
        ? 'assets/html/about_smartrent_en.html'
        : 'assets/html/about_smartrent_ar.html';
    Get.to(() => HtmlScreen(title: Strings.aboutUs, asset: asset));
  }

  void _openContact() {
    final lang = DynamicLanguage.selectedLanguage.value;
    final asset = (lang.startsWith('en'))
        ? 'assets/html/contact-us-en.html'
        : 'assets/html/contact-us-ar.html';
    Get.to(() => HtmlScreen(title: Strings.contactUs, asset: asset));
  }

  _itemCard(IconData icon, String title, VoidCallback onTap, [Color? color]) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 0.5,
        ),
        leading: Icon(icon, color: color ?? CustomColor.primary),
        title: TextWidget(title),
      ),
    );
  }
}
