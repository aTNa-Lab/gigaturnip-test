import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class PaginationWrapper<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginationWrapper({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginationWrapper.fromJson(json) {
    try {
      return PaginationWrapper(
        count: json['count'],
        results: json['results'],
        previous: json['previous'],
        next: json['next'],
      );
    } catch (e) {
      rethrow;
    }
  }
}
