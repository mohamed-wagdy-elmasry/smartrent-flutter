import 'package:carbo/base/utils/basic_import.dart';
import '../localization/dynamic_language_shim.dart';
import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  final RxString selectedTime; // Observable time string
  final String label;
  final String subtitle;
  final Decoration? decoration;
  final Color? labelColor;
  final double? inputBoxHeight;
  final Color? clockIconColor;
  final Widget? leading;
  final EdgeInsets? fieldPadding;
  final double? labelFontSize;
  final double? hintFontSize;
  final Widget? labelSpacing;
  final bool showBorder;

  const CustomTimePicker({
    required this.selectedTime,
    this.label = '',
    this.subtitle = '',
    this.decoration,
    this.labelColor,
    this.inputBoxHeight,
    this.clockIconColor,
    this.leading,
    this.fieldPadding,
    Key? key,
    this.labelFontSize,
    this.hintFontSize,
    this.labelSpacing,
    required this.showBorder,
  }) : super(key: key);

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker>
    with SingleTickerProviderStateMixin {
  bool isTimePickerOpened = false;

  Future<void> _selectTime() async {
    // Get current time as initial time to prevent past bookings
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: CustomColor.whiteColor,
            colorScheme: ColorScheme.light(
              primary: CustomColor.primary,
              onPrimary: Colors.white,
              surface: CustomColor.whiteColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: CustomColor.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        widget.selectedTime.value = _formatTime(pickedTime);
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour; // 24-hour format
    return "${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  Widget _buildTimePickerButton(BuildContext context) {
    return GestureDetector(
      onTap: _selectTime,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label.isNotEmpty)
            Column(
              children: [
                TextWidget(
                  widget.label,
                  fontSize: widget.labelFontSize ?? Dimensions.titleSmall * 0.9,
                  style: CustomStyle.titleSmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  color: const Color(0xff1D1D1D),
                ),
                widget.labelSpacing ?? Sizes.height.btnInputTitleAndBox,
              ],
            ),
          Container(
            height: widget.inputBoxHeight ?? Dimensions.inputBoxHeight * 0.75,
            decoration:
                widget.decoration ??
                BoxDecoration(
                  color: CustomColor.background,
                  border: widget.showBorder == true
                      ? Border.all(
                          color: isTimePickerOpened
                              ? CustomColor.primary
                              : Colors.grey,
                          width: isTimePickerOpened ? 2 : 1,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(Dimensions.radius * 0.5),
                ),
            child: Padding(
              padding:
                  widget.fieldPadding ??
                  const EdgeInsets.only(left: 5, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        if (widget.leading != null) widget.leading!,
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: widget.leading == null
                                  ? Dimensions.paddingSize * 0.4
                                  : Dimensions.paddingSize * 0.4,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWidget(
                                  widget.selectedTime.value.isEmpty
                                      ? DynamicLanguage.key(Strings.SelectATime)
                                      : widget.selectedTime.value,
                                  fontSize:
                                      widget.hintFontSize ??
                                      Dimensions.titleSmall,
                                  style: CustomStyle.titleSmall.copyWith(
                                    color:
                                        widget.labelColor ??
                                        (isTimePickerOpened
                                            ? CustomColor.primary
                                            : null),
                                  ),
                                ),
                                if (widget.subtitle != '')
                                  TextWidget(
                                    widget.subtitle,
                                    fontSize: Dimensions.labelSmall * 0.9,
                                    fontWeight: FontWeight.w400,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.access_time,
                    color:
                        widget.clockIconColor ??
                        (isTimePickerOpened
                            ? CustomColor.primary
                            : CustomColor.disableColor),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTimePickerButton(context);
  }
}
