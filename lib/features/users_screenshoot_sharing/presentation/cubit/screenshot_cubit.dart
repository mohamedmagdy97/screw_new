import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/entities/screenshot_entity.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/delete_screenshot_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/get_screenshots_usecase.dart';
import 'package:screw_calculator/features/users_screenshoot_sharing/domain/usecases/load_more_screenshots_usecase.dart';

part 'screenshot_state.dart';

/// Cubit for managing screenshot sharing screen state
class ScreenshotCubit extends Cubit<ScreenshotState> {
  final GetScreenshotsUseCase _getScreenshotsUseCase;
  final LoadMoreScreenshotsUseCase _loadMoreScreenshotsUseCase;
  final DeleteScreenshotUseCase _deleteScreenshotUseCase;

  final int _itemsPerPage = 10;
  StreamSubscription<List<ScreenshotEntity>>? _subscription;

  ScreenshotCubit({
    required GetScreenshotsUseCase getScreenshotsUseCase,
    required LoadMoreScreenshotsUseCase loadMoreScreenshotsUseCase,
    required DeleteScreenshotUseCase deleteScreenshotUseCase,
  })  : _getScreenshotsUseCase = getScreenshotsUseCase,
        _loadMoreScreenshotsUseCase = loadMoreScreenshotsUseCase,
        _deleteScreenshotUseCase = deleteScreenshotUseCase,
        super(ScreenshotInitial()) {
    _loadScreenshots();
  }

  /// Loads screenshots stream
  void _loadScreenshots() {
    emit(ScreenshotLoading());
    _subscription = _getScreenshotsUseCase.call(limit: _itemsPerPage).listen(
      (screenshots) {
        if (screenshots.isEmpty) {
          emit(ScreenshotEmpty());
        } else {
          emit(ScreenshotLoaded(
            screenshots: screenshots,
            hasMore: screenshots.length == _itemsPerPage,
            lastDocumentId: screenshots.last.id,
          ));
        }
      },
      onError: (error) {
        emit(ScreenshotError('حدث خطأ أثناء تحميل المشاركات'));
      },
    );
  }

  /// Loads more screenshots for pagination
  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is! ScreenshotLoaded || !currentState.hasMore) {
      return;
    }

    emit(ScreenshotLoadingMore(
      screenshots: currentState.screenshots,
      hasMore: currentState.hasMore,
      lastDocumentId: currentState.lastDocumentId,
    ));

    try {
      final newScreenshots = await _loadMoreScreenshotsUseCase.call(
        lastDocumentId: currentState.lastDocumentId!,
        limit: _itemsPerPage,
      );

      if (newScreenshots.isEmpty) {
        emit(ScreenshotLoaded(
          screenshots: currentState.screenshots,
          hasMore: false,
          lastDocumentId: currentState.lastDocumentId,
        ));
      } else {
        final updatedScreenshots = [
          ...currentState.screenshots,
          ...newScreenshots,
        ];
        emit(ScreenshotLoaded(
          screenshots: updatedScreenshots,
          hasMore: newScreenshots.length == _itemsPerPage,
          lastDocumentId: newScreenshots.last.id,
        ));
      }
    } catch (e) {
      emit(ScreenshotError('حدث خطأ أثناء تحميل المزيد من المشاركات'));
    }
  }

  /// Deletes a screenshot
  Future<void> deleteScreenshot(String screenshotId) async {
    final currentState = state;
    if (currentState is! ScreenshotLoaded) return;

    emit(ScreenshotDeleting(currentState.screenshots));

    try {
      final success = await _deleteScreenshotUseCase.call(screenshotId);
      if (success) {
        final updatedScreenshots = currentState.screenshots
            .where((s) => s.id != screenshotId)
            .toList();

        if (updatedScreenshots.isEmpty) {
          emit(ScreenshotEmpty());
        } else {
          emit(ScreenshotDeleted(updatedScreenshots));
          // Reload to get fresh data
          _loadScreenshots();
        }
      } else {
        emit(ScreenshotError('فشل في حذف المشاركة'));
      }
    } catch (e) {
      emit(ScreenshotError('حدث خطأ أثناء حذف المشاركة'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

