import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/more_apps/domain/entities/megtech_app.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// «تطبيقات تانية من MegTech»: أيقونة واسم وسطر وصف وشارة «نزّل» لكل تطبيق.
///
/// يختفي القسم أثناء التحميل ولو مفيش حاجة تتعرض، ولا يعطّل الصفحة أبدًا.
class MoreAppsSection extends StatefulWidget {
  const MoreAppsSection({
    super.key,
    required this.load,
    required this.open,
    this.allAppsUrl,
    this.padding = const EdgeInsets.fromLTRB(12, 16, 12, 8),
  });

  /// يحمّل التطبيقات المناسبة للمنصّة (فارغة عند الفشل).
  final Future<List<MegTechApp>> Function(AppPlatform platform) load;

  /// يفتح رابطًا خارجيًا (المتجر / صفحة MegTech).
  final Future<void> Function(String url) open;

  /// صفحة MegTech بكل التطبيقات؛ يضيف زر «كل تطبيقاتنا» تحت القائمة. على
  /// iPhone تُفتح بـ `?p=ios` لتعرض تطبيقات App Store فقط.
  final String? allAppsUrl;

  /// المسافة حول الكارت.
  final EdgeInsetsGeometry padding;

  @override
  State<MoreAppsSection> createState() => _MoreAppsSectionState();
}

class _MoreAppsSectionState extends State<MoreAppsSection> {
  Future<List<MegTechApp>>? _apps;
  late AppPlatform _platform;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _platform = Theme.of(context).platform == TargetPlatform.iOS
        ? AppPlatform.ios
        : AppPlatform.android;
    _apps ??= widget.load(_platform);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MegTechApp>>(
      future: _apps,
      builder: (context, snapshot) {
        final apps = snapshot.data ?? const <MegTechApp>[];
        if (apps.isEmpty) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context);
        final palette = context.palette;
        final allAppsUrl = widget.allAppsUrl;
        return Padding(
          padding: widget.padding,
          child: Material(
            color: palette.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              side: BorderSide(color: palette.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                  child: CustomText(
                    text: l10n.moreAppsTitle,
                    fontSize: 15,
                    fontFamily: AppFonts.bold,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                  ),
                ),
                for (final app in apps)
                  _AppRow(app: app, platform: _platform, open: widget.open),
                if (allAppsUrl != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: TextButton.icon(
                      key: const ValueKey('more-apps-all'),
                      onPressed: () => widget.open(
                        _platform == AppPlatform.ios
                            ? '$allAppsUrl?p=ios'
                            : allAppsUrl,
                      ),
                      icon: const Icon(Icons.apps_rounded, size: 20),
                      label: Text(l10n.moreAppsAll),
                    ),
                  )
                else
                  const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({
    required this.app,
    required this.platform,
    required this.open,
  });

  final MegTechApp app;
  final AppPlatform platform;
  final Future<void> Function(String url) open;

  static const double _iconSize = 52;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final link = app.linkFor(platform);
    return InkWell(
      key: ValueKey('more-app-${app.id}'),
      onTap: link == null ? null : () => open(link),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.md),
              child: _icon(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: app.name,
                    fontSize: 15,
                    textAlign: TextAlign.start,
                    height: 1.3,
                    maxLines: 1,
                  ),
                  CustomText(
                    text: app.tagline,
                    fontSize: 12,
                    color: palette.textSecondary,
                    textAlign: TextAlign.start,
                    height: 1.4,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _GetChip(label: AppLocalizations.of(context).moreAppsGet),
          ],
        ),
      ),
    );
  }

  Widget _icon(BuildContext context) {
    final palette = context.palette;
    final fallback = Container(
      width: _iconSize,
      height: _iconSize,
      color: palette.brand.withValues(alpha: 0.14),
      alignment: Alignment.center,
      child: CustomText(
        text: app.name.characters.first,
        fontSize: 20,
        fontFamily: AppFonts.bold,
        color: palette.brand,
      ),
    );
    final image = app.icon.startsWith('https://')
        ? Image.network(
            app.icon,
            width: _iconSize,
            height: _iconSize,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback,
          )
        : Image.asset(
            app.icon,
            width: _iconSize,
            height: _iconSize,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => fallback,
          );
    return Semantics(
      label: app.name,
      image: true,
      child: ExcludeSemantics(child: image),
    );
  }
}

/// شارة «نزّل» الذهبية.
class _GetChip extends StatelessWidget {
  const _GetChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: context.palette.gold,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: CustomText(
        text: label,
        fontSize: 12.5,
        fontFamily: AppFonts.bold,
        color: context.palette.onGold,
        maxLines: 1,
      ),
    );
  }
}
