part of 'video_cubit.dart';

abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final ChewieController chewieController;

  VideoLoaded(this.chewieController);
}

class VideoError extends VideoState {
  final String message;

  VideoError(this.message);
}
