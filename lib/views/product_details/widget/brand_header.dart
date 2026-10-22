part of '../screen/product_details_screen.dart';

class BrandHeader extends GetView<ProductDetailsController> {
  const BrandHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: crossStart,
            children: [
              TextWidget(
                'Tesla',
                color: CustomColor.blackColor.withValues(alpha: 0.5),
              ),
              TextWidget(
                'Model S',
                typographyStyle: TypographyStyle.titleLarge,
                fontWeight: FontWeight.w500,
              ),
            ],
          ),
          ClipRRect(
            child: Image.network(
              'https://nova-hata.com/image/cache/catalog/Ithem/NH_0615/bmw-logo-machine-embroidery-design-615-750x750.jpg',
              height: MediaQuery.of(context).size.height * 0.06,
            ),
          ),
        ],
      ),
    );
  }
}
