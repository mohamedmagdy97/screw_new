import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class YoutubeLikePlayer extends StatefulWidget {
  const YoutubeLikePlayer({super.key});

  @override
  State<YoutubeLikePlayer> createState() => _YoutubeLikePlayerState();
}

class _YoutubeLikePlayerState extends State<YoutubeLikePlayer>
    with WidgetsBindingObserver {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _videoController =
        VideoPlayerController.asset('assets/video/screw_video.mp4')
          ..initialize().then((_) {
            setState(() {
              _chewieController = ChewieController(
                videoPlayerController: _videoController,
                autoPlay: true,
                looping: false,
                allowFullScreen: true,
                allowPlaybackSpeedChanging: true,
                materialProgressColors: ChewieProgressColors(
                  playedColor: Colors.red,
                  handleColor: Colors.white,
                  backgroundColor: Colors.grey.shade600,
                  bufferedColor: Colors.grey,
                ),
              );
            });
          });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }


  void _skip(int seconds) {
    final pos = _videoController.value.position;
    final dur = _videoController.value.duration;
    final newPos = pos + Duration(seconds: seconds);
    _videoController.seekTo(
      // newPos.clamp(Duration.zero, dur),
      newPos,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: "شرح قواعد اللعبة", fontSize: 22.sp),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Transform.flip(
              flipX: true,
              child: const Icon(
                Icons.arrow_back_ios_sharp,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
      body: _chewieController != null
          ? GestureDetector(
              onDoubleTap: () => _skip(10),
              onHorizontalDragEnd: (details) {
                details.primaryVelocity! > 0 ? _skip(-10) : _skip(10);
              },
              child: Chewie(controller: _chewieController!),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
