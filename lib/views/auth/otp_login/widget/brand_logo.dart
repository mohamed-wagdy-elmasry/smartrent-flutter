part of '../screen/otp_login_screen.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: CachedNetworkImage(
        imageUrl: BasicServices.appBasicLogoWhite.value,
        placeholder: (context, url) => Image.asset(
          'assets/logo/logo.png',
          fit: BoxFit.contain,
        ),
        errorWidget: (context, url, error) => Image.asset(
          'assets/logo/logo.png',
          fit: BoxFit.contain,
        ),
        fit: BoxFit.contain,
      ),
    ));
  }
}
