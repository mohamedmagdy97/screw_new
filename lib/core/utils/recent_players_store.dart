import 'dart:convert';

import 'package:screw_calculator/core/constants/local_storage_keys.dart';
import 'package:screw_calculator/core/utils/local_store.dart';

/// يحفظ أسماء اللاعبين الأخيرة لاختيارها بسرعة بدل إعادة كتابتها.
class RecentPlayersStore {
  static const int maxNames = 12;

  Future<List<String>> load() async {
    final raw = await AppLocalStore.getString(LocalStoreNames.recentPlayers);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>).cast<String>();
    } catch (_) {
      return const [];
    }
  }

  /// يضيف [names] في المقدمة (الأحدث أولًا) دون تكرار، ويقصّ القائمة.
  Future<List<String>> remember(Iterable<String> names) async {
    final cleaned = names.map((n) => n.trim()).where((n) => n.isNotEmpty);
    final current = await load();
    final merged = <String>[];
    for (final n in [...cleaned, ...current]) {
      if (!merged.any((m) => m.toLowerCase() == n.toLowerCase())) merged.add(n);
    }
    final result = merged.take(maxNames).toList();
    await AppLocalStore.setString(
      LocalStoreNames.recentPlayers,
      jsonEncode(result),
    );
    return result;
  }
}
