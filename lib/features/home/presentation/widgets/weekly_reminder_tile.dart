import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/features/home/presentation/widgets/drawer_tile.dart';
import 'package:screw_calculator/features/prayer/core/notification_service.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// عنصر القائمة الجانبية لتشغيل/إيقاف التذكير الأسبوعي بلعبة (اختياري).
class WeeklyReminderTile extends StatefulWidget {
  const WeeklyReminderTile({super.key});

  @override
  State<WeeklyReminderTile> createState() => _WeeklyReminderTileState();
}

class _WeeklyReminderTileState extends State<WeeklyReminderTile> {
  static const String _key = 'weeklyReminder';
  final Box<dynamic> _box = Hive.box<dynamic>('userBox');

  bool get _enabled => (_box.get(_key) as bool?) ?? false;

  Future<void> _toggle() async {
    final l10n = AppLocalizations.of(context);
    if (_enabled) {
      await NotificationService.cancelWeeklyGameReminder();
      await _box.put(_key, false);
      if (mounted) {
        setState(() {});
        Utilities().showCustomSnack(context, txt: l10n.reminderDisabled);
      }
      return;
    }
    final ok = await NotificationService.scheduleWeeklyGameReminder(
      title: l10n.reminderTitle,
      body: l10n.reminderBody,
    );
    if (!mounted) return;
    if (ok) {
      await _box.put(_key, true);
      if (!mounted) return;
      setState(() {});
    }
    Utilities().showCustomSnack(
      context,
      txt: ok ? l10n.reminderEnabled : l10n.reminderPermission,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DrawerTile(
      icon: Icons.alarm_rounded,
      title: l10n.weeklyReminderLabel,
      subtitle: l10n.weeklyReminderSub,
      color: context.palette.win,
      onTap: _toggle,
      trailing: Switch(value: _enabled, onChanged: (_) => _toggle()),
    );
  }
}
