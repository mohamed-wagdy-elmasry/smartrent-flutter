part of '../screen/dashboard_screen.dart';

class SearchBar extends GetView<DashboardController> {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        bottom: Dimensions.verticalSize * 0.5,
        top: Dimensions.verticalSize * 0.5,
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSize * 0.45),
      child: Wrap(
        spacing: Dimensions.horizontalSize * 0.4,
        children: [
          Icon(Icons.tune),
          TextWidget("Sort & Filter", fontWeight: FontWeight.bold),
        ],
      ),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: CustomColor.whiteColor,

        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
    );
  }
}
