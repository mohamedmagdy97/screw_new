import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/show_video/presentation/cubit/video_cubit.dart';
import 'package:screw_calculator/utility/app_theme.dart';

/// Show video screen following clean architecture
class YoutubeLikePlayer extends StatelessWidget {
  const YoutubeLikePlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VideoCubit(),
      child: const _ShowVideoView(),
    );
  }
}

class _ShowVideoView extends StatelessWidget {
  const _ShowVideoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: 'شرح قواعد اللعبة', fontSize: 22.sp),
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
      body: BlocBuilder<VideoCubit, VideoState>(
        builder: (context, state) {
          if (state is VideoInitial || state is VideoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VideoLoaded) {
            return GestureDetector(
              onDoubleTap: () => context.read<VideoCubit>().skip(10),
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  context.read<VideoCubit>().skip(
                        details.primaryVelocity! > 0 ? -10 : 10,
                      );
                }
              },
              child: Chewie(controller: state.chewieController),
            );
          }

          if (state is VideoError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  CustomText(
                    text: state.message,
                    fontSize: 16,
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

