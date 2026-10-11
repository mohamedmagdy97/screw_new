import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/domain/entities/score_edit.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/features/rules/presentation/widgets/rules_view.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// شريط الجولة أعلى لوحة النتائج: رقم الجولة بمؤشر تقدّم من 5 نقاط،
/// وأزرار: تراجع، مرجع الكروت، وسجل التعديلات.
class RoundHeader extends StatelessWidget {
  const RoundHeader({
    super.key,
    required this.cubit,
    required this.round,
    required this.readOnly,
  });

  final DashboardCubit cubit;
  final int round;

  /// عرض من السجل: بدون تراجع أو تعديل.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final finished = round == kGameFinishedRound;
    final current = finished ? 5 : round;
    final edits = cubit.state.edits;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: finished
                      ? l10n.roundsFinished
                      : l10n.roundOfFive(round),
                  fontSize: 17,
                  fontFamily: AppFonts.bold,
                  color: palette.brandSoft,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      Container(
                        width: 26,
                        height: 6,
                        margin: const EdgeInsetsDirectional.only(end: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                          color: i < current || finished
                              ? palette.win
                              : i == current
                              ? palette.brand
                              : palette.border,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _ToolButton(
            icon: Icons.bolt_rounded,
            tooltip: l10n.powerCardsTooltip,
            onTap: () => showPowerCardsSheet(context),
          ),
          if (!readOnly) ...[
            _ToolButton(
              icon: Icons.undo_rounded,
              tooltip: l10n.undo,
              onTap: cubit.canUndo ? cubit.undo : null,
            ),
            if (edits.isNotEmpty)
              _ToolButton(
                icon: Icons.history_edu_rounded,
                tooltip: l10n.editsLogTitle,
                badge: edits.length,
                onTap: () => _showEditsLog(context, edits),
              ),
          ],
        ],
      ),
    );
  }

  void _showEditsLog(BuildContext context, List<ScoreEdit> edits) {
    showAppSheet<void>(
      context,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        final palette = ctx.palette;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: l10n.editsLogTitle,
                  fontSize: 18,
                  fontFamily: AppFonts.bold,
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final e in edits.reversed)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            border: Border.all(color: palette.border),
                          ),
                          child: CustomText(
                            text: l10n.editsLogEntry(
                              e.playerName,
                              e.round,
                              e.oldValue,
                              e.newValue,
                            ),
                            fontSize: 15,
                            textAlign: TextAlign.start,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = onTap != null;
    final button = Container(
      width: 42,
      height: 42,
      margin: const EdgeInsetsDirectional.only(start: 6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.brand.withValues(alpha: enabled ? 0.14 : 0.06),
      ),
      child: Icon(
        icon,
        size: 22,
        color: enabled ? palette.brandSoft : palette.textSecondary,
      ),
    );
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: badge == null
            ? button
            : Badge(
                label: Text('$badge'),
                alignment: AlignmentDirectional.topEnd,
                child: button,
              ),
      ),
    );
  }
}
