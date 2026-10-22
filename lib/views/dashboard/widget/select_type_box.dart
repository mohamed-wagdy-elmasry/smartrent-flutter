part of '../screen/dashboard_screen.dart';

class SelectTypeBox extends GetView<DashboardController> {
  const SelectTypeBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: Dimensions.verticalSize * 0.5,
      ),
      decoration: BoxDecoration(
        color: CustomColor.whiteColor,
        borderRadius: BorderRadius.circular(Dimensions.radius),
      ),
      padding: EdgeInsets.only(
        bottom: Dimensions.verticalSize * 0.5,
        left: Dimensions.defaultHorizontalSize,
        right: Dimensions.defaultHorizontalSize,
      ),
      child: Column(
        children: [
          // REMOVED AREA SELECTION - Now fetching all types directly
          Obx(
            () => CustomDropDown<TypesAll>(
              labelSpacing: Sizes.height.v5,
              label: Strings.SelectType,
              labelFontSize: Dimensions.titleSmall * 0.8,
              hintFontSize: Dimensions.titleSmall * 0.8,
              inputBoxHeight: Dimensions.inputBoxHeight * 0.695,
              fieldPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.horizontalSize * 0.7,
                vertical: Dimensions.verticalSize * 0.37,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
                color: CustomColor.background,
              ),
              itemsList: controller.typeList,
              selectMethod: controller.isLoad
                  ? RxString(Strings.pleaseWait)
                  : controller.alis,
              onChanged: (v) {
                controller.selectType.value = v!;
                // clear previous models and selection
                controller.modelList.clear();
                controller.selectModel.value = null;
                controller.carTypeId.value = v.carTypeId;
                controller.alis.value = v.name;
                // fetch models for selected type
                controller.typeHasModel();
              },
            ),
          ),
          Obx(
            () => CustomDropDown<ModelsAll>(
              labelSpacing: Sizes.height.v5,
              label: Strings.SelectModel,
              labelFontSize: Dimensions.titleSmall * 0.8,
              hintFontSize: Dimensions.titleSmall * 0.8,
              inputBoxHeight: Dimensions.inputBoxHeight * 0.695,
              fieldPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.horizontalSize * 0.7,
                vertical: Dimensions.verticalSize * 0.37,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
                color: CustomColor.background,
              ),
              itemsList: controller.modelList,
              selectMethod: controller.isLoad
                  ? RxString(Strings.pleaseWait)
                  : controller.selectedModelName,
              onChanged: (v) {
                controller.selectModel.value = v!;
                controller.carModelId.value = v.id;
                controller.selectedModelName.value = v.name;
                // fetch years for selected model
                controller.modelHasYears();
              },
            ),
          ),

          Obx(
            () => CustomDropDown<String>(
              labelSpacing: Sizes.height.v5,
              label: Strings.SelectYear,
              labelFontSize: Dimensions.titleSmall * 0.8,
              hintFontSize: Dimensions.titleSmall * 0.8,
              inputBoxHeight: Dimensions.inputBoxHeight * 0.695,
              fieldPadding: EdgeInsets.symmetric(
                horizontal: Dimensions.horizontalSize * 0.7,
                vertical: Dimensions.verticalSize * 0.37,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius * 1.2),
                color: CustomColor.background,
              ),
              itemsList: controller.modelYearsList,
              selectMethod: controller.isLoad
                  ? RxString(Strings.pleaseWait)
                  : controller.selectedYearName,
              onChanged: (v) {
                if (v == null) return;
                controller.selectedYearName.value = v;
                // parse and set numeric year
                final parsed = int.tryParse(v);
                controller.selectedYear.value = parsed;
                controller.carYear.value = parsed ?? 0;
              },
            ),
          ),
        ],
      ),
    );
  }
}
