import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class BalanceCardWidget extends StatelessWidget {
  final WalletController controller;

  const BalanceCardWidget({
    required this.controller,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingBalance.value && controller.balances.isEmpty) {
        return _buildLoadingCard();
      }

      if (controller.balances.isEmpty) {
        return _buildEmptyCard(context);
      }

      return _buildBalanceCard(context);
    });
  }

  Widget _buildLoadingCard() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24.h),
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(24.h),
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 48.sp,
                color: Colors.grey,
              ),
              SizedBox(height: 8.h),
              Text(
                AppLocalizations.of(Get.context!)?.appLNoWalletBalance ??
                    'No wallet balance available',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final defaultCurrency = 'SAR';
    final defaultBalance = controller.balances.firstWhereOrNull(
          (b) => b.currency == defaultCurrency,
        ) ??
        controller.balances.first;

    final displayBalance = controller.getBalanceForCurrency(defaultBalance.currency);
    final hasOptimisticChange =
        controller.optimisticBalanceChanges.containsKey(defaultBalance.currency);

    return SizedBox(
      height: 160.h,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        elevation: 4,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCurrencyHeader(defaultBalance.currency),
              _buildBalanceInfo(context, displayBalance, hasOptimisticChange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyHeader(String currency) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          currency,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        Icon(
          Icons.account_balance_wallet,
          color: Colors.white.withOpacity(0.8),
          size: 24.sp,
        ),
      ],
    );
  }

  Widget _buildBalanceInfo(
    BuildContext context,
    double displayBalance,
    bool hasOptimisticChange,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)?.appLAvailableBalance ??
              'Available Balance',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          children: [
            Text(
              displayBalance.toStringAsFixed(2),
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (hasOptimisticChange)
              Padding(
                padding: EdgeInsets.only(left: 8.w),
                child: Tooltip(
                  message: 'Processing...',
                  child: Icon(
                    Icons.pending,
                    color: Colors.amber,
                    size: 16.sp,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
