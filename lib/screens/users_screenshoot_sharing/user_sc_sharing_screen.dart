import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/components/dox_decoration.dart';
import 'package:screw_calculator/models/screenshoot_model.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class UserScSharingScreen extends StatefulWidget {
  const UserScSharingScreen({super.key});

  @override
  State<UserScSharingScreen> createState() => _UserScSharingScreenState();
}

class _UserScSharingScreenState extends State<UserScSharingScreen> {
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final int _itemsPerPage = 10;

  DocumentSnapshot? _lastDocument;
  List<ScreenShootModel> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  bool _isDisposed = false;
  StreamSubscription<QuerySnapshot>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _safeSetState(VoidCallback fn) {
    if (_isDisposed) return;
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed && mounted) {
          setState(fn);
        }
      });
    }
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreData();
      }
    });
  }

  Future<void> _loadInitialData() async {
    if (_isLoading) return;

    _safeSetState(() {
      _isLoading = true;
    });

    try {
      final query = _firestore
          .collection('user_screenshoot_sharing')
          .orderBy('timestamp', descending: true)
          .limit(_itemsPerPage);

      _subscription = query.snapshots().listen(
        (snapshot) {
          if (_isDisposed) return;

          if (snapshot.docs.isNotEmpty) {
            _lastDocument = snapshot.docs.last;

            final newItems = snapshot.docs.map((doc) {
              return ScreenShootModel.fromJson(doc.data(), doc.id);
            }).toList();

            _safeSetState(() {
              _items = newItems;
              _hasMore = snapshot.docs.length == _itemsPerPage;
              _isLoading = false;
            });
          } else {
            _safeSetState(() {
              _isLoading = false;
            });
          }
        },
        onError: (error) {
          if (_isDisposed) return;
          _safeSetState(() {
            _isLoading = false;
          });
          _showErrorSnackbar(error.toString());
        },
      );
    } catch (error) {
      if (_isDisposed) return;
      _safeSetState(() {
        _isLoading = false;
      });
      _showErrorSnackbar(error.toString());
    }
  }

  Future<void> _loadMoreData() async {
    if (_isLoading || !_hasMore || _lastDocument == null) return;

    _safeSetState(() {
      _isLoading = true;
    });

    try {
      final query = _firestore
          .collection('user_screenshoot_sharing')
          .orderBy('timestamp', descending: true)
          .startAfterDocument(_lastDocument!)
          .limit(_itemsPerPage);

      final snapshot = await query.get();

      if (_isDisposed) return;

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        final newItems = snapshot.docs.map((doc) {
          return ScreenShootModel.fromJson(doc.data(), doc.id);
        }).toList();

        _safeSetState(() {
          _items.addAll(newItems);
          _hasMore = snapshot.docs.length == _itemsPerPage;
        });
      } else {
        _safeSetState(() {
          _hasMore = false;
        });
      }
    } catch (error) {
      if (_isDisposed) return;
      _showErrorSnackbar(error.toString());
    } finally {
      if (!_isDisposed) {
        _safeSetState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteImage(String itemId) async {
    try {
      final shouldDelete = await _showDeleteConfirmationDialog();

      if (!shouldDelete) {
        return;
      }

      await _firestore
          .collection('user_screenshoot_sharing')
          .doc(itemId)
          .delete();

      _safeSetState(() {
        _items.removeWhere((item) => item.id == itemId);
      });

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
    } catch (error) {
      if (_isDisposed) return;
      _showErrorSnackbar('فشل في الحذف: ${error.toString()}');
    } finally {
      if (!_isDisposed) {}
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.textColorTitle,
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                CustomText(
                  text: 'تأكيد الحذف',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
            content: CustomText(
              text: 'هل أنت متأكد أنك تريد حذف هذه المشاركة؟',
              fontSize: 16.sp,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: CustomText(
                  text: 'إلغاء',
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: CustomText(
                  text: 'حذف',
                  fontSize: 16.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showErrorSnackbar(String message) {
    if (_isDisposed) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomText(text: message, fontSize: 14.sp),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 50.h,
          left: 8.w,
          right: 8.w,
        ),
      ),
    );
  }

  Widget _buildImageItem(ScreenShootModel item) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: GestureDetector(
        onDoubleTap: () => _deleteImage(item.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(4.w),
          decoration: customBoxDecoration(
            borderRadius: 8.r,
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: AppColors.opacity_1.withOpacity(0.75),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: Image.memory(
                base64Decode(item.imageBase64.toString()),
                width: 1.sw,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200.h,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey[400],
                        size: 48.sp,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return _isLoading
        ? Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Center(
              child: SizedBox(
                width: 24.w,
                height: 24.h,
                child: const CircularProgressIndicator.adaptive(
                  strokeWidth: 2,
                  backgroundColor: AppColors.mainColor,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bg),
                ),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_search, size: 64.sp, color: Colors.grey[400]),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.grayy,
        title: CustomText(text: 'مشاركات الاخرين', fontSize: 22.sp),
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
      backgroundColor: AppColors.bg,
      bottomNavigationBar: const BottomNavigationText(),
      body: _items.isEmpty && !_isLoading
          ? _buildEmptyState()
          : CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.only(top: 8.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return _buildImageItem(_items[index]);
                    }, childCount: _items.length),
                  ),
                ),
                SliverToBoxAdapter(child: _buildLoadingIndicator()),
                if (!_hasMore && _items.isNotEmpty)
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
            ),
    );
  }
}
