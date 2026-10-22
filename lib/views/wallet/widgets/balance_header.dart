import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:carbo/base/themes/token.dart';

class BalanceHeader extends StatelessWidget {
  final WalletController controller;

  const BalanceHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: Column(
          children: [
            Obx(() {
              final isLoading = controller.isLoadingBalance.value;
              final currency = controller.selectedCurrency.value;
              final balance = controller.getBalanceForCurrency(currency);
              final hasOptimisticChange =
                  controller.optimisticBalanceChanges[currency] != null;

              return _buildMainBalanceCard(
                context,
                isLoading: isLoading,
                currency: currency,
                balance: balance,
                hasOptimisticChange: hasOptimisticChange,
              );
            }),
          ],
        ),
    );
  }

  Widget _buildMainBalanceCard(
    BuildContext context, {
    required bool isLoading,
    required String currency,
    required double balance,
    required bool hasOptimisticChange,
  }) {
    if (isLoading) {
      return _buildShimmerCard();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColor.primary,
            CustomColor.primary.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: CustomColor.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.appLAvailableBalance,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        currency,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  tween: Tween(begin: 0.0, end: balance),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      '${value.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                        letterSpacing: -1,
                      ),
                    );
                  },
                ),
                SizedBox(height: 8.h),
                if (hasOptimisticChange)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.pending, color: Colors.white, size: 14.sp),
                        SizedBox(width: 6.w),
                        Text(
                          AppLocalizations.of(context)!.appLPaymentProcessing,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ),
    );
  }



  Widget _buildShimmerCard() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade200,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: controller.shimmerController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: LinearGradient(
                begin: Alignment(-1.0 + 2.0 * controller.shimmerController.value, 0),
                end: Alignment(1.0 + 2.0 * controller.shimmerController.value, 0),
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade50,
                  Colors.grey.shade200,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
