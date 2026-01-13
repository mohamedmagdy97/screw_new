part of 'video_cubit.dart';

/// Base state for video feature
abstract class VideoState {}

/// Initial state
class VideoInitial extends VideoState {}

/// Loading state
class VideoLoading extends VideoState {}

/// Loaded state with Chewie controller
class VideoLoaded extends VideoState {
  final ChewieController chewieController;

  VideoLoaded(this.chewieController);
}

/// Error state
class VideoError extends VideoState {
  final String message;

  VideoError(this.message);
}

