import 'package:flutter/material.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// نبرة الحوار: تحدّد لون الأيقونة وزر التأكيد.
enum AppDialogTone { brand, danger, success }

/// حوار تأكيد موحّد بتصميم حديث: أيقونة دائرية، عنوان، نص، وزران واضحان.
///
/// يعيد `true` عند التأكيد و`false`/`null` عند الإلغاء.
Future<bool?> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  String? message,
  IconData icon = Icons.help_outline_rounded,
  AppDialogTone tone = AppDialogTone.brand,
  String? confirmText,
  String? cancelText,
}) {
  final l10n = AppLocalizations.of(context);
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AppDialog(
      icon: icon,
      tone: tone,
      title: title,
      message: message,
      actions: [
        Expanded(
          child: AppDialogButton(
            label: cancelText ?? l10n.cancel,
            onPressed: () => Navigator.pop(ctx, false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AppDialogButton(
            label: confirmText ?? l10n.yes,
            primary: true,
            tone: tone,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ),
      ],
    ),
  );
}

/// قالب الحوار الحديث (زوايا 28، أيقونة، محتوى مرن، صف أزرار).
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.tone = AppDialogTone.brand,
    this.content,
    this.actions = const [],
  });

  final String title;
  final String? message;
  final IconData? icon;
  final AppDialogTone tone;

  /// محتوى إضافي بعد النص (قائمة، حقول...).
  final Widget? content;
  final List<Widget> actions;

  Color _toneColor(AppPalette p) => switch (tone) {
    AppDialogTone.brand => p.brand,
    AppDialogTone.danger => p.lose,
    AppDialogTone.success => p.win,
  };

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = _toneColor(palette);
    return Directionality(
      textDirection: context.contentDirection,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.14),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
              if (icon != null) const SizedBox(height: 16),
              CustomText(
                text: title,
                fontSize: 20,
                fontFamily: AppFonts.bold,
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 10),
                CustomText(
                  text: message!,
                  fontSize: 15,
                  color: palette.textSecondary,
                  textAlign: TextAlign.center,
                  height: 1.6,
                ),
              ],
              if (content != null) ...[const SizedBox(height: 14), content!],
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 22),
                Row(children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// زر داخل الحوار: ثانوي (حد) أو رئيسي (ممتلئ بلون النبرة).
class AppDialogButton extends StatelessWidget {
  const AppDialogButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.tone = AppDialogTone.brand,
  });

  final String label;
  final VoidCallback onPressed;
  final bool primary;
  final AppDialogTone tone;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = switch (tone) {
      AppDialogTone.brand => palette.brand,
      AppDialogTone.danger => palette.lose,
      AppDialogTone.success => palette.win,
    };
    return SizedBox(
      height: 48,
      child: primary
          ? FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                textStyle: const TextStyle(
                  fontFamily: AppFonts.bold,
                  fontSize: 16,
                ),
              ),
              child: Text(label),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: palette.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                textStyle: const TextStyle(
                  fontFamily: AppFonts.regular,
                  fontSize: 16,
                ),
              ),
              child: Text(label),
            ),
    );
  }
}

/// ورقة سفلية حديثة بمقبض سحب وزوايا علوية 28 (من ثيم التطبيق).
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => Directionality(
      textDirection: ctx.contentDirection,
      child: builder(ctx),
    ),
  );
}
