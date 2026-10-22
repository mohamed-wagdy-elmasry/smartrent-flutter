part of 'history_screen.dart';

class HistoryMobileScreen extends GetView<HistoryController> {
  const HistoryMobileScreen({super.key});

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
        body: Column(
          children: [
            _HistoryHeader(controller: controller),
            _FilterBar(controller: controller),
            // ── List / Empty / Shimmer ────────────────────────────
            Expanded(
              child: Obx(
                () => controller.showShimmer
                    ? const HistoryShimmer()
                    : _bodyWidget(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyWidget() {
    return Obx(
      () => controller.filteredList.isNotEmpty
          ? _HistoryListView(controller: controller)
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

// ─── Filter Bar ───────────────────────────────────────────────────
class _FilterBar extends StatelessWidget {
  final HistoryController controller;
  const _FilterBar({required this.controller});

  static const _labels = [
    Strings.all,
    Strings.ongoing,
    Strings.complete,
    Strings.reject,
  ];

  static const _icons = [
    Icons.grid_view_rounded,
    Icons.play_circle_outline_rounded,
    Icons.check_circle_outline_rounded,
    Icons.cancel_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.defaultHorizontalSize,
        vertical: 12,
      ),
      child: Obx(
        () => Row(
          children: List.generate(_labels.length, (i) {
            final selected = controller.selectedFilter.value == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedFilter.value = i,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? CustomColor.primary
                        : CustomColor.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(_R.chip),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[i],
                        size: 18,
                        color: selected ? Colors.white : _C.inkLight,
                      ),
                      const SizedBox(height: 4),
                      TextWidget(
                        _labels[i],
                        typographyStyle: TypographyStyle.labelSmall,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        color: selected ? Colors.white : _C.inkLight,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── List View with infinite scroll ────────────────────────────────
class _HistoryListView extends StatefulWidget {
  final HistoryController controller;
  const _HistoryListView({required this.controller});

  @override
  State<_HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<_HistoryListView> {
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
