import 'package:flutter/material.dart';

import '../../../../base/utils/basic_import.dart';

class CardTypeWidget extends StatelessWidget {
  CardTypeWidget({
    super.key,
    this.onTap,
    this.title,
    this.description,
    this.icon,
    this.isDeleteAccount = false,
    this.isMenu = false,
    this.child,
  });

  final VoidCallback? onTap;
  final Widget? child;
  final String? title, description;
  final IconData? icon;
  final bool isDeleteAccount;
  final bool isMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: isMenu ? 0 : Dimensions.verticalSize * 0.3),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap ?? () {},
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radius),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.horizontalSize * 0.55,
              vertical: isMenu ? 0 : Dimensions.verticalSize * 0.5,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(
                    Dimensions.paddingSize * (isMenu ? 0.5 : 0.4),
                  ),
                  decoration: BoxDecoration(
                    color: isDeleteAccount
                        ? Color(0xffFFEBE9)
                        : CustomColor.background,
                    borderRadius: BorderRadius.circular(
                      Dimensions.radius * 1.2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDeleteAccount ? Color(0xffFF4231) : null,
                  ),
                ),
                Sizes.width.v10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: crossStart,
                    mainAxisSize: mainMin,
                    mainAxisAlignment: mainCenter,
                    children: [
                      TextWidget(
                        title ?? '',
                        typographyStyle: TypographyStyle.titleMedium,
                        style: CustomStyle.titleMedium.copyWith(),
                      ),
                      if (description != '')
                        TextWidget(
                          description ?? '',
                          fontSize: Dimensions.labelSmall * 0.9,
                          fontWeight: FontWeight.w400,
                        ),
                    ],
                  ),
                ),
                if (child != null) ...[Container(child: child)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
