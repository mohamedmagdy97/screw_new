/// Notification entity representing a notification in the domain layer
class NotificationEntity {
  final String id;
  final String title;
  final String description;
  final DateTime datetime;
  final String type;
  final String? image;
  final bool isRead;
  final String priority;
  final String? actionUrl;
  final String? createdAt;
  final String? token;
  final String? messageId;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.datetime,
    required this.type,
    this.image,
    this.isRead = false,
    this.priority = 'low',
    this.actionUrl,
    this.createdAt,
    this.token,
    this.messageId,
  });
}

