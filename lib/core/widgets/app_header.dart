import 'package:flutter/material.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

/// شريط علوي حديث: تدرّج الهوية بزوايا سفلية دائرية، عنوان في المنتصف،
/// وخانتان ماديتان [left] و[right] لأزرار دائرية شبه شفافة.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({super.key, required this.title, this.left, this.right});

  final String title;

  /// عنصر الجهة اليسرى/اليمنى فعليًا (بغضّ النظر عن اللغة).
  final Widget? left;
  final Widget? right;

  static const double height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: true,
      toolbarHeight: height,
      elevation: 0,
      scrolledUnderElevation: 0,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: palette.brandGradient,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(28),
          ),
        ),
      ),
      leadingWidth: 72,
      leading: left == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Align(alignment: Alignment.centerLeft, child: left),
            ),
      actions: [
        if (right != null)
          Padding(padding: const EdgeInsets.only(right: 16), child: right),
      ],
      title: CustomText(
        text: title,
        fontSize: 21,
        fontFamily: AppFonts.bold,
        color: Colors.white,
        maxLines: 1,
      ),
    );
  }
}

/// زر دائري شبه شفاف للشريط العلوي.
class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  /// عدّاد صغير فوق الزر (مثل عدد التعديلات).
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final button = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
    final content = badge == null || badge == 0
        ? button
        : Badge(label: Text('$badge'), child: button);
    return tooltip == null
        ? content
        : Tooltip(message: tooltip, child: content);
  }
}

/// زر الرجوع المناسب للغة: سهم يشير لليمين في العربي ولليسار في الإنجليزي.
class HeaderBackButton extends StatelessWidget {
  const HeaderBackButton({super.key, this.onTap, this.result});

  final VoidCallback? onTap;
  final Object? result;

  @override
  Widget build(BuildContext context) {
    return HeaderIconButton(
      icon: context.isArabicLocale
          ? Icons.arrow_forward_ios_rounded
          : Icons.arrow_back_ios_new_rounded,
      onTap: onTap ?? () => Navigator.pop(context, result),
    );
  }
}
