part of 'product_details_screen.dart';

class ProductDetailsTabletScreen extends GetView<ProductDetailsController> {
  const ProductDetailsTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('ProductDetails Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
