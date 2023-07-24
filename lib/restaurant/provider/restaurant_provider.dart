import 'package:delivery_app/common/model/cursor_pagination_model.dart';
import 'package:delivery_app/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>(
  (ref) {
    final repository = ref.watch(restaurantRepositoryProvider);
    final notifier = RestaurantStateNotifier(repository: repository);

    return notifier;
  },
);

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({required this.repository})
      : super(CursorPaginationLoading()) {
    paginate();
  }

  void paginate({
    int fetchCount = 20,
    bool fetchMore = false,
    bool forceRefetch = false,
  }) async {
    // 5가지 경우
    // State 의 상태
    // 1) CursorPagination - 정상적으로 데이터가 있는 상태
    // 2) CursorPaginationLoading - 데이터가 로딩중인 상태 (현재 캐시 없음)
    // 3) CursorPaginationError - 에러가 있는 상태
    // 4) CursorPaginationRefetching - 첫번째 페이지부터 다시 데이터를 가져올때
    // 5) CursorPaginationFetchMore - 추가 데이터를 paginate 해오라는 요청을 받았을때

    // 바로 반환하는 경우
    // 1) hasMore = false (기존 상태에서 이미 다음 데이터가 없다는 값을 들고있는 경우)
    // 2) 로딩중 - fetchMore : true
    //    fetchmore 가 아닐때 - 새로고침
    if (state is CursorPaginationModel && !forceRefetch) {
      final pState = state as CursorPaginationModel;

      if (!pState.meta.hasMore) {
        return;
      }
    }

    final isLoading = state is CursorPaginationLoading;
    final isRefetching = state is CursorPaginationRefetching;
    final isFetchingMore = state is CursorPaginationFetchingMore;

    if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
      return;
    }
  }
}
