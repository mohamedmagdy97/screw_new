import 'package:flutter/material.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/features/rules/presentation/widgets/rules_view.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// شاشة قواعد اللعبة: بحث وتصفية بالتصنيف، بالعربية والإنجليزية.
class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context).rulesTitle),
      bottomNavigationBar: const BottomNavigationText(),
      body: Directionality(
        textDirection: context.contentDirection,
        child: const RulesView(),
      ),
    );
  }
}
