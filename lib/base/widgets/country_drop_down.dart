import 'package:flutter/material.dart';
import '../utils/basic_import.dart';

abstract class CountryDropdownModel {
  String get title;
}

class CountryDropDown<T> extends StatefulWidget {
  final RxString selectMethod;
  final List<T> itemsList;
  final void Function(T?)? onChanged;
  final bool showSearchField;
  final String subtitle;
  final Decoration? decoration;
  final Color? labelColor;
  final double? inputBoxHeight;
  final Color? dropdownIconColor;
  final Widget? leading;
  final EdgeInsets? fieldPadding;
  final String label;

  const CountryDropDown({
    required this.itemsList,
    required this.selectMethod,
    this.onChanged,
    this.inputBoxHeight,
    this.decoration,
    this.labelColor,
    this.label = '',
    this.dropdownIconColor,
    this.leading,
    this.fieldPadding,
    this.showSearchField = false, // Default is false (no search field)
    this.subtitle = '',
    super.key,
  });

  @override
  _CountryDropDownState<T> createState() => _CountryDropDownState<T>();
}

class _CountryDropDownState<T> extends State<CountryDropDown<T>>
    with SingleTickerProviderStateMixin {
  bool isDropdownOpened = false;
  final LayerLink _layerLink = LayerLink();
  TextEditingController searchController = TextEditingController();
  List<T> filteredItems = [];
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.itemsList;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _toggleDropdown() {
    if (isDropdownOpened) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var screenHeight = MediaQuery.of(context).size.height;
    var spaceBelow =
        screenHeight - renderBox.localToGlobal(Offset.zero).dy - size.height;
    var spaceAbove = renderBox.localToGlobal(Offset.zero).dy;

    double itemHeight = 48.0;
    int maxVisibleItems = 6;
    double dropdownHeight = _calculateDropdownHeight(
      itemHeight,
      maxVisibleItems,
    );

    double spaceThresholdAbove = dropdownHeight - 20.0;
    bool openUpwards =
        spaceBelow < dropdownHeight && spaceAbove > spaceThresholdAbove;

    if (openUpwards && spaceAbove < dropdownHeight) {
      dropdownHeight = spaceAbove - 10.0;
    }

    _overlayEntry = _createOverlayEntry(
      openUpwards: openUpwards,
      dropdownHeight: dropdownHeight,
    );
    Overlay.of(context).insert(_overlayEntry!);

    setState(() {
      isDropdownOpened = true;
    });
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    setState(() {
      isDropdownOpened = false;
      searchController.clear();
      filteredItems = widget.itemsList;
    });
  }

  OverlayEntry _createOverlayEntry({
    bool openUpwards = false,
    double dropdownHeight = 200.0,
  }) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeDropdown,
        child: Stack(
          children: [
            Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(
                  0.0,
                  openUpwards
                      ? -dropdownHeight - size.height * 0.08
                      : size.height,
                ),
                child: _buildDropdownList(dropdownHeight),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDropdownHeight(double itemHeight, int maxVisibleItems) {
    return filteredItems.length <= maxVisibleItems
        ? filteredItems.length * itemHeight
        : maxVisibleItems * itemHeight;
  }

  Widget _buildDropdownList(double dropdownHeight) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        elevation: 2,
        color: CustomColor.whiteColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
        child: Container(
          margin: EdgeInsets.symmetric(vertical: Dimensions.verticalSize * 0.5),
          decoration: BoxDecoration(
            color: CustomColor.whiteColor,
            borderRadius: BorderRadius.circular(Dimensions.radius),
          ),
          child: Column(
            children: [
              if (widget.showSearchField) _buildSearchField(),
              if (filteredItems.isNotEmpty)
                _buildFilteredItemsList(dropdownHeight)
              else
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('No data found', style: CustomStyle.titleMedium),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.horizontalSize * 0.5,
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            filteredItems = widget.itemsList
                .where(
                  (item) => _getItemTitle(
                    item,
                  ).toLowerCase().contains(value.toLowerCase()),
                )
                .toList();
          });
        },
        cursorColor: CustomColor.primary,
        decoration: InputDecoration(
          hintText: 'Search',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: CustomColor.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredItemsList(double dropdownHeight) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: dropdownHeight),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final value = filteredItems[index];
          return _buildDropdownItem(value);
        },
      ),
    );
  }

  Widget _buildDropdownItem(T value) {
    final itemTitle = _getItemTitle(value);

    return GestureDetector(
      onTap: () {
        widget.onChanged?.call(value);
        widget.selectMethod.value = itemTitle;
        _closeDropdown();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: widget.selectMethod.value == itemTitle
              ? CustomColor.primary.withValues(alpha: 0.6)
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13),
          child: Text(
            itemTitle,
            style: CustomStyle.titleMedium.copyWith(
              color: widget.selectMethod.value == itemTitle
                  ? Colors.white
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownButton(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: Column(
        crossAxisAlignment: crossStart,
        children: [
          TextWidget(
            padding: EdgeInsets.only(
              bottom: Dimensions.spaceBetweenInputTitleAndBox * 0.8,
            ),
            fontSize: Dimensions.titleMedium * 0.9,
            widget.label,
            style: CustomStyle.labelSmall.copyWith(fontWeight: FontWeight.w500),
            color: Color(0xfff1D1D1D),
          ),

          // if (widget.label != '')
          //   Column(
          //     children: [
          //       Sizes.height.btnInputTitleAndBox,
          //       TextWidget(
          //         widget.label,
          //         typographyStyle: TypographyStyle.labelSmall,
          //       ),
          //       Sizes.height.btnInputTitleAndBox,
          //     ],
          //   ),
          Container(
            height: widget.inputBoxHeight ?? Dimensions.inputBoxHeight * 0.8,
            decoration:
                widget.decoration ??
                BoxDecoration(
                  border: Border.all(
                    color: isDropdownOpened ? CustomColor.primary : Colors.grey,
                    width: isDropdownOpened ? 1 : 1,
                  ),
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
                        if (widget.leading != null)
                          Container(child: widget.leading),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: widget.leading == null
                                  ? Dimensions.paddingSize * 0.4
                                  : Dimensions.paddingSize * 0.4,
                            ),
                            child: Column(
                              crossAxisAlignment: crossStart,
                              mainAxisSize: mainMin,
                              children: [
                                if (widget.subtitle != '')
                                  Column(
                                    crossAxisAlignment: crossStart,
                                    children: [
                                      TextWidget(
                                        widget.subtitle,
                                        fontSize: Dimensions.labelSmall * 0.9,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      Sizes.height.v5,
                                    ],
                                  ),
                                TextWidget(
                                  widget.selectMethod.value,
                                  typographyStyle: TypographyStyle.titleMedium,
                                  style: CustomStyle.titleMedium.copyWith(
                                    fontSize: Dimensions.titleSmall,
                                    color:
                                        widget.labelColor ??
                                        (isDropdownOpened
                                            ? CustomColor.primary
                                            : null),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isDropdownOpened
                        ? Icons.arrow_drop_up
                        : Icons.arrow_drop_down,
                    color:
                        widget.dropdownIconColor ??
                        (isDropdownOpened
                            ? CustomColor.primary
                            : CustomColor.disableColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getItemTitle(T item) {
    if (item is CountryDropdownModel) {
      return item.title;
    } else if (item is String) {
      return item;
    } else {
      throw ArgumentError('Unsupported item type: ${item.runtimeType}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: _buildDropdownButton(context),
    );
  }
}
