part of 'preview_screen.dart';

class PreviewTabletScreen extends GetView<PreviewController> {
  const PreviewTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar('Preview Tablet Screen'),
        body: _bodyWidget(context),
      ),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
