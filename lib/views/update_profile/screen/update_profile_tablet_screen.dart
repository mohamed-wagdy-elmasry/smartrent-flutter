part of 'update_profile_screen.dart';

class UpdateProfileTabletScreen extends GetView<UpdateProfileController> {
  const UpdateProfileTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the mobile screen — it adapts well via padding & flexible layout
    return const UpdateProfileMobileScreen();
  }
}
