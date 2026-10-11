import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// يعرض ورقة إدخال النتيجة.
///
/// - [editRoundIndex] == null: إضافة نتيجة الجولة التالية للاعب.
/// - غير ذلك: تعديل نتيجة الجولة (0..4) المحددة.
Future<void> showScoreInputSheet({
  required BuildContext context,
  required DashboardCubit cubit,
  required PlayerModel player,
  int? editRoundIndex,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) => ScoreInputSheet(
      cubit: cubit,
      player: player,
      editRoundIndex: editRoundIndex,
    ),
  );
}

/// نوع كارت في شبكة الاختيار.
enum _CardKind { number, power, plus20, scrollGreen, scrollRed }

class _CardOption {
  const _CardOption(this.value, this.kind);

  final int value;
  final _CardKind kind;
}

/// الكروت المتاحة (قيم سكرو): -1 و0 و1..10 والباور (10) و+20 والسكرول.
const List<_CardOption> _cards = [
  _CardOption(-1, _CardKind.number),
  _CardOption(0, _CardKind.number),
  _CardOption(1, _CardKind.number),
  _CardOption(2, _CardKind.number),
  _CardOption(3, _CardKind.number),
  _CardOption(4, _CardKind.number),
  _CardOption(5, _CardKind.number),
  _CardOption(6, _CardKind.number),
  _CardOption(7, _CardKind.number),
  _CardOption(8, _CardKind.number),
  _CardOption(9, _CardKind.number),
  _CardOption(10, _CardKind.number),
  _CardOption(10, _CardKind.power),
  _CardOption(20, _CardKind.plus20),
  _CardOption(0, _CardKind.scrollGreen),
  _CardOption(25, _CardKind.scrollRed),
];

/// ورقة إدخال/تعديل نتيجة لاعب في جولة بحاسبة أوراق باللمس + كتابة يدوية.
class ScoreInputSheet extends StatefulWidget {
  const ScoreInputSheet({
    super.key,
    required this.cubit,
    required this.player,
    this.editRoundIndex,
  });

  final DashboardCubit cubit;
  final PlayerModel player;
  final int? editRoundIndex;

  @override
  State<ScoreInputSheet> createState() => _ScoreInputSheetState();
}

class _ScoreInputSheetState extends State<ScoreInputSheet> {
  final TextEditingController _controller = TextEditingController();

  /// قيم الكروت المختارة بالترتيب (لزر "حذف آخر كارت").
  final List<_CardOption> _picked = [];
  bool _hasValue = false;
  int _total = 0;

  bool get _isEdit => widget.editRoundIndex != null;

  /// فهرس الجولة المستهدفة (0..4).
  int get _roundIndex =>
      widget.editRoundIndex ?? widget.player.filledRoundsCount;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final current = int.tryParse(widget.player.roundValueAt(_roundIndex));
      if (current != null) _setTotal(current, fromCards: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setTotal(int value, {required bool fromCards}) {
    _total = value;
    _hasValue = true;
    _controller.text = '$value';
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
    if (!fromCards) _picked.clear();
  }

  void _pick(_CardOption card) {
    HapticFeedback.selectionClick();
    setState(() {
      _picked.add(card);
      _setTotal(_total + card.value, fromCards: true);
    });
  }

  void _removeLast() {
    if (_picked.isEmpty) return;
    setState(() {
      final last = _picked.removeLast();
      _setTotal(_total - last.value, fromCards: true);
    });
  }

  void _clear() {
    setState(() {
      _picked.clear();
      _total = 0;
      _hasValue = false;
      _controller.clear();
    });
  }

  void _onTyped(String text) {
    setState(() {
      final parsed = int.tryParse(text.trim());
      _picked.clear();
      _hasValue = parsed != null;
      _total = parsed ?? 0;
    });
  }

  void _submit({int multiplier = 1, bool screw = false}) {
    final value = screw ? 0 : _total * multiplier;
    if (_isEdit) {
      widget.cubit.applyScoreAt(widget.player, _roundIndex, value);
    } else {
      widget.cubit.applyScore(widget.player, value);
    }
    Navigator.pop(context);
  }

  int _countOf(_CardOption card) =>
      _picked.where((c) => c.kind == card.kind && c.value == card.value).length;

  Color _cardColor(AppPalette p, _CardKind kind, int value) {
    return switch (kind) {
      _CardKind.number => value <= 0 ? p.win : p.brandSoft,
      _CardKind.power => p.accent,
      _CardKind.plus20 => p.lose,
      _CardKind.scrollGreen => p.win,
      _CardKind.scrollRed => p.lose,
    };
  }

  String _label(AppLocalizations l10n, _CardOption c) => switch (c.kind) {
    _CardKind.number => '${c.value}',
    _CardKind.power => l10n.cardPower,
    _CardKind.plus20 => l10n.cardPlus20,
    _CardKind.scrollGreen => l10n.cardScrollGreen,
    _CardKind.scrollRed => l10n.cardScrollRed,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isFinalRound = _roundIndex == 4;
    final name = widget.player.name ?? '';

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== العنوان =====
            Row(
              children: [
                _Avatar(name: name),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomText(
                    text: _isEdit
                        ? l10n.scoreSheetEditTitle(name, _roundIndex + 1)
                        : l10n.scoreSheetAddTitle(name, _roundIndex + 1),
                    fontSize: 17,
                    fontFamily: AppFonts.bold,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== المجموع + الكتابة اليدوية =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                gradient: palette.brandGradient,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.cardsTotal,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontFamily: AppFonts.regular,
                          ),
                        ),
                        TextField(
                          textDirection: TextDirection.ltr,
                          controller: _controller,
                          onChanged: _onTyped,
                          keyboardType: const TextInputType.numberWithOptions(
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^-?\d{0,4}'),
                            ),
                          ],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontFamily: AppFonts.bold,
                          ),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            hintText: l10n.orTypeScore,
                            hintStyle: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 15,
                              fontFamily: AppFonts.regular,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RoundIconButton(
                    icon: Icons.backspace_outlined,
                    tooltip: l10n.removeLastCard,
                    onTap: _picked.isEmpty ? null : _removeLast,
                  ),
                  const SizedBox(width: 8),
                  _RoundIconButton(
                    icon: Icons.delete_sweep_outlined,
                    tooltip: l10n.clearCards,
                    onTap: _hasValue ? _clear : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== شبكة الكروت =====
            CustomText(
              text: l10n.pickYourCards,
              fontSize: 14,
              color: palette.textSecondary,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final card in _cards)
                  _CardChip(
                    label: _label(l10n, card),
                    isSpecial: card.kind != _CardKind.number,
                    color: _cardColor(palette, card.kind, card.value),
                    value: card.value,
                    count: _countOf(card),
                    onTap: () => _pick(card),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ===== الإجراءات =====
            FilledButton(
              onPressed: _hasValue ? _submit : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
                backgroundColor: palette.brand,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                textStyle: const TextStyle(
                  fontFamily: AppFonts.bold,
                  fontSize: 18,
                ),
              ),
              child: Text(_isEdit ? l10n.saveChanges : l10n.addScore),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _SecondaryAction(
                    label: l10n.multiplyBy2,
                    onTap: _hasValue ? () => _submit(multiplier: 2) : null,
                  ),
                ),
                if (isFinalRound) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: _SecondaryAction(
                      label: l10n.multiplyBy4,
                      onTap: _hasValue ? () => _submit(multiplier: 4) : null,
                    ),
                  ),
                ],
                const SizedBox(width: 10),
                Expanded(
                  child: _SecondaryAction(
                    label: l10n.screwZeroShort,
                    onTap: () => _submit(screw: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: palette.brand.withValues(alpha: 0.16),
      ),
      child: Text(
        initial,
        style: TextStyle(
          color: palette.brandSoft,
          fontSize: 20,
          fontFamily: AppFonts.bold,
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: enabled ? 0.2 : 0.08),
          ),
          child: Icon(
            icon,
            size: 22,
            color: Colors.white.withValues(alpha: enabled ? 1 : 0.4),
          ),
        ),
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  const _SecondaryAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.brandSoft,
          side: BorderSide(color: palette.border),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          textStyle: const TextStyle(fontFamily: AppFonts.bold, fontSize: 14),
        ),
        child: FittedBox(child: Text(label)),
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip({
    required this.label,
    required this.isSpecial,
    required this.color,
    required this.value,
    required this.count,
    required this.onTap,
  });

  final String label;
  final bool isSpecial;
  final Color color;
  final int value;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final selected = count > 0;
    return Semantics(
      button: true,
      label: '$label ($value)',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isSpecial ? 78 : 54,
          height: 66,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            color: Color.alphaBlend(
              color.withValues(alpha: selected ? 0.28 : 0.10),
              palette.surface,
            ),
            border: Border.all(
              color: selected ? color : palette.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      isSpecial ? '$value' : label,
                      style: TextStyle(
                        color: color,
                        fontSize: isSpecial ? 20 : 24,
                        fontFamily: AppFonts.bold,
                      ),
                    ),
                  ),
                  if (isSpecial)
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.textSecondary,
                        fontSize: 11,
                        fontFamily: AppFonts.regular,
                      ),
                    ),
                ],
              ),
              if (selected)
                PositionedDirectional(
                  top: 4,
                  end: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '×$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontFamily: AppFonts.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
