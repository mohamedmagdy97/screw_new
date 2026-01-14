import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_appbar.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/data/datasources/screenshot_data_source.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/data/repositories/screenshot_repository_impl.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/delete_screenshot_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/get_screenshots_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/load_more_screenshots_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/cubit/screenshot_cubit.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/widgets/delete_confirmation_dialog.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/widgets/empty_data.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/widgets/loading_indicator.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/presentation/widgets/screenshot_item.dart';
import 'package:screw_calculator/helpers/image_helper.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/utilities.dart';

class UserScSharingScreen extends StatelessWidget {
  const UserScSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _createScreenshotCubit(),
      child: const _UserScSharingView(),
    );
  }

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

  String _getGroupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) return 'اليوم';
    if (itemDate == yesterday) return 'الأمس';
    return DateFormat('yyyy/MM/dd').format(date);
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
            Utilities().showCustomSnack(
              context,
              txt: state.message,
              backgroundColor: Colors.red,
            );
          } else if (state is ScreenshotDeleted) {
            Utilities().showCustomSnack(
              context,
              txt: 'تم الحذف بنجاح ✓',
              backgroundColor: Colors.green,
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
            return const EmptyData();
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

            final Map<String, List<ScreenshotEntity>> grouped = {};
            if (state is ScreenshotLoaded || state is ScreenshotLoadingMore) {
              final list =
                  (state as dynamic).screenshots as List<ScreenshotEntity>;
              for (var s in list) {
                final String label = _getGroupLabel(s.timestamp);
                grouped.putIfAbsent(label, () => []).add(s);
              }
            }
            return CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                for (var entry in grouped.entries) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: CustomText(
                        text: entry.key,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // صورتين في الصف
                        mainAxisSpacing: 10.h,
                        crossAxisSpacing: 10.w,
                        // childAspectRatio: 2.5, // تحكم في طول الكارت
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ScreenshotItem(
                          screenshot: entry.value[index],
                          onDelete: () => _handleDelete(entry.value[index].id),
                          onTap: () => ImageHelper.showFullImage(
                            context,
                            entry.value[index].imageBase64.toString(),
                            padding: 16.0,
                            title: entry.key,
                          ),
                        ),

                        childCount: entry.value.length,
                      ),
                    ),
                  ),
                ],

                if (state is ScreenshotLoadingMore)
                  const SliverToBoxAdapter(child: LoadingIndicator()),
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
