part of 'product_details_screen.dart';

class ProductDetailsMobileScreen extends GetView<ProductDetailsController> {
  const ProductDetailsMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      appBar: CustomAppBar(
        '',
        backgroundColor: Colors.transparent,
        action: [
          IconButton(onPressed: () {}, icon: Icon(Icons.bookmarks_outlined)),
        ],
      ),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return SafeArea(
      child: ListView(
        children: [
          Imageview(),
          BrandHeader(),
          BookNow(),
          CarInfo(),
          Range(),
          DetailReview(),
        ],
      ),
    );
  }
}
