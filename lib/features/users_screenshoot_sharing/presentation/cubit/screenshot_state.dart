part of 'screenshot_cubit.dart';

/// Base state for screenshot feature
abstract class ScreenshotState {}

/// Initial state
class ScreenshotInitial extends ScreenshotState {}

/// Loading state
class ScreenshotLoading extends ScreenshotState {}

/// Loaded state with screenshots
class ScreenshotLoaded extends ScreenshotState {
  final List<ScreenshotEntity> screenshots;
  final bool hasMore;
  final String? lastDocumentId;

  ScreenshotLoaded({
    required this.screenshots,
    required this.hasMore,
    this.lastDocumentId,
  });
}

/// Loading more state
class ScreenshotLoadingMore extends ScreenshotState {
  final List<ScreenshotEntity> screenshots;
  final bool hasMore;
  final String? lastDocumentId;

  ScreenshotLoadingMore({
    required this.screenshots,
    required this.hasMore,
    this.lastDocumentId,
  });
}

/// Empty state when no screenshots are available
class ScreenshotEmpty extends ScreenshotState {}

/// Error state
class ScreenshotError extends ScreenshotState {
  final String message;

  ScreenshotError(this.message);
}

/// State when deleting a screenshot
class ScreenshotDeleting extends ScreenshotState {
  final List<ScreenshotEntity> screenshots;

  ScreenshotDeleting(this.screenshots);
}

/// State when screenshot is deleted successfully
class ScreenshotDeleted extends ScreenshotState {
  final List<ScreenshotEntity> screenshots;

  ScreenshotDeleted(this.screenshots);
}

