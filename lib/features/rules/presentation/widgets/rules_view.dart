import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/rules/data/rules_data.dart';
import 'package:screw_calculator/features/rules/domain/rule_entry.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// يعرض مرجع الكروت السريع أثناء اللعب في ورقة سفلية قابلة للسحب.
Future<void> showPowerCardsSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.8,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (ctx, controller) =>
          RulesView(cardsOnly: true, scrollController: controller),
    ),
  );
}

/// عرض القواعد: بحث + تصفية بالتصنيف + بطاقات. يُستخدم في شاشة القواعد
/// وفي المرجع السريع للكروت ([cardsOnly]).
class RulesView extends StatefulWidget {
  const RulesView({super.key, this.cardsOnly = false, this.scrollController});

  final bool cardsOnly;
  final ScrollController? scrollController;

  @override
  State<RulesView> createState() => _RulesViewState();
}

class _RulesViewState extends State<RulesView> {
  String _query = '';
  RuleCategory? _category;

  String _categoryLabel(AppLocalizations l10n, RuleCategory c) => switch (c) {
    RuleCategory.basics => l10n.rulesCatBasics,
    RuleCategory.power => l10n.rulesCatPower,
    RuleCategory.oscar => l10n.rulesCatOscar,
    RuleCategory.ramadan => l10n.rulesCatRamadan,
    RuleCategory.teams => l10n.rulesCatTeams,
    RuleCategory.goal => l10n.rulesCatGoal,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final all = rulesFor(Localizations.localeOf(context).languageCode);
    final base = widget.cardsOnly ? all.where((e) => e.isCard).toList() : all;
    final categories = <RuleCategory>[
      for (final c in RuleCategory.values)
        if (base.any((e) => e.category == c)) c,
    ];
    final entries = base
        .where((e) => _category == null || e.category == _category)
        .where((e) => e.matches(_query))
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: l10n.rulesSearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => setState(() => _query = ''),
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _CategoryChip(
                label: l10n.rulesFilterAll,
                selected: _category == null,
                onTap: () => setState(() => _category = null),
              ),
              for (final c in categories)
                _CategoryChip(
                  label: _categoryLabel(l10n, c),
                  selected: _category == c,
                  color: _colorOf(palette, c),
                  onTap: () => setState(() => _category = c),
                ),
            ],
          ),
        ),
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: CustomText(
                    text: l10n.rulesNoResults,
                    fontSize: 16,
                    color: palette.textSecondary,
                  ),
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: entries.length,
                  itemBuilder: (_, i) => _RuleCard(
                    entry: entries[i],
                    color: _colorOf(palette, entries[i].category),
                    icon: _iconOf(entries[i].category),
                    query: _query,
                  ),
                ),
        ),
      ],
    );
  }
}

Color _colorOf(AppPalette p, RuleCategory c) => switch (c) {
  RuleCategory.basics => p.brand,
  RuleCategory.power => p.accent,
  RuleCategory.oscar => const Color(0xFFF59E0B),
  RuleCategory.ramadan => const Color(0xFFFB923C),
  RuleCategory.teams => p.win,
  RuleCategory.goal => p.lose,
};

IconData _iconOf(RuleCategory c) => switch (c) {
  RuleCategory.basics => Icons.menu_book_rounded,
  RuleCategory.power => Icons.bolt_rounded,
  RuleCategory.oscar => Icons.auto_awesome_rounded,
  RuleCategory.ramadan => Icons.nights_stay_rounded,
  RuleCategory.teams => Icons.groups_rounded,
  RuleCategory.goal => Icons.flag_rounded,
};

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final c = color ?? palette.brand;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: c.withValues(alpha: 0.22),
        backgroundColor: palette.surface,
        side: BorderSide(color: selected ? c : palette.border),
        labelStyle: TextStyle(
          color: selected ? c : palette.textPrimary,
          fontFamily: AppFonts.regular,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.entry,
    required this.color,
    required this.icon,
    required this.query,
  });

  final RuleEntry entry;
  final Color color;
  final IconData icon;
  final String query;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: palette.border),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: color),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withValues(alpha: 0.16),
                          ),
                          child: Icon(icon, size: 19, color: color),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomText(
                            text: entry.title,
                            fontSize: 17,
                            fontFamily: AppFonts.bold,
                            color: color,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomText(
                      text: entry.body,
                      fontSize: 14.5,
                      height: 1.7,
                      textAlign: TextAlign.start,
                      maxLines: 40,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
