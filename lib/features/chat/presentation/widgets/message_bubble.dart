import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;
import 'package:screw_calculator/core/helpers/image_helper.dart';
import 'package:screw_calculator/core/helpers/phone_mask_helper.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/chat/data/models/chat_msg_model.dart';
import 'package:screw_calculator/features/chat/presentation/widgets/build_status_icons.dart';
import 'package:swipe_to/swipe_to.dart';

/// فقاعة رسالة واحدة في الشات (نص/صورة/محذوفة) مع رد ومشاهدات وتفاعلات.
///
/// عرض بحت: كل الأحداث تُمرَّر كـ callbacks من [ChatScreen].
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.bubbleKey,
    required this.msg,
    required this.isMe,
    required this.showName,
    required this.isHighlighted,
    required this.userName,
    required this.reactionRow,
    required this.onSwipeReply,
    required this.onLongPress,
    required this.onDoubleTap,
    this.replyPreview,
  });

  final GlobalKey bubbleKey;
  final ChatMessage msg;
  final bool isMe;
  final bool showName;
  final bool isHighlighted;
  final String? userName;

  /// صف التفاعلات (emoji) أسفل الرسالة.
  final Widget reactionRow;

  /// معاينة الرسالة المردود عليها (إن وُجدت).
  final Widget? replyPreview;

  final VoidCallback onSwipeReply;
  final VoidCallback onLongPress;
  final VoidCallback onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: bubbleKey,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            children: [
              if (msg.isDeleted)
                Column(
                  crossAxisAlignment: isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, right: 8, left: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.palette.border),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: CustomText(
                        text: 'تم حذف هذه الرسالة',
                        fontSize: 12,
                        color: context.palette.textSecondary,
                        textAlign: msg.name == userName
                            ? TextAlign.end
                            : TextAlign.start,
                      ),
                    ),
                  ],
                ),

              Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!msg.isDeleted)
                    IntrinsicWidth(
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),

                        child: SwipeTo(
                          iconColor: AppColors.white,
                          onRightSwipe: (details) {
                            onSwipeReply();
                            HapticFeedback.mediumImpact();
                          },
                          child: GestureDetector(
                            onLongPress: onLongPress,
                            onDoubleTap: onDoubleTap,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: 8,
                                left: 8,
                                top: 4,
                              ),
                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isHighlighted
                                          ? Color.alphaBlend(
                                              context.palette.win.withValues(
                                                alpha: 0.30,
                                              ),
                                              context.palette.surface,
                                            )
                                          : isMe
                                          ? Color.alphaBlend(
                                              context.palette.brand.withValues(
                                                alpha: 0.22,
                                              ),
                                              context.palette.surface,
                                            )
                                          : context.palette.surfaceElevated,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(12),
                                        topRight: const Radius.circular(12),
                                        bottomLeft: Radius.circular(
                                          isMe ? 12 : 0,
                                        ),
                                        bottomRight: Radius.circular(
                                          isMe ? 0 : 12,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (showName)
                                          Row(
                                            children: [
                                              CustomText(
                                                text: msg.name,
                                                fontSize: 14.sp,
                                                color: isMe
                                                    ? AppColors.mainColor
                                                    : AppColors.secondaryColor,
                                                fontFamily: AppFonts.bold,
                                              ),
                                            ],
                                          ),
                                        if (msg.replyTo != null) replyPreview!,

                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (msg.type != 'image')
                                              Flexible(
                                                child: CustomText(
                                                  text: isMe
                                                      ? msg.message
                                                      : PhoneMaskHelper.maskPhoneNumbers(
                                                          msg.message,
                                                        ),
                                                  fontSize: 14.sp,
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                            if (msg.type == 'image')
                                              GestureDetector(
                                                onTap: () =>
                                                    ImageHelper.showFullImage(
                                                      context,
                                                      msg.message,
                                                    ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.memory(
                                                    base64Decode(msg.message),
                                                    width: 0.2.sw,
                                                    height: 0.2.sh,
                                                    fit: BoxFit.cover,
                                                    cacheWidth: 400,
                                                    gaplessPlayback: true,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => const Icon(
                                                          Icons.broken_image,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                            const SizedBox(width: 8),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  intl.DateFormat.jm().format(
                                                    msg.timestamp,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    color: AppColors.grayy2,
                                                  ),
                                                ),

                                                BuildStatusIcons(
                                                  msg: msg,
                                                  isMe: isMe,
                                                ),
                                                if (msg.seenBy.isNotEmpty &&
                                                    msg.name == userName)
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 4),

                                                      Text(
                                                        '👁 ${msg.seenBy.length}',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: AppColors
                                                              .greenDark,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  reactionRow,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
