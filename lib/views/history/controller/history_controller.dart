import 'package:carbo/views/history/model/history_model.dart';
import 'package:get/get.dart';

import '../../../base/api/endpoint/api_endpoint.dart';
import '../../../base/api/method/request_process.dart';
import '../../../base/enums/booking_status.dart';

class HistoryController extends GetxController {
  final List<RxBool> isExpanded = List.generate(1000, (_) => false.obs);

  void toggleCardExpansion(int index) {
    for (int i = 0; i < isExpanded.length; i++) {
      if (i != index) {
        isExpanded[i].value = false;
      }
    }
    isExpanded[index].toggle();
  }

  // ── Filter state ──────────────────────────────────────────────────
  final selectedFilter = 0.obs; // 0=All, 1=Ongoing, 2=Completed, 3=Cancelled

  List<History> get filteredList {
    if (selectedFilter.value == 0) return historyList;
    return historyList.where((h) {
      return switch (selectedFilter.value) {
        1 => h.status == BookingStatus.ongoing,
        2 => h.status == BookingStatus.completed,
        3 => h.status == BookingStatus.cancelled,
        _ => true,
      };
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getHistoryInfo();
  }

  var historyList = <History>[].obs;

  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _isRefreshing = false.obs;

  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get showShimmer => _isLoading.value && !_isRefreshing.value;

  // Pagination variables
  int _currentPage = 1;
  int _perPage = 10;
  bool _hasMore = true;
  int _totalItems = 0;

  bool get hasMore => _hasMore;
  int get totalItems => _totalItems;
  int get currentPage => _currentPage;

  late HistoryModel _historyModel;

  HistoryModel get historyModel => _historyModel;

  Future<HistoryModel?> getHistoryInfo({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!_hasMore || _isLoadingMore.value) return null;
      _isLoadingMore.value = true;
    }

    return RequestProcess().request<HistoryModel>(
      fromJson: HistoryModel.fromJson,
      apiEndpoint: ApiEndpoint.history,
      queryParams: {
        'page': _currentPage.toString(),
        'per_page': _perPage.toString(),
      },
      isLoading: isLoadMore ? _isLoadingMore : _isLoading,
      showErrorMessage: true,
      onSuccess: (value) {
        if (value == null) {
          _hasMore = false;
          if (isLoadMore) _isLoadingMore.value = false;
          return;
        }

        _historyModel = value;

        // Check if we have pagination info in the response
        if (value.data.history.isEmpty) {
          _hasMore = false;
          if (isLoadMore) _isLoadingMore.value = false;
          return;
        }

        if (!isLoadMore) {
          historyList.clear(); // Clear existing data only on initial load
          _currentPage = 1;
          _hasMore = true;
        }

        // Add new items to the list
        for (var element in value.data.history) {
          historyList.add(element);
        }

        // Use pagination metadata from API if available
        if (value.data.pagination != null) {
          _hasMore = value.data.pagination!.hasMore;
          _totalItems = value.data.pagination!.total;
          _currentPage = value.data.pagination!.currentPage + 1;
        } else {
          // Fallback: If we received less items than perPage, there are no more items
          if (value.data.history.length < _perPage) {
            _hasMore = false;
          } else {
            _currentPage++;
          }
        }

        if (isLoadMore) _isLoadingMore.value = false;
      },
    );
  }

  void loadMore() {
    if (!_hasMore || _isLoadingMore.value) return;
    getHistoryInfo(isLoadMore: true);
  }

  Future<void> refresh() async {
    _currentPage = 1;
    _hasMore = true;
    _isRefreshing.value = true;
    await getHistoryInfo();
    _isRefreshing.value = false;
  }
}
