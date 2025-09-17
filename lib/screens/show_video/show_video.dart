/// main old screen
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:video_player/video_player.dart';

class ShowVideo extends StatefulWidget {
  const ShowVideo({super.key});

  @override
  State<ShowVideo> createState() => _ShowVideoState();
}

class _ShowVideoState extends State<ShowVideo> {
  late VideoPlayerController _controller;
  double _volume = 1.0; // Default volume (1.0 is max)

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/screw_video.mp4')
      ..initialize().then((ee) {
        setState(() {
          _controller.play();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _skipForward() {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;
    if (currentPosition + const Duration(seconds: 10) < duration) {
      _controller.seekTo(currentPosition + const Duration(seconds: 10));
    } else {
      _controller.seekTo(duration);
    }
  }

  void _skipBackward() {
    final currentPosition = _controller.value.position;
    if (currentPosition - const Duration(seconds: 10) > Duration.zero) {
      _controller.seekTo(currentPosition - const Duration(seconds: 10));
    } else {
      _controller.seekTo(Duration.zero);
    }
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
      body: Center(
        child: _controller.value.isInitialized
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                  const SizedBox(height: 20),

                  const SizedBox(height: 20),
                  // Video Controls (Skip Backward, Play/Pause, Skip Forward)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _skipBackward,
                        icon: const Icon(
                          Icons.replay_10,
                          color: AppColors.white,
                        ),
                        iconSize: 36,
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: AppColors.mainColorLight,
                        ),
                        iconSize: 36,
                      ),
                      IconButton(
                        onPressed: _skipForward,
                        icon: const Icon(
                          Icons.forward_10,
                          color: AppColors.white,
                        ),
                        iconSize: 36,
                      ),
                    ],
                  ),
                  // Volume Control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.volume_down, color: AppColors.white),
                      Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: (_volume * 100).toInt().toString(),
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                            _controller.setVolume(_volume);
                          });
                        },
                      ),
                      const Icon(Icons.volume_up, color: AppColors.white),
                    ],
                  ),
                ],
              )
            : const CircularProgressIndicator(), // Show a loader until the video is initialized
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}

/// update screen 1
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:screw_calculator/components/custom_text.dart';
// import 'package:screw_calculator/utility/app_theme.dart';
// import 'package:video_player/video_player.dart';
//
// class ShowVideo extends StatefulWidget {
//   const ShowVideo({super.key});
//
//   @override
//   State<ShowVideo> createState() => _ShowVideoState();
// }
//
// class _ShowVideoState extends State<ShowVideo> {
//   late VideoPlayerController _controller;
//   double _volume = 1.0;
//   double _playbackSpeed = 1.0;
//   bool _isFullScreen = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.asset('assets/video/screw_video.mp4')
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _skipForward() {
//     final pos = _controller.value.position;
//     final dur = _controller.value.duration;
//     _controller.seekTo(
//       pos + const Duration(seconds: 10) < dur ? pos + const Duration(seconds: 10) : dur,
//     );
//   }
//
//   void _skipBackward() {
//     final pos = _controller.value.position;
//     _controller.seekTo(
//       pos - const Duration(seconds: 10) > Duration.zero ? pos - const Duration(seconds: 10) : Duration.zero,
//     );
//   }
//
//   void _togglePlayPause() {
//     setState(() {
//       _controller.value.isPlaying ? _controller.pause() : _controller.play();
//     });
//   }
//
//   void _toggleFullScreen() {
//     setState(() => _isFullScreen = !_isFullScreen);
//     if (_isFullScreen) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => Scaffold(
//             backgroundColor: Colors.black,
//             body: SafeArea(
//               child: Center(
//                 child: AspectRatio(
//                   aspectRatio: _controller.value.aspectRatio,
//                   child: VideoPlayer(_controller),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ).then((_) {
//         setState(() => _isFullScreen = false);
//       });
//     }
//   }
//
//   String _formatDuration(Duration d) {
//     String twoDigits(int n) => n.toString().padLeft(2, "0");
//     return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: AppColors.grayy,
//         title: CustomText(text: "شرح قواعد اللعبة", fontSize: 22.sp),
//         actions: [
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.close, color: AppColors.white),
//           )
//         ],
//       ),
//       body: _controller.value.isInitialized
//           ? Column(
//         children: [
//           AspectRatio(
//             aspectRatio: _controller.value.aspectRatio,
//             child: VideoPlayer(_controller),
//           ),
//           const SizedBox(height: 16),
//           // SeekBar + Timer
//           Row(
//             children: [
//               Text(
//                 _formatDuration(_controller.value.position),
//                 style: const TextStyle(color: Colors.white),
//               ),
//               Expanded(
//                 child: VideoProgressIndicator(
//                   _controller,
//                   allowScrubbing: true,
//                   colors: const VideoProgressColors(
//                     playedColor: AppColors.mainColorLight,
//                     backgroundColor: Colors.grey,
//                   ),
//                 ),
//               ),
//               Text(
//                 _formatDuration(_controller.value.duration),
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ],
//           ),
//           // Controls
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 onPressed: _skipBackward,
//                 icon: const Icon(Icons.replay_10, color: AppColors.white),
//                 iconSize: 36,
//               ),
//               IconButton(
//                 onPressed: _togglePlayPause,
//                 icon: Icon(
//                   _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                   color: AppColors.mainColorLight,
//                 ),
//                 iconSize: 48,
//               ),
//               IconButton(
//                 onPressed: _skipForward,
//                 icon: const Icon(Icons.forward_10, color: AppColors.white),
//                 iconSize: 36,
//               ),
//               IconButton(
//                 onPressed: _toggleFullScreen,
//                 icon: Icon(
//                   _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//           // Volume Control
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               IconButton(
//                 icon: Icon(
//                   _volume == 0 ? Icons.volume_off : Icons.volume_up,
//                   color: Colors.white,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _volume = _volume == 0 ? 1.0 : 0.0;
//                     _controller.setVolume(_volume);
//                   });
//                 },
//               ),
//               Expanded(
//                 child: Slider(
//                   value: _volume,
//                   min: 0,
//                   max: 1,
//                   divisions: 10,
//                   onChanged: (val) {
//                     setState(() {
//                       _volume = val;
//                       _controller.setVolume(_volume);
//                     });
//                   },
//                 ),
//               ),
//             ],
//           ),
//           // Playback Speed
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text("Speed:", style: TextStyle(color: Colors.white)),
//               const SizedBox(width: 8),
//               DropdownButton<double>(
//                 dropdownColor: Colors.black,
//                 value: _playbackSpeed,
//                 items: const [
//                   DropdownMenuItem(value: 0.5, child: Text("0.5x")),
//                   DropdownMenuItem(value: 1.0, child: Text("1.0x")),
//                   DropdownMenuItem(value: 1.5, child: Text("1.5x")),
//                   DropdownMenuItem(value: 2.0, child: Text("2.0x")),
//                 ],
//                 onChanged: (val) {
//                   if (val != null) {
//                     setState(() {
//                       _playbackSpeed = val;
//                       _controller.setPlaybackSpeed(val);
//                     });
//                   }
//                 },
//               ),
//             ],
//           ),
//         ],
//       )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }

/// update screen 2

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:video_player/video_player.dart';
// import '../../components/custom_text.dart';
// import '../../utility/app_theme.dart';
//
// class ShowVideo extends StatefulWidget {
//   const ShowVideo({super.key});
//
//   @override
//   State<ShowVideo> createState() => _ShowVideoState();
// }
//
// class _ShowVideoState extends State<ShowVideo> {
//   late VideoPlayerController _controller;
//   double _volume = 1.0;
//   bool _showControls = true;
//   double _playbackSpeed = 1.0;
//   final List<double> _speeds = [0.5, 1.0, 1.5, 2.0];
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.asset('assets/video/screw_video.mp4')
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//         _controller.setVolume(_volume);
//       });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   void _togglePlayPause() {
//     setState(() {
//       _controller.value.isPlaying ? _controller.pause() : _controller.play();
//     });
//   }
//
//   void _skipForward() {
//     final pos = _controller.value.position;
//     final dur = _controller.value.duration;
//     _controller.seekTo(pos + const Duration(seconds: 10) > dur ? dur : pos + const Duration(seconds: 10));
//   }
//
//   void _skipBackward() {
//     final pos = _controller.value.position;
//     _controller.seekTo(pos - const Duration(seconds: 10) < Duration.zero ? Duration.zero : pos - const Duration(seconds: 10));
//   }
//
//   void _toggleControls() => setState(() => _showControls = !_showControls);
//
//   void _changeSpeed() {
//     final idx = _speeds.indexOf(_playbackSpeed);
//     final next = _speeds[(idx + 1) % _speeds.length];
//     setState(() {
//       _playbackSpeed = next;
//       _controller.setPlaybackSpeed(next);
//     });
//   }
//
//   void _enterFullScreen() async {
//     await Navigator.of(context).push(
//       PageRouteBuilder(
//         opaque: false,
//         pageBuilder: (_, __, ___) => Scaffold(
//           backgroundColor: Colors.black,
//           body: Center(
//             child: AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: VideoPlayer(_controller),
//             ),
//           ),
//         ),
//       ),
//     );
//     setState(() {}); // rebuild when back
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       appBar: AppBar(
//         title: CustomText(text: "شرح قواعد اللعبة", fontSize: 22.sp),
//         backgroundColor: AppColors.grayy,
//         centerTitle: true,
//       ),
//       body: _controller.value.isInitialized
//           ? GestureDetector(
//         onTap: _toggleControls,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             AspectRatio(
//               aspectRatio: _controller.value.aspectRatio,
//               child: VideoPlayer(_controller),
//             ),
//             if (_showControls)
//               Positioned.fill(
//                 child: Container(
//                   color: Colors.black45,
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       // --- Seek bar ---
//                       VideoProgressIndicator(
//                         _controller,
//                         allowScrubbing: true,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         colors: VideoProgressColors(
//                           playedColor: AppColors.mainColorLight,
//                           backgroundColor: Colors.grey.shade700,
//                           bufferedColor: Colors.grey.shade400,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       // --- Playback buttons ---
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                             onPressed: _skipBackward,
//                             icon: const Icon(Icons.replay_10, color: Colors.white),
//                             iconSize: 32,
//                           ),
//                           IconButton(
//                             onPressed: _togglePlayPause,
//                             icon: Icon(
//                               _controller.value.isPlaying
//                                   ? Icons.pause_circle_filled
//                                   : Icons.play_circle_fill,
//                               color: Colors.white,
//                               size: 48,
//                             ),
//                           ),
//                           IconButton(
//                             onPressed: _skipForward,
//                             icon: const Icon(Icons.forward_10, color: Colors.white),
//                             iconSize: 32,
//                           ),
//                         ],
//                       ),
//                       // --- Bottom controls ---
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                         child: Row(
//                           children: [
//                             IconButton(
//                               icon: Icon(
//                                 _volume > 0 ? Icons.volume_up : Icons.volume_off,
//                                 color: Colors.white,
//                               ),
//                               onPressed: () {
//                                 setState(() {
//                                   _volume = _volume > 0 ? 0 : 1;
//                                   _controller.setVolume(_volume);
//                                 });
//                               },
//                             ),
//                             Expanded(
//                               child: Slider(
//                                 value: _volume,
//                                 min: 0,
//                                 max: 1,
//                                 onChanged: (v) {
//                                   setState(() {
//                                     _volume = v;
//                                     _controller.setVolume(v);
//                                   });
//                                 },
//                               ),
//                             ),
//                             IconButton(
//                               icon: const Icon(Icons.speed, color: Colors.white),
//                               onPressed: _changeSpeed,
//                             ),
//                             Text(
//                               '${_playbackSpeed}x',
//                               style: const TextStyle(color: Colors.white),
//                             ),
//                             const SizedBox(width: 8),
//                             IconButton(
//                               icon: const Icon(Icons.fullscreen, color: Colors.white),
//                               onPressed: _enterFullScreen,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       )
//           : const Center(child: CircularProgressIndicator()),
//     );
//   }
// }

/// update screen 3 with pp

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:video_player/video_player.dart';
// import 'package:screw_calculator/components/custom_text.dart';
// import 'package:screw_calculator/utility/app_theme.dart';
//
// class ShowVideo extends StatefulWidget {
//   const ShowVideo({super.key});
//
//   @override
//   State<ShowVideo> createState() => _ShowVideoState();
// }
//
// class _ShowVideoState extends State<ShowVideo> with WidgetsBindingObserver {
//   late VideoPlayerController _controller;
//   double _volume = 1.0;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//
//     _controller = VideoPlayerController.asset('assets/video/screw_video.mp4')
//       ..initialize().then((_) {
//         setState(() {
//           _controller.play();
//         });
//       });
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _controller.dispose();
//     super.dispose();
//   }
//
//   /// Picture-in-Picture trigger
//   void _enterPipMode() {
//     // لسه Flutter ما بيدعمش PIP natively، تقدر تستخدم حزمة مثل `floating` أو `android_pip`.
//     // هنا مجرد placeholder لو هتضيف الحزمة:
//     // AndroidPip.enterPipMode();
//   }
//
//   void _skipForward() {
//     final position = _controller.value.position;
//     final duration = _controller.value.duration;
//     _controller.seekTo(position + const Duration(seconds: 10) < duration
//         ? position + const Duration(seconds: 10)
//         : duration);
//   }
//
//   void _skipBackward() {
//     final position = _controller.value.position;
//     _controller.seekTo(position - const Duration(seconds: 10) > Duration.zero
//         ? position - const Duration(seconds: 10)
//         : Duration.zero);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: AppColors.grayy,
//         title: CustomText(text: "شرح قواعد اللعبة", fontSize: 22.sp),
//         actions: [
//           IconButton(
//             onPressed: () => Navigator.pop(context),
//             icon: const Icon(Icons.close, color: Colors.white),
//           ),
//         ],
//       ),
//       body: _controller.value.isInitialized
//           ? GestureDetector(
//               onDoubleTap: _skipForward,
//               onLongPress: _enterPipMode,
//               onHorizontalDragEnd: (details) {
//                 if (details.primaryVelocity! > 0) {
//                   _skipBackward();
//                 } else {
//                   _skipForward();
//                 }
//               },
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   AspectRatio(
//                     aspectRatio: _controller.value.aspectRatio,
//                     child: VideoPlayer(_controller),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.replay_10, color: Colors.white),
//                         iconSize: 36,
//                         onPressed: _skipBackward,
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           _controller.value.isPlaying
//                               ? Icons.pause
//                               : Icons.play_arrow,
//                           color: AppColors.mainColorLight,
//                         ),
//                         iconSize: 40,
//                         onPressed: () {
//                           setState(() {
//                             _controller.value.isPlaying
//                                 ? _controller.pause()
//                                 : _controller.play();
//                           });
//                         },
//                       ),
//                       IconButton(
//                         icon:
//                             const Icon(Icons.forward_10, color: Colors.white),
//                         iconSize: 36,
//                         onPressed: _skipForward,
//                       ),
//                     ],
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.volume_down, color: Colors.white),
//                       SizedBox(
//                         width: 200.w,
//                         child: Slider(
//                           value: _volume,
//                           min: 0,
//                           max: 1,
//                           onChanged: (v) {
//                             setState(() {
//                               _volume = v;
//                               _controller.setVolume(_volume);
//                             });
//                           },
//                         ),
//                       ),
//                       const Icon(Icons.volume_up, color: Colors.white),
//                     ],
//                   ),
//                   ElevatedButton.icon(
//                     onPressed: _enterPipMode,
//                     icon: const Icon(Icons.picture_in_picture),
//                     label: const Text('PIP Mode'),
//                   )
//                 ],
//               ),
//             )
//           : const Center(child: CircularProgressIndicator()),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           setState(() {
//             _controller.value.isPlaying
//                 ? _controller.pause()
//                 : _controller.play();
//           });
//         },
//         child: Icon(
//           _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
//         ),
//       ),
//     );
//   }
// }

/// pp

// ios

// <key>UIBackgroundModes</key>
// <array>
//     <string>audio</string>
//     <string>picture-in-picture</string>
// </array>

// android

// <activity
//     android:name=".MainActivity"
//     android:resizeableActivity="true"
//     android:supportsPictureInPicture="true"
//     android:configChanges="orientation|screenSize|screenLayout|smallestScreenSize|keyboardHidden"
// />
