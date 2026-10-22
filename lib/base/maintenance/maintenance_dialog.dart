import 'package:flutter/material.dart';
import 'package:restart_app/restart_app.dart';
import '../utils/basic_import.dart';
import 'maintenance_model.dart';

class SystemMaintenanceController extends GetxController {
  RxBool maintenanceStatus = false.obs;
}

class MaintenanceDialog {
  show({required MaintenanceModel maintenanceModel}) {
    Get.dialog(
      WillPopScope(
        onWillPop: () async {
          Restart.restartApp();
          return false;
        },
        child: Dialog(
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            color: CustomColor.background,
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.horizontalSize * 0.8,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: Dimensions.verticalSize * 0.5,
                  ),
                  child: Image.network(
                    "${maintenanceModel.data.baseUrl}/${maintenanceModel.data.imagePath}/${maintenanceModel.data.image}",
                  ),
                ),
                TextWidget(
                  maintenanceModel.data.title,
                  textAlign: TextAlign.center,
                  typographyStyle: TypographyStyle.bodyLarge,
                ),
                Container(
                  margin: EdgeInsets.symmetric(
                    vertical: Dimensions.verticalSize * 0.5,
                  ),
                  child: TextWidget(
                    maintenanceModel.data.details,
                    textAlign: TextAlign.center,
                    typographyStyle: TypographyStyle.bodySmall,
                  ),
                ),
                PrimaryButton(
                  title: Strings.restart,
                  onPressed: () {
                    Restart.restartApp();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
