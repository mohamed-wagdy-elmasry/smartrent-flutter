part of 'history_screen.dart';

class HistoryTabletScreen extends GetView<HistoryController> {
  const HistoryTabletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Get.offAllNamed(Routes.dashboardScreen);
        }
      },
      child: Scaffold(
        backgroundColor: _C.surface,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                _HistoryHeader(controller: controller),
                _FilterBar(controller: controller),
                Expanded(
                  child: Obx(
                    () => controller.showShimmer
                        ? const HistoryShimmer()
                        : _bodyWidgetTablet(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyWidgetTablet() {
    return Obx(
      () => controller.filteredList.isNotEmpty
          ? _HistoryListViewTablet(controller: controller)
          : RefreshIndicator(
              onRefresh: controller.refresh,
              color: CustomColor.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: Get.height * 0.6,
                  child: EmptyDataWidget(massage: Strings.noHistory),
                ),
              ),
            ),
    );
  }
}

class _HistoryListViewTablet extends StatefulWidget {
  final HistoryController controller;
  const _HistoryListViewTablet({required this.controller});

  @override
  State<_HistoryListViewTablet> createState() => _HistoryListViewTabletState();
}

class _HistoryListViewTabletState extends State<_HistoryListViewTablet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final threshold = _scrollController.position.maxScrollExtent * 0.8;
    if (_scrollController.position.pixels >= threshold) {
      if (widget.controller.hasMore && !widget.controller.isLoadingMore) {
        widget.controller.loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: widget.controller.refresh,
      color: CustomColor.primary,
      child: Obx(
        () {
          final list = widget.controller.filteredList;
          return ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
              Dimensions.defaultHorizontalSize,
              12,
              Dimensions.defaultHorizontalSize,
              Dimensions.verticalSize,
            ),
            itemCount: list.length + (widget.controller.isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == list.length) {
                return Padding(
                  padding: EdgeInsets.all(Dimensions.heightSize * 2),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: CustomColor.primary,
                      ),
                    ),
                  ),
                );
              }
              if (index >= list.length) return const SizedBox.shrink();

              return TweenAnimationBuilder<double>(
                key: ValueKey(list[index].id),
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 350 + (index % 5) * 60),
                curve: Curves.easeOutCubic,
                builder: (_, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: child,
                  ),
                ),
                child: HistoryCard(list[index]),
              );
            },
          );
        },
      ),
    );
  }
}
