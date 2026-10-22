part of '../screen/vendor_cars_screen.dart';

/// Simple drawer for guest users browsing vendor cars
class VendorCarsGuestDrawer extends StatelessWidget {
  const VendorCarsGuestDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.defaultHorizontalSize,
          ),
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dimensions.verticalSize * 0.5,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logo/logo.png', width: 150, height: 150),
                  Container(
                    
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'Smart Rent',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: CustomColor.typography,
                      ),
                    ),
                  ),
                 
                ],
              ),
            ),
            const Divider(),
            SizedBox(height: Dimensions.verticalSize * 0.5),

            // Login Button
            ElevatedButton.icon(
              onPressed: () {
                Get.back();
                Get.toNamed(Routes.otpLoginScreen);
              },
              icon: const Icon(Icons.login_rounded),
              label: Text(DynamicLanguage.key(Strings.login)),
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomColor.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.verticalSize * 0.6,
                ),
              ),
            ),
            SizedBox(height: Dimensions.verticalSize * 0.8),

            // Menu items
            _menuItem(
              Icons.language_rounded,
              DynamicLanguage.key(Strings.language),
              () {
                Get.back();
                Get.toNamed(Routes.settingScreen);
              },
            ),
            _menuItem(
              Icons.privacy_tip_outlined,
              DynamicLanguage.key(Strings.privacyPolicy),
              () {
                Get.back();
                _openPrivacyPolicy();
              },
            ),
            _menuItem(
              Icons.info_outline,
              DynamicLanguage.key(Strings.aboutUs),
              () {
                Get.back();
                _openAbout();
              },
            ),
            _menuItem(
              Icons.headphones,
              DynamicLanguage.key(Strings.contactUs),
              () {
                Get.back();
                _openContact();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.verticalSize * 0.5,
          horizontal: Dimensions.horizontalSize * 0.4,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: CustomColor.primary),
            SizedBox(width: Dimensions.horizontalSize * 0.8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: CustomColor.typography,
              ),
            ),
          ],
        ),
      ),
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
}
