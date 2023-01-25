import 'package:json_annotation/json_annotation.dart';

part 'notification.g.dart';

@JsonSerializable()
class Notification {
  final int id;
  final DateTime createdAt;
  final String title;
  final String text;
  final int importance;

  Notification({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.text,
    required this.importance,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return _$NotificationFromJson(json);
  }
}
