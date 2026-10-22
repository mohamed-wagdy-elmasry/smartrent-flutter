import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:carbo/controllers/wallet_controller.dart';
import 'package:carbo/generated/l10n/app_localizations.dart';
import 'package:carbo/base/themes/token.dart';
import 'widgets/balance_header.dart';
import 'widgets/quick_actions.dart';
import 'widgets/transactions_section.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: RefreshIndicator(
          onRefresh: controller.refresh,
          color: CustomColor.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            slivers: [
              // Gradient background header
              SliverToBoxAdapter(
                child: _buildGradientHeader(context),
              ),
              
              // Balance cards
              SliverToBoxAdapter(
                child: BalanceHeader(controller: controller),
              ),
              
              // Quick actions
              SliverToBoxAdapter(
                child: QuickActions(controller: controller),
              ),
              
              // Transactions section
              TransactionsSection(controller: controller),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20.sp),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        AppLocalizations.of(context)!.appLMyWallet,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.history, color: Colors.white, size: 24.sp),
          onPressed: () {
            // Navigate to full transaction history
          },
        ),
      ],
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CustomColor.primary,
            CustomColor.primary.withOpacity(0.8),
            CustomColor.primary.withOpacity(0.6),
          ],
        ),
      ),
    );
  }
}
