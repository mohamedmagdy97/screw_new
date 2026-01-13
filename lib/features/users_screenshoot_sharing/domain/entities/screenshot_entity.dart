class ScreenshotEntity {
  final String id;
  final String title;
  final String description;
  final DateTime datetime;
  final DateTime timestamp;
  final String? imageBase64;

  ScreenshotEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.datetime,
    required this.timestamp,
    this.imageBase64,
  });
}

