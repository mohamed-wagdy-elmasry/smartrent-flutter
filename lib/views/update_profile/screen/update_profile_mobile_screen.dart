part of 'update_profile_screen.dart';

class UpdateProfileMobileScreen extends GetView<UpdateProfileController> {
  const UpdateProfileMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: _C.surface,
        body: controller.isLoading
            ? const ProfileLoadingSkeleton()
            : _buildBody(context),
        bottomNavigationBar: controller.isUpdateLoading
            ? Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: _S.x2, vertical: _S.x1h),
                child: Loader(),
              )
            : (controller.isLoading ? null : _buildBottomButton(context)),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(context),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _S.x2),
            child: Column(
              children: [
                const SizedBox(height: _S.x3),
                _buildPersonalInfoCard(context),
                const SizedBox(height: _S.x2),
                _buildContactCard(context),
                const SizedBox(height: _S.x2),
                _buildAddressCard(context),
                const SizedBox(height: _S.x2),
                _buildDocumentsCard(context),
                const SizedBox(height: _S.x2),
                _buildDangerZoneCard(context),
                const SizedBox(height: _S.x6),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  SLIVER APP BAR  — gradient header with avatar
  // ────────────────────────────────────────────────────────────────
  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      stretch: true,
      backgroundColor: _C.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _C.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [const DeleteButton()],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0A5EA8),
                    Color(0xFF1B8CE3),
                    Color(0xFF0D74C1),
                  ],
                ),
              ),
            ),
            // Decorative circles
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -50,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Avatar + Name
            Positioned(
              bottom: _S.x3,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  _buildAvatarWidget(context),
                  const SizedBox(height: _S.x1h),
                  Obx(() => Text(
                        controller.displayName.value.isEmpty
                            ? '—'
                            : controller.displayName.value,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _C.white,
                          letterSpacing: 0.2,
                        ),
                      )),
                  const SizedBox(height: _S.x05),
                  Obx(() => Text(
                        controller.userEmail.value,
                        style: TextStyle(
                          fontSize: 13,
                          color: _C.white.withValues(alpha: 0.75),
                          letterSpacing: 0.1,
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  AVATAR
  // ────────────────────────────────────────────────────────────────
  Widget _buildAvatarWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImagePickerSheet(context),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _C.white.withValues(alpha: 0.3), width: 3),
              boxShadow: [
                BoxShadow(
                  color: _C.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Obx(
              () => controller.imagePath.value.isNotEmpty
                  ? CircleAvatar(
                      radius: 46,
                      backgroundColor: _C.surfaceMuted,
                      backgroundImage:
                          FileImage(File(controller.imagePath.value)),
                    )
                  : AppCachedImage(
                      imageUrl: Get.find<DashboardController>()
                          .userProfileImage
                          .value,
                      width: 92,
                      height: 92,
                      fit: BoxFit.cover,
                      shape: BoxShape.circle,
                      useShimmer: true,
                      errorWidget: AppCachedImage(
                        imageUrl: Get.find<DashboardController>()
                            .userDefaultImageUrl
                            .value,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        shape: BoxShape.circle,
                        useShimmer: false,
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _C.white,
                shape: BoxShape.circle,
                boxShadow: _Shadow.card,
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 16, color: _C.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(_S.x3, _S.x2, _S.x3, _S.x4),
        decoration: const BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(_R.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(_R.full),
              ),
            ),
            const SizedBox(height: _S.x3),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary),
            ),
            const SizedBox(height: _S.x3),
            Row(
              children: [
                Expanded(
                  child: _buildPickerOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.pickImage(ImageSource.gallery);
                    },
                  ),
                ),
                const SizedBox(width: _S.x2),
                Expanded(
                  child: _buildPickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(ctx);
                      controller.pickImage(ImageSource.camera);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(_R.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: _S.x2),
        decoration: BoxDecoration(
          color: _C.primaryLight,
          borderRadius: BorderRadius.circular(_R.md),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: _C.primary),
            const SizedBox(height: _S.x1),
            Text(label,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _C.primary)),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  SECTION CARDS
  // ────────────────────────────────────────────────────────────────
  Widget _sectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surfaceCard,
        borderRadius: BorderRadius.circular(_R.md),
        boxShadow: _Shadow.subtle,
        border: Border.all(color: _C.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(_S.x2, _S.x2, _S.x2, _S.x1),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: _C.primaryLight,
                    borderRadius: BorderRadius.circular(_R.xs),
                  ),
                  child: Icon(icon, size: 16, color: _C.primary),
                ),
                const SizedBox(width: _S.x1h),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: _C.borderLight, height: 1),
          // Fields
          Padding(
            padding: const EdgeInsets.all(_S.x2),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  PERSONAL INFO
  // ────────────────────────────────────────────────────────────────
  Widget _buildPersonalInfoCard(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: _sectionCard(
        title: DynamicLanguage.key(Strings.personalInformation),
        icon: Icons.person_outline_rounded,
        children: [
          Row(
            children: [
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.firstNameController,
                  label: Strings.firstName,
                  hintText: Strings.firstName,
                  textInputType: TextInputType.name,
                  showBorderSide: true,
                ),
              ),
              const SizedBox(width: _S.x1h),
              Expanded(
                child: PrimaryInputWidget(
                  controller: controller.lastNameController,
                  label: Strings.lastName,
                  hintText: Strings.lastName,
                  textInputType: TextInputType.name,
                  showBorderSide: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  CONTACT
  // ────────────────────────────────────────────────────────────────
  Widget _buildContactCard(BuildContext context) {
    return _sectionCard(
      title: DynamicLanguage.key(Strings.contactInformation),
      icon: Icons.phone_outlined,
      children: [
        CountryDropDown(
          label: Strings.Country,
          itemsList: controller.countryList,
          selectMethod: controller.countrySelectMethod,
          onChanged: (v) {
            controller.countrySelectMethod.value = v!.name;
            controller.mobileCode.value = v.mobileCode;
            LocalStorage.save(userCountryCode: v.mobileCode);
          },
        ),
        const SizedBox(height: _S.x2),
        PrimaryInputWidget(
          controller: controller.mobileController,
          label: Strings.Phone,
          hintText: Strings.Phone,
          textInputType: TextInputType.phone,
          showBorderSide: true,
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  ADDRESS
  // ────────────────────────────────────────────────────────────────
  Widget _buildAddressCard(BuildContext context) {
    return _sectionCard(
      title: DynamicLanguage.key(Strings.addressInformation),
      icon: Icons.location_on_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryInputWidget(
                controller: controller.addressController,
                label: Strings.Address,
                hintText: Strings.Address,
                textInputType: TextInputType.streetAddress,
                showBorderSide: true,
              ),
            ),
            const SizedBox(width: _S.x1h),
            Expanded(
              child: PrimaryInputWidget(
                controller: controller.cityController,
                label: Strings.City,
                hintText: Strings.City,
                textInputType: TextInputType.text,
                showBorderSide: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: _S.x2),
        Row(
          children: [
            Expanded(
              child: PrimaryInputWidget(
                controller: controller.stateController,
                label: Strings.State,
                hintText: Strings.State,
                textInputType: TextInputType.text,
                showBorderSide: true,
              ),
            ),
            const SizedBox(width: _S.x1h),
            Expanded(
              child: PrimaryInputWidget(
                controller: controller.zipCodeController,
                label: Strings.ZipCode,
                hintText: Strings.ZipCode,
                textInputType: TextInputType.number,
                showBorderSide: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  DOCUMENTS
  // ────────────────────────────────────────────────────────────────
  Widget _buildDocumentsCard(BuildContext context) {
    return _sectionCard(
      title: DynamicLanguage.key(Strings.documentUploads),
      icon: Icons.description_outlined,
      children: [
        Obx(() => _buildDocumentTile(
              context: context,
              title: DynamicLanguage.key(Strings.nationalId),
              icon: Icons.badge_outlined,
              imageUrl: controller.nationalIdImageUrl.value,
              imagePath: controller.nationalIdPath.value,
              onPickCamera: () =>
                  controller.pickNationalIdImage(ImageSource.camera),
              onPickGallery: () =>
                  controller.pickNationalIdImage(ImageSource.gallery),
              onRemove: controller.removeNationalId,
            )),
        const SizedBox(height: _S.x1h),
        Obx(() => _buildDocumentTile(
              context: context,
              title: DynamicLanguage.key(Strings.drivingLicense),
              icon: Icons.drive_eta_outlined,
              imageUrl: controller.drivingLicenseImageUrl.value,
              imagePath: controller.drivingLicensePath.value,
              onPickCamera: () =>
                  controller.pickDrivingLicenseImage(ImageSource.camera),
              onPickGallery: () =>
                  controller.pickDrivingLicenseImage(ImageSource.gallery),
              onRemove: controller.removeDrivingLicense,
            )),
      ],
    );
  }

  Widget _buildDocumentTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String imageUrl,
    required String imagePath,
    required VoidCallback onPickCamera,
    required VoidCallback onPickGallery,
    required VoidCallback onRemove,
  }) {
    final hasImage =
        imagePath.isNotEmpty || imageUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(_S.x1h),
      decoration: BoxDecoration(
        color: hasImage ? _C.successLight : _C.surfaceMuted,
        borderRadius: BorderRadius.circular(_R.sm),
        border: Border.all(
          color: hasImage
              ? _C.success.withValues(alpha: 0.2)
              : _C.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 20,
                  color: hasImage ? _C.success : _C.textSecondary),
              const SizedBox(width: _S.x1),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: hasImage ? _C.success : _C.textPrimary,
                  ),
                ),
              ),
              if (hasImage)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _C.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(_R.full),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 12, color: _C.success),
                      SizedBox(width: 4),
                      Text('Uploaded',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: _C.success)),
                    ],
                  ),
                ),
            ],
          ),
          if (hasImage) ...[
            const SizedBox(height: _S.x1h),
            ClipRRect(
              borderRadius: BorderRadius.circular(_R.xs),
              child: SizedBox(
                height: 160,
                width: double.infinity,
                child: imagePath.isNotEmpty
                    ? Image.file(File(imagePath), fit: BoxFit.cover)
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.broken_image_rounded,
                              size: 40, color: _C.textTertiary),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: _S.x1h),
            Row(
              children: [
                Expanded(
                  child: _docActionButton(
                    label: 'Change',
                    icon: Icons.edit_rounded,
                    color: _C.primary,
                    onTap: () => _showDocPickerSheet(
                        context, onPickCamera, onPickGallery),
                  ),
                ),
                const SizedBox(width: _S.x1),
                Expanded(
                  child: _docActionButton(
                    label: 'Remove',
                    icon: Icons.delete_outline_rounded,
                    color: _C.error,
                    onTap: onRemove,
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: _S.x1h),
            Row(
              children: [
                Expanded(
                  child: _docActionButton(
                    label: 'Camera',
                    icon: Icons.camera_alt_rounded,
                    color: _C.primary,
                    onTap: onPickCamera,
                  ),
                ),
                const SizedBox(width: _S.x1),
                Expanded(
                  child: _docActionButton(
                    label: 'Gallery',
                    icon: Icons.photo_library_rounded,
                    color: _C.primary,
                    onTap: onPickGallery,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _docActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(_R.xs),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: _S.x1, horizontal: _S.x1),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(_R.xs),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: _S.x05),
              Text(label,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocPickerSheet(
      BuildContext context, VoidCallback onCamera, VoidCallback onGallery) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(_S.x3, _S.x2, _S.x3, _S.x4),
        decoration: const BoxDecoration(
          color: _C.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(_R.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _C.border,
                borderRadius: BorderRadius.circular(_R.full),
              ),
            ),
            const SizedBox(height: _S.x3),
            Row(
              children: [
                Expanded(
                  child: _buildPickerOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(ctx);
                      onCamera();
                    },
                  ),
                ),
                const SizedBox(width: _S.x2),
                Expanded(
                  child: _buildPickerOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(ctx);
                      onGallery();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  BOTTOM BUTTON
  // ────────────────────────────────────────────────────────────────
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(_S.x2, _S.x1h, _S.x2, _S.x2),
      decoration: BoxDecoration(
        color: _C.white,
        boxShadow: [
          BoxShadow(
            color: _C.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(
          () => PrimaryButton(
            title: Strings.update,
            disable: false,
            isLoading: controller.isUpdateLoading,
            onPressed: () {
              controller.updateProfile();
            },
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────
  //  DANGER ZONE / DELETE ACCOUNT (Guideline 5.1.1)
  // ────────────────────────────────────────────────────────────────
  Widget _buildDangerZoneCard(BuildContext context) {
    final isEn = DynamicLanguage.selectedLanguage.value.startsWith('en');
    return Container(
      decoration: BoxDecoration(
        color: _C.surfaceCard,
        borderRadius: BorderRadius.circular(_R.md),
        boxShadow: _Shadow.subtle,
        border: Border.all(color: _C.error.withValues(alpha: 0.25), width: 1),
      ),
      padding: const EdgeInsets.all(_S.x2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: _C.errorLight,
                  borderRadius: BorderRadius.circular(_R.xs),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    size: 16, color: _C.error),
              ),
              const SizedBox(width: _S.x1h),
              Text(
                isEn ? 'Account Management' : 'إدارة الحساب',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _C.textPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: _S.x1h),
          Text(
            isEn
                ? 'Permanently delete your SmartRent account and all associated personal data.'
                : 'حذف حسابك في سمارت رنت نهائياً وجميع البيانات الشخصية المرتبطة به.',
            style: const TextStyle(
              fontSize: 13,
              color: _C.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: _S.x2),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: _C.error,
                side: const BorderSide(color: _C.error),
                padding: const EdgeInsets.symmetric(vertical: _S.x1h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_R.xs),
                ),
              ),
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: Text(
                isEn ? 'Delete Account' : 'حذف الحساب',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(_R.lg)),
                  ),
                  builder: (BuildContext ctx) {
                    return const DeletePop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
