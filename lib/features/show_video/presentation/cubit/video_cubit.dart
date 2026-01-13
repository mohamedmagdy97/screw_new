import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

part 'video_state.dart';

class VideoCubit extends Cubit<VideoState> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  VideoCubit() : super(VideoInitial()) {
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    emit(VideoLoading());
    try {
      _videoController = VideoPlayerController.asset('assets/video/screw_video.mp4');
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.white,
          backgroundColor: Colors.grey.shade600,
          bufferedColor: Colors.grey,
        ),
      );

      emit(VideoLoaded(_chewieController!));
    } catch (e) {
      emit(VideoError('حدث خطأ أثناء تحميل الفيديو'));
    }
  }

  void skip(int seconds) {
    if (_videoController != null && state is VideoLoaded) {
      final currentPosition = _videoController!.value.position;
      final duration = _videoController!.value.duration;
      final newPosition = currentPosition + Duration(seconds: seconds);

      Duration clampedPosition;
      if (newPosition < Duration.zero) {
        clampedPosition = Duration.zero;
      } else if (newPosition > duration) {
        clampedPosition = duration;
      } else {
        clampedPosition = newPosition;
      }

      _videoController!.seekTo(clampedPosition);
    }
  }

  @override
  Future<void> close() {
    _chewieController?.dispose();
    _videoController?.dispose();
    return super.close();
  }
}

