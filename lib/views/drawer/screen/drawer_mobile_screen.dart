part of 'drawer_screen.dart';

class DrawerMobileScreen extends StatelessWidget {
  const DrawerMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.defaultHorizontalSize,
          ),
          children: [ProfileHeaderWidget(), OthersWidgets()],
        ),
      ),
    );
  }
}
