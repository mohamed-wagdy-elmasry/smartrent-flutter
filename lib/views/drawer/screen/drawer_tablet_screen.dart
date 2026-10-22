part of 'drawer_screen.dart';

class DrawerTabletScreen extends StatelessWidget {
  const DrawerTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('Drawer Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
