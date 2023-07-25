import 'package:delivery_app/common/model/cursor_pagination_model.dart';
import 'package:delivery_app/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantRatingStateNotifier
    extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantRatingStateNotifier({required this.repository})
      : super(CursorPaginationLoading());
}
