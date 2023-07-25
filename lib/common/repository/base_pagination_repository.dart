import 'package:delivery_app/common/model/cursor_pagination_model.dart';
import 'package:delivery_app/common/model/pagination_params.dart';

abstract class IBasePaginationRepository<T> {
  Future<CursorPaginationModel<T>> paginate({
    PaginationParams? paginationParams = const PaginationParams(),
  });
}
