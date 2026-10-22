import 'package:flutter/material.dart';
import '../../../base/localization/dynamic_language_shim.dart';
import 'delete_pop.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEn = DynamicLanguage.selectedLanguage.value.startsWith('en');
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton(
        tooltip: isEn ? 'Delete Account' : 'حذف الحساب',
        style: IconButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 20),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (BuildContext ctx) {
              return const DeletePop();
            },
          );
        },
      ),
    );
  }
}
