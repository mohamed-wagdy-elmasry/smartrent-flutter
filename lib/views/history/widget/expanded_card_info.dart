part of '../screen/history_screen.dart';

class ExpandedCardInfo extends GetView<HistoryController> {
  final int index;

  const ExpandedCardInfo(this.index, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [_moreInfoShow(index)]),
    );
  }

  _moreInfoShow(int index) {
    final info = controller.historyList[index];
    return Container(
      // decoration: BoxDecoration(
      //   color: CustomColor.whiteColor,
      //   borderRadius: BorderRadius.circular(Dimensions.radius * 0.8),
      // ),
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      child: Column(
        children: [
          _previewHistoryCard(Strings.PickUpLocation, info.location),
          _previewHistoryCard(Strings.destination, info.destination),
          _previewHistoryCard(
            Strings.PickUpdate,
            info.pickupDate.toString().substring(0, 11),
          ),
          _previewHistoryCard(Strings.PickUpTime, info.pickupTime),
          _previewHistoryCard(
            Strings.totalAmount,
            "${info.amount} ${BasicServices.baseCurCode}",
          ),
          if (info.message.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dimensions.verticalSize * 0.25,
              ),
              child: Row(
                mainAxisAlignment: mainSpaceBet,
                crossAxisAlignment: crossStart,
                children: [
                  TextWidget(Strings.note, fontSize: Dimensions.titleSmall),
                  Sizes.width.v10,
                  Flexible(
                    child: TextWidget(
                      info.message,
                      fontWeight: FontWeight.w500,
                      color: CustomColor.primary,
                      fontSize: Dimensions.titleSmall,
                      maxLines: 3,
                      textOverflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          _previewHistoryCard(
            Strings.status,
            info.bookingStatus == BookingStatus.pending
                ? Strings.pending
                : info.bookingStatus == BookingStatus.approved
                ? Strings.approved
                : info.bookingStatus == BookingStatus.ongoing
                ? Strings.ongoing
                : info.bookingStatus == BookingStatus.completed
                ? Strings.complete
                : info.bookingStatus == BookingStatus.cancelled
                ? Strings.reject
                : Strings.draft,
          ),
        ],
      ),
    );
  }

  _previewHistoryCard(String title, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.25),
      child: Row(
        mainAxisAlignment: mainSpaceBet,
        children: [
          TextWidget(title, fontSize: Dimensions.titleSmall),
          TextWidget(
            value ?? '-',
            fontWeight: FontWeight.w500,
            color: CustomColor.primary,
            fontSize: Dimensions.titleSmall,
          ),
        ],
      ),
    );
  }
}
