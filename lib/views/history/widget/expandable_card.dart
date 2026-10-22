part of '../screen/history_screen.dart';

class ExpandableCard extends GetView<HistoryController> {
  const ExpandableCard({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return Obx(
          () => Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: Dimensions.radius * 2,
                    backgroundImage: const NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSWtyoKr8-EgU3I8xH4GlEJiPOqPszxHJLWcw&s',
                    ),
                    backgroundColor: CustomColor.whiteColor,
                  ),
                  title: TextWidget(
                    'Jeep -44',
                    typographyStyle: TypographyStyle.titleMedium,
                  ),
                  subtitle: Row(
                    spacing: 5,
                    children: [
                      CircleAvatar(
                        radius: Dimensions.radius * 0.3,
                        backgroundColor: CustomColor.rejected,
                        child: Container(alignment: Alignment.center),
                      ),
                      TextWidget(
                        'Pending',
                        typographyStyle: TypographyStyle.labelMedium,
                      ),
                    ],
                  ),
                  trailing: TextWidget(
                    DateFormat('d MMM yyyy').format(DateTime.now()),
                    typographyStyle: TypographyStyle.bodySmall,
                    color: CustomColor.primary,
                    fontWeight: FontWeight.w700,
                  ),
                  onTap: () => controller.toggleCardExpansion(index),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: controller.isExpanded[index].value ? h * 0.4 : 0,
                  child: ExpandedCardInfo(index),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
