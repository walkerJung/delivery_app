import 'package:json_annotation/json_annotation.dart';

part 'cursor_pagination_model.g.dart';

abstract class CursorPaginationBase {}

class CursorPaginationError extends CursorPaginationBase {
  final String message;

  CursorPaginationError({
    required this.message,
  });
}

class CursorPaginationLoading extends CursorPaginationBase {}

@JsonSerializable(
  genericArgumentFactories: true,
)
class CursorPaginationModel<T> extends CursorPaginationBase {
  final CursorPaginationMeta meta;
  final List<T> data;

  CursorPaginationModel({
    required this.meta,
    required this.data,
  });

  factory CursorPaginationModel.fromJson(
          Map<String, dynamic> json, T Function(Object? json) fromJsonT) =>
      _$CursorPaginationModelFromJson(json, fromJsonT);
}

@JsonSerializable()
class CursorPaginationMeta {
  final int count;
  final bool hasMore;

  CursorPaginationMeta({
    required this.count,
    required this.hasMore,
  });

  factory CursorPaginationMeta.fromJson(Map<String, dynamic> json) =>
      _$CursorPaginationMetaFromJson(json);
}

// 위로 당겨 새로고침
class CursorPaginationRefetching extends CursorPaginationModel {
  CursorPaginationRefetching({
    required super.meta,
    required super.data,
  });
}

// 추가 데이터 요청하는중
class CursorPaginationFetchingMore extends CursorPaginationModel {
  CursorPaginationFetchingMore({
    required super.meta,
    required super.data,
  });
}
