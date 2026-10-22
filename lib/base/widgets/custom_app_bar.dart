import 'package:carbo/base/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../themes/token.dart';
import '../utils/dimensions.dart';
import 'back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar(
    this.title, {
    super.key,
    this.backgroundColor,
    this.elevation = 0,
    this.autoLeading = false,
    this.showBackButton = true,
    this.centerTitle = false,
    this.isWhite = false,
    this.action,
    this.leading,
    this.bottom,
    this.toolbarHeight,
    this.appbarSize,
    this.leadingWidth,
  });

  final String title;
  final Color? backgroundColor;
  final double elevation;
  final List<Widget>? action;
  final Widget? leading;
  final bool autoLeading;
  final bool showBackButton;
  final bool centerTitle;
  final bool isWhite;
  final PreferredSizeWidget? bottom;
  final double? toolbarHeight;
  final double? appbarSize;
  final double? leadingWidth;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: centerTitle,
      title: TextWidget(
        fontWeight: FontWeight.w500,
        title,
        color: isWhite ? Colors.white : null,
      ),
      actions: action,
      leading: showBackButton
          ? leading ??
                BackButtonWidget(
                  onTap: () {
                    Get.close(1);
                  },
                  isWhite: isWhite,
                )
          : null,
      bottom: bottom,
      elevation: elevation,
      toolbarHeight: toolbarHeight,
      leadingWidth: leadingWidth,
      scrolledUnderElevation: 0,
      backgroundColor:
          backgroundColor ?? CustomColor.disableColor.withValues(alpha: 0.25),
      automaticallyImplyLeading: autoLeading,
      systemOverlayStyle: SystemUiOverlayStyle(
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(appbarSize ?? Dimensions.appBarHeight);
}
