import 'package:carbo/base/utils/basic_import.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';

import '../../assets/assets.dart';

class EmptyDataWidget extends StatelessWidget {
  final String? massage;

  const EmptyDataWidget({super.key, this.massage});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.defaultHorizontalSize * 4,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(Assets.icons.empty),
            Sizes.height.v5,
            TextWidget(
              maxLines: 2,
              textOverflow: TextOverflow.ellipsis,
              massage ?? Strings.noDataFound,
              typographyStyle: TypographyStyle.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
