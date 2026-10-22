import 'package:carbo/base/utils/basic_import.dart';
import 'package:carbo/views/checkout/controller/checkout_controller.dart';
import 'package:flutter/material.dart';
import 'package:moyasar/moyasar.dart' as moyasar;

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CheckoutController());
    return Scaffold(
      appBar: CustomAppBar('Checkout'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.paymentConfig == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Failed to load payment configuration'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.paddingSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Payment Amount Card
              Card(
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.paddingSize),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        'Amount to Pay',
                        style: CustomStyle.bodyMedium,
                      ),
                      TextWidget(
                        '${controller.amount.toStringAsFixed(2)} ${controller.currency}',
                        style: CustomStyle.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: Dimensions.heightSize * 2),
              
              TextWidget(
                'Payment Details',
                style: CustomStyle.headlineSmall,
              ),
              SizedBox(height: Dimensions.heightSize),

              // Moyasar Credit Card Widget
              moyasar.CreditCard(
                config: controller.paymentConfig!,
                onPaymentResult: controller.onPaymentResult,
              ),
            ],
          ),
        );
      }),
    );
  }
}
