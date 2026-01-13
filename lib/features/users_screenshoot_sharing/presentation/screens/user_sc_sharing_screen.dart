import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_appbar.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/data/datasources/screenshot_data_source.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/data/repositories/screenshot_repository_impl.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/delete_screenshot_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/get_screenshots_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/load_more_screenshots_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/cubit/screenshot_cubit.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/widgets/screenshot_item.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class UserScSharingScreen extends StatelessWidget {
  const UserScSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _createScreenshotCubit(),
      child: const _UserScSharingView(),
    );
  }

  /// Creates and configures ScreenshotCubit with all dependencies
  ScreenshotCubit _createScreenshotCubit() {
    final dataSource = ScreenshotDataSourceImpl();
    final repository = ScreenshotRepositoryImpl(dataSource: dataSource);
    final getScreenshotsUseCase = GetScreenshotsUseCase(repository);
    final loadMoreScreenshotsUseCase = LoadMoreScreenshotsUseCase(repository);
    final deleteScreenshotUseCase = DeleteScreenshotUseCase(repository);
    return ScreenshotCubit(
      getScreenshotsUseCase: getScreenshotsUseCase,
      loadMoreScreenshotsUseCase: loadMoreScreenshotsUseCase,
      deleteScreenshotUseCase: deleteScreenshotUseCase,
    );
  }
}

class _UserScSharingView extends StatefulWidget {
  const _UserScSharingView();

  @override
  State<_UserScSharingView> createState() => _UserScSharingViewState();
}

class _UserScSharingViewState extends State<_UserScSharingView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ScreenshotCubit>().loadMore();
      }
    });
  }

  Future<void> _handleDelete(String screenshotId) async {
    final shouldDelete =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => const DeleteConfirmationDialog(),
        ) ??
        false;

    if (shouldDelete) {
      context.read<ScreenshotCubit>().deleteScreenshot(screenshotId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'مشاركات الاخرين'),
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocConsumer<ScreenshotCubit, ScreenshotState>(
        listener: (context, state) {
          if (state is ScreenshotError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(text: state.message, fontSize: 14.sp),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 50.h,
                  left: 8.w,
                  right: 8.w,
                ),
              ),
            );
          } else if (state is ScreenshotDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: CustomText(
                  text: 'تم الحذف بنجاح',
                  fontSize: 16.sp,
                  textAlign: TextAlign.center,
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ScreenshotInitial || state is ScreenshotLoading) {
            return const Center(
              child: CircularProgressIndicator.adaptive(
                strokeWidth: 4,
                backgroundColor: AppColors.mainColor,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
              ),
            );
          }

          if (state is ScreenshotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_search,
                    size: 64.sp,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16.h),
                  CustomText(
                    text: 'لا توجد مشاركات حالياً',
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            );
          }

          if (state is ScreenshotLoaded ||
              state is ScreenshotLoadingMore ||
              state is ScreenshotDeleting ||
              state is ScreenshotDeleted) {
            final screenshots = state is ScreenshotLoaded
                ? state.screenshots
                : state is ScreenshotLoadingMore
                ? state.screenshots
                : state is ScreenshotDeleting
                ? state.screenshots
                : (state as ScreenshotDeleted).screenshots;

            final hasMore = state is ScreenshotLoaded ? state.hasMore : false;
            final isLoadingMore = state is ScreenshotLoadingMore;

            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: 8.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return ScreenshotItem(
                        screenshot: screenshots[index],
                        onDelete: () => _handleDelete(screenshots[index].id),
                      );
                    }, childCount: screenshots.length),
                  ),
                ),
                if (isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: const CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                            backgroundColor: AppColors.mainColor,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.bg,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                if (!hasMore && screenshots.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Center(
                        child: CustomText(
                          text: 'تم عرض جميع النتائج',
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
