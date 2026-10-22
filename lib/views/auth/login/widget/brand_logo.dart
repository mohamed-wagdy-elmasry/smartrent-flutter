part of '../screen/login_screen.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 4,
        ),
        child: CachedNetworkImage(
          imageUrl: BasicServices.appBasicLogoWhite.value,
          placeholder: (context, url) => const Text(''),
          errorWidget: (context, url, error) => const Text(''),
          height: MediaQuery.of(context).size.height * 0.15,
        ),
      ),
    );
  }
}
