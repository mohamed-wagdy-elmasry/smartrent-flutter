import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import '../../../base/widgets/primary_button.dart';
import '../../auth/login/controller/login_controller.dart';

class DeletePop extends StatelessWidget {
  const DeletePop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loginController = Get.isRegistered<LoginController>()
        ? Get.find<LoginController>()
        : Get.put(LoginController());

    final isEn = DynamicLanguage.selectedLanguage.value.startsWith('en');

    final title = isEn ? 'Delete Account' : 'حذف الحساب نهائياً';
    final description = isEn
        ? 'Are you sure you want to permanently delete your account?\n\nThis action is permanent and cannot be undone. All your personal data, rental history, and account records will be permanently erased from our servers in compliance with privacy regulations.'
        : 'هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟\n\nهذا الإجراء دائم ولا يمكن التراجع عنه. سيتم حذف جميع بياناتك الشخصية وسجل الحجوزات وجميع السجلات المرتبطة بحسابك بشكل نهائي من خوادمنا وفقاً لسياسات الخصوصية.';
    final cancelText = isEn ? 'Cancel' : 'إلغاء';
    final confirmText = isEn ? 'Permanently Delete Account' : 'تأكيد حذف الحساب نهائياً';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_forever_rounded,
                size: 36,
                color: Color(0xFFDC2626),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Cancel button
            PrimaryButton(
              title: cancelText,
              onPressed: () {
                Navigator.pop(context);
              },
              buttonColor: const Color(0xFFF1F3F5),
              borderColor: const Color(0xFFF1F3F5),
              buttonTextColor: const Color(0xFF0F172A),
            ),
            const SizedBox(height: 12),
            // Delete button with loading
            Obx(
              () => PrimaryButton(
                title: confirmText,
                isLoading: loginController.isLoading,
                onPressed: () async {
                  final success = await loginController.deleteAccountProcess();
                  if (!success && context.mounted) {
                    // Dialog stays open if deletion encountered an error so user sees message
                  }
                },
                buttonColor: const Color(0xFFDC2626),
                borderColor: const Color(0xFFDC2626),
                buttonTextColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
