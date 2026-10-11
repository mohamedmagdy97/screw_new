import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';

/// شريط اختيار سريع لأسماء اللاعبين المحفوظين.
class RecentPlayersBar extends StatelessWidget {
  const RecentPlayersBar({
    super.key,
    required this.names,
    required this.onPick,
  });

  final ValueNotifier<List<String>> names;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: names,
      builder: (context, list, _) {
        if (list.isEmpty) return const SizedBox.shrink();
        final palette = context.palette;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const CustomText(
                text: 'لاعبون سابقون',
                fontSize: 14,
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in list)
                    ActionChip(
                      label: Text(name),
                      onPressed: () => onPick(name),
                      backgroundColor: palette.surface,
                      side: BorderSide(color: palette.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
