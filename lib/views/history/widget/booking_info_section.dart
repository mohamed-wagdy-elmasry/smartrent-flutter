part of '../screen/history_screen.dart';

class BookingInfoSection extends StatelessWidget {
  final String title;
  final List<BookingInfoItem> items;

  const BookingInfoSection({
    required this.title,
    required this.items,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          title,
          typographyStyle: TypographyStyle.titleMedium,
          fontWeight: FontWeight.w700,
        ),
        Sizes.height.v10,
        ...items.map((item) => _buildInfoRow(item)),
      ],
    );
  }

  Widget _buildInfoRow(BookingInfoItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.verticalSize * 0.8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: 18,
              color: CustomColor.typography.withOpacity(0.6),
            ),
            Sizes.width.v10,
          ],
          Expanded(
            flex: 2,
            child: TextWidget(
              item.label,
              typographyStyle: TypographyStyle.bodySmall,
              color: CustomColor.typography.withOpacity(0.6),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextWidget(
              item.value,
              typographyStyle: TypographyStyle.bodySmall,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class BookingInfoItem {
  final String label;
  final String value;
  final IconData? icon;

  BookingInfoItem({
    required this.label,
    required this.value,
    this.icon,
  });
}
