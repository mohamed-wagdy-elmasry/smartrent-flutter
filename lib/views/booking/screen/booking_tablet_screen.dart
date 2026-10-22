part of 'booking_screen.dart';

class BookingTabletScreen extends GetView<BookingController> {
  const BookingTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar('Booking Tablet Screen'),
      body: _bodyWidget(context),
    );
  }

  _bodyWidget(BuildContext context) {
    return const SafeArea(child: Column(children: []));
  }
}
