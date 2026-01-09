import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/screens/chat/widgets/users_status_bottom_sheet.dart';
import 'package:screw_calculator/utility/app_theme.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isSearching;
  final String userName;
  final TextEditingController searchController;
  final VoidCallback onToggleSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onPrevResult;
  final VoidCallback onNextResult;
  final VoidCallback onBackPressed;
  final List<int> searchResults;

  const ChatAppBar({
    super.key,
    required this.isSearching,
    required this.searchController,
    required this.onToggleSearch,
    required this.onSearchChanged,
    required this.onPrevResult,
    required this.onNextResult,
    required this.onBackPressed,
    required this.userName,
    required this.searchResults,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.grayy,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                cursorColor: AppColors.white,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  color: AppColors.white,
                  fontFamily: AppFonts.regular,
                ),
                decoration: InputDecoration(
                  hintText: 'بحث…',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    color: AppColors.white,
                    fontFamily: AppFonts.regular,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: onSearchChanged,
              )
            : CustomText(text: 'الشات', fontSize: 22.sp),
      ),
      leading: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .doc('users_presence')
            .collection('users_presence')
            .where('isOnline', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          final onlineCount = snapshot.hasData
              ? snapshot.data!.docs
                    .where((doc) => (doc.data() as Map)['name'] != userName)
                    .length
              : 0;

          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.people, color: AppColors.white),
                onPressed: () {
                  UsersStatusBottomSheet.show(
                    context,
                    currentUserName: userName,
                  );
                },
              ),
              if (onlineCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$onlineCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      actions: [
        if (isSearching && searchResults.isNotEmpty) ...[
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up, color: AppColors.white),
            onPressed: onPrevResult,
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
            onPressed: onNextResult,
          ),
        ],

        IconButton(
          icon: Icon(
            isSearching ? Icons.close : Icons.search,
            color: AppColors.white,
          ),
          onPressed: onToggleSearch,
        ),
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
