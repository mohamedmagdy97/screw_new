import 'package:flutter/material.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/app_header.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// شريط علوي للوحة النتائج: زر رجوع، وزر إعادة بدء اللعبة (مع تأكيد).
class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DashboardAppBar({
    super.key,
    required this.fromHistory,
    this.onResetConfirmed,
  });

  final bool fromHistory;
  final VoidCallback? onResetConfirmed;

  @override
  Size get preferredSize => const Size.fromHeight(AppHeader.height);

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showAppConfirmDialog(
      context,
      icon: Icons.restart_alt_rounded,
      tone: AppDialogTone.danger,
      title: l10n.warning,
      message: l10n.confirmResetRound,
      confirmText: l10n.yes,
      cancelText: l10n.no,
    );
    if (confirmed ?? false) onResetConfirmed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: AppLocalizations.of(context).results,
      backResult: true,
      leading: fromHistory
          ? null
          : HeaderIconButton(
              icon: Icons.restart_alt_rounded,
              onTap: () => _confirmReset(context),
            ),
    );
  }
}
