import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:carbo/base/themes/token.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'payment_webview.dart';

class TopUpBottomSheet extends StatefulWidget {
  final WalletController controller;

  const TopUpBottomSheet({super.key, required this.controller});

  @override
  State<TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends State<TopUpBottomSheet> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedCurrency = 'SAR';
  bool _isProcessing = false;
  late AnimationController _animationController;

  final List<double> _quickAmounts = [50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, 500 * (1 - _animationController.value)),
            child: child,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHandle(),
                    SizedBox(height: 20.h),
                    _buildTitle(context),
                    SizedBox(height: 24.h),
                    _buildAmountField(context),
                    SizedBox(height: 16.h),
                    _buildQuickAmounts(),
                    SizedBox(height: 24.h),
                    _buildCurrencySelector(context),
                    SizedBox(height: 32.h),
                    _buildSubmitButton(context),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: CustomColor.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.account_balance_wallet,
            color: CustomColor.primary,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.appLTopUpWallet,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              'Add funds to your wallet',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.appLAmount,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            prefixIcon: Icon(Icons.attach_money, color: CustomColor.primary),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: CustomColor.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: Colors.red.shade400),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(errorText: 'Amount is required'),
            FormBuilderValidators.numeric(errorText: 'Please enter a valid number'),
            FormBuilderValidators.min(1, errorText: 'Minimum amount is 1'),
            FormBuilderValidators.max(50000, errorText: 'Maximum amount is 50,000'),
          ]),
        ),
      ],
    );
  }

  Widget _buildQuickAmounts() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: _quickAmounts.map((amount) {
        return GestureDetector(
          onTap: () => _amountController.text = amount.toString(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              '+$amount',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: CustomColor.primary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    final currencies = [
      {'code': 'SAR', 'name': 'Saudi Riyal'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.appLCurrency,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8.h),
        ...currencies.map((currency) {
          final isSelected = _selectedCurrency == currency['code'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCurrency = currency['code']!),
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected ? CustomColor.primary.withOpacity(0.1) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? CustomColor.primary : Colors.grey.shade200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? CustomColor.primary : Colors.grey.shade400,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    currency['code']!,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? CustomColor.primary : Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    currency['name']!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handleTopUp,
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomColor.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
          shadowColor: CustomColor.primary.withOpacity(0.3),
        ),
        child: _isProcessing
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Continue to Payment',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  Future<void> _handleTopUp() async {
    // Validate form first
    if (!_formKey.currentState!.validate()) {
      Get.snackbar(
        'Validation Error',
        'Please enter a valid amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        icon: const Icon(Icons.warning, color: Colors.orange),
      );
      return;
    }

    // Check if amount is entered
    if (_amountController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter an amount',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);
      
      // Validate amount range
      if (amount < 1 || amount > 50000) {
        throw Exception('Amount must be between 1 and 50,000');
      }
      
      // Create Moyasar invoice
      final invoiceData = await widget.controller.createTopUpInvoice(
        amount: amount,
        currency: _selectedCurrency,
      );

      if (invoiceData != null && invoiceData['invoice_url'] != null) {
        // Close bottom sheet before opening payment WebView
        if (mounted) {
          Get.back();
          await Future.delayed(const Duration(milliseconds: 300));
        }
        
        // Open invoice URL in in-app WebView
        final invoiceUrl = invoiceData['invoice_url'] as String;
        print('Opening payment WebView with URL: $invoiceUrl');
        
        // Open in WebView
        final result = await Get.to<String>(
          () => PaymentWebView(
            url: invoiceUrl,
            title: 'Complete Payment',
          ),
          fullscreenDialog: true,
        );
        
        print('WebView closed with result: $result');
        
        // Handle WebView result
        if (result == 'success') {
          if (mounted) {
            Get.snackbar(
              'Payment Completed',
              'Processing your payment. Your wallet will be updated shortly.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green.shade100,
              colorText: Colors.green.shade900,
              duration: const Duration(seconds: 5),
              icon: const Icon(Icons.check_circle, color: Colors.green),
            );
          }
          
          // Wait for webhook processing then refresh balance once
          await Future.delayed(const Duration(seconds: 3));
          widget.controller.refresh();
        } else if (result == 'failed') {
          if (mounted) {
            Get.snackbar(
              'Payment Failed',
              'The payment was not completed. Please try again.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red.shade100,
              colorText: Colors.red.shade900,
              icon: const Icon(Icons.error, color: Colors.red),
            );
          }
        } else {
          // User closed WebView without completing payment
          if (mounted) {
            Get.snackbar(
              'Payment Window Closed',
              'The payment was not completed. You can try again when ready.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.orange.shade100,
              colorText: Colors.orange.shade900,
              icon: const Icon(Icons.info, color: Colors.orange),
            );
          }
        }
        
        // Final refresh after longer delay (for webhook processing)
        Future.delayed(const Duration(seconds: 10), () {
          widget.controller.refresh();
        });
      } else {
        throw Exception(widget.controller.error.value.isNotEmpty 
            ? widget.controller.error.value 
            : 'Failed to create payment invoice');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        icon: const Icon(Icons.error, color: Colors.red),
        duration: const Duration(seconds: 5),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
