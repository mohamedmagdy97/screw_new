import 'package:flutter/material.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/format_date_to_string.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/contact_us/presentation/screens/contact_us_screen.dart';
import 'package:screw_calculator/features/notifications/domain/entities/notification_entity.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// بطاقة إشعار: أيقونة/صورة، عنوان ونص وتاريخ، ونقطة للإشعار غير المقروء.
/// السحب في اتجاه يحذف (بتأكيد)، وفي الاتجاه الآخر يُخفي الإشعار.
class NotificationsItem extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onDelete;

  const NotificationsItem({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  Widget _swipeBackground(
    BuildContext context, {
    required Alignment alignment,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      alignment: alignment,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Icon(icon, color: Colors.white),
    );
  }

  Future<void> _open(BuildContext context) async {
    if (notification.type == 'contact') {
      await Navigator.of(context).push(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, _, _) => const ContactUsScreen(),
        ),
      );
    } else if (notification.type == 'action') {
      final url = notification.actionUrl;
      if (url != null && await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final l10n = AppLocalizations.of(context);
    final hasImage = (notification.image ?? '').isNotEmpty;

    return Dismissible(
      key: Key(notification.id),
      background: _swipeBackground(
        context,
        alignment: Alignment.centerLeft,
        color: palette.lose,
        icon: Icons.delete_outline_rounded,
      ),
      secondaryBackground: _swipeBackground(
        context,
        alignment: Alignment.centerRight,
        color: palette.accent,
        icon: Icons.visibility_off_rounded,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          Utilities().showCustomSnack(context, txt: l10n.notificationHidden);
          return true;
        }
        final confirmed = await showAppConfirmDialog(
          context,
          icon: Icons.delete_outline_rounded,
          tone: AppDialogTone.danger,
          title: l10n.warning,
          message: l10n.deleteNotificationQuestion,
          confirmText: l10n.yes,
          cancelText: l10n.no,
        );
        if (confirmed ?? false) onDelete();
        return confirmed ?? false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: notification.isRead
                ? palette.border
                : palette.brand.withValues(alpha: 0.6),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            onTap: () => _open(context),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          child: Image.network(
                            notification.image!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _FallbackIcon(color: palette.brand),
                          ),
                        )
                      : _FallbackIcon(color: palette.brand),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: context.readStartCross,
                      children: [
                        Row(
                          children: [
                            if (!notification.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsetsDirectional.only(
                                  end: 8,
                                ),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: palette.brand,
                                ),
                              ),
                            Expanded(
                              child: CustomText(
                                text: notification.title,
                                fontSize: 16.5,
                                fontFamily: AppFonts.bold,
                                textAlign: context.readStart,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          text: notification.description,
                          fontSize: 14.5,
                          height: 1.5,
                          textAlign: context.readStart,
                        ),
                        const SizedBox(height: 8),
                        CustomText(
                          text: notification.datetime.toSmartFormat(),
                          fontSize: 12,
                          color: palette.textSecondary,
                          textAlign: context.readStart,
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
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.md),
        color: color.withValues(alpha: 0.14),
      ),
      child: Icon(Icons.notifications_rounded, color: color),
    );
  }
}
