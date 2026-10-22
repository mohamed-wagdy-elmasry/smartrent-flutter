import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/models/wallet_transaction.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:carbo/base/themes/token.dart';
import 'package:intl/intl.dart';

class TransactionsSection extends StatelessWidget {
  final WalletController controller;

  const TransactionsSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(top: 0, left: 20.w, right: 20.w, bottom: 20.h),
      sliver: SliverToBoxAdapter(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context),
              SizedBox(height: 16.h),
              Obx(() => _buildTransactionsList(context)),
            ],
          ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.appLRecentTransactions,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Obx(() {
          if (controller.isRefreshing.value) {
            return SizedBox(
              width: 20.w,
              height: 20.h,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(CustomColor.primary),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    if (controller.isLoadingTransactions.value && controller.transactions.isEmpty) {
      return _buildLoadingState();
    }

    if (controller.transactions.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.transactions.length + (controller.hasMore.value ? 1 : 0),
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        if (index == controller.transactions.length) {
          return _buildLoadMoreButton();
        }
        
        return _TransactionCard(
          transaction: controller.transactions[index],
          index: index,
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        5,
        (index) => Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 80.h,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context)!.appLNoTransactions,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: TextButton(
        onPressed: () => controller.fetchTransactions(loadMore: true),
        child: Text(
          'Load More',
          style: TextStyle(
            color: CustomColor.primary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final WalletTransaction transaction;
  final int index;

  const _TransactionCard({
    required this.transaction,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == WalletTransactionType.topup ||
        transaction.type == WalletTransactionType.refundWallet;
    
    final color = _getTransactionColor();

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getTransactionIcon(),
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 14.w),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _getTransactionTitle(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          softWrap: true,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${isCredit ? '+' : '-'}${transaction.amount} ${transaction.currency}',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                          color: isCredit ? Colors.green.shade600 : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          DateFormat('MMM dd, yyyy • HH:mm').format(transaction.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildStatusBadge(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = _getStatusColor();
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        transaction.status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  IconData _getTransactionIcon() {
    switch (transaction.type) {
      case WalletTransactionType.topup:
        return Icons.add_circle;
      case WalletTransactionType.debit:
        return Icons.shopping_bag;
      case WalletTransactionType.refundWallet:
      case WalletTransactionType.refundCard:
        return Icons.replay_circle_filled;
    }
  }

  Color _getTransactionColor() {
    switch (transaction.type) {
      case WalletTransactionType.topup:
        return Colors.green.shade600;
      case WalletTransactionType.debit:
        return Colors.blue.shade600;
      case WalletTransactionType.refundWallet:
      case WalletTransactionType.refundCard:
        return Colors.orange.shade600;
    }
  }

  Color _getStatusColor() {
    switch (transaction.status) {
      case WalletTransactionStatus.completed:
        return Colors.green.shade600;
      case WalletTransactionStatus.pending:
        return Colors.orange.shade600;
      case WalletTransactionStatus.failed:
        return Colors.red.shade600;
      case WalletTransactionStatus.cancelled:
        return Colors.grey.shade600;
    }
  }

  String _getTransactionTitle() {
    switch (transaction.type) {
      case WalletTransactionType.topup:
        return 'Wallet Top-up';
      case WalletTransactionType.debit:
        return transaction.description ?? 'Payment';
      case WalletTransactionType.refundWallet:
        return 'Refund to Wallet';
      case WalletTransactionType.refundCard:
        return 'Refund to Card';
    }
  }
}
