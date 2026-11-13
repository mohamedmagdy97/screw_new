import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/constants/app_links.dart';
import 'package:screw_calculator/core/constants/developer_info.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/helpers/url_launcher_data_source.dart';
import 'package:screw_calculator/features/more_apps/domain/usecases/get_more_apps_usecase.dart';
import 'package:screw_calculator/features/more_apps/presentation/widgets/more_apps_section.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// «عن التطبيق»: هوية التطبيق وإصداره، إيه هو، مين المطوّر وإزاي توصله،
/// تقييم/مشاركة/تراخيص، «تطبيقات تانية من MegTech»، وفي الآخر «من MegTech».
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  UrlLauncherDataSource get _launcher => sl<UrlLauncherDataSource>();

  Future<void> _open(String url) async => _launcher.launchUrl(url);

  Future<void> _whatsapp(String message) async {
    final messenger = ScaffoldMessenger.of(context);
    final failed = AppLocalizations.of(context).aboutOpenFailed;
    final url =
        'https://wa.me/${DeveloperInfo.whatsappNumber}'
        '?text=${Uri.encodeComponent(message)}';
    if (await _launcher.launchUrl(url)) return;
    await Clipboard.setData(
      const ClipboardData(text: DeveloperInfo.whatsappDisplay),
    );
    messenger.showSnackBar(SnackBar(content: Text(failed)));
  }

  Future<void> _copyEmail() async {
    final messenger = ScaffoldMessenger.of(context);
    final text = AppLocalizations.of(context).aboutEmailCopied;
    await Clipboard.setData(const ClipboardData(text: DeveloperInfo.email));
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    return Scaffold(
      appBar: CustomAppBar(title: l10n.aboutTitle),
      body: Directionality(
        textDirection: context.contentDirection,
        child: FutureBuilder<PackageInfo>(
          future: _info,
          builder: (context, snapshot) {
            final info = snapshot.data;
            final version = info?.version ?? '';
            return ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                24 + MediaQuery.of(context).padding.bottom,
              ),
              children: [
                _AppHero(info: info),
                const SizedBox(height: 20),
                _Card(
                  title: l10n.aboutAppTitle,
                  child: CustomText(
                    text: l10n.aboutAppBody,
                    fontSize: 14.5,
                    height: 1.7,
                    textAlign: TextAlign.start,
                  ),
                ),
                const SizedBox(height: 12),
                const _DeveloperCard(),
                const SizedBox(height: 12),
                _ListCard(
                  children: [
                    _Tile(
                      key: const ValueKey('about-whatsapp'),
                      icon: Icons.chat_rounded,
                      iconColor: palette.win,
                      title: l10n.aboutWhatsApp,
                      subtitle:
                          '${DeveloperInfo.whatsappDisplay}  ·  '
                          '${l10n.aboutWhatsAppHint}',
                      onTap: () =>
                          _whatsapp(l10n.aboutWhatsAppMessage(version)),
                    ),
                    _Tile(
                      key: const ValueKey('about-suggest'),
                      icon: Icons.lightbulb_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: l10n.aboutSuggest,
                      subtitle: l10n.aboutSuggestHint,
                      onTap: () => _whatsapp(l10n.aboutSuggestMessage),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ListCard(
                  children: [
                    _Tile(
                      key: const ValueKey('about-email'),
                      icon: Icons.mail_rounded,
                      title: l10n.aboutContact,
                      subtitle: DeveloperInfo.email,
                      subtitleLtr: true,
                      trailing: Icons.copy_rounded,
                      onTap: _copyEmail,
                    ),
                    _Tile(
                      key: const ValueKey('about-rate'),
                      icon: Icons.star_rounded,
                      iconColor: const Color(0xFFF59E0B),
                      title: l10n.aboutRate,
                      subtitle: l10n.aboutRateHint,
                      onTap: () => InAppReview.instance.openStoreListing(),
                    ),
                    _Tile(
                      key: const ValueKey('about-share'),
                      icon: Icons.share_rounded,
                      iconColor: palette.accent,
                      title: l10n.aboutShare,
                      onTap: () => SharePlus.instance.share(
                        ShareParams(text: l10n.inviteText(AppLinks.playStore)),
                      ),
                    ),
                    _Tile(
                      key: const ValueKey('about-licenses'),
                      icon: Icons.description_rounded,
                      iconColor: palette.textSecondary,
                      title: l10n.aboutLicenses,
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: l10n.appName,
                        applicationVersion: info == null
                            ? null
                            : '${info.version} (${info.buildNumber})',
                      ),
                    ),
                  ],
                ),
                MoreAppsSection(
                  load: sl<GetMoreAppsUseCase>().call,
                  open: _open,
                  allAppsUrl: AppLinks.megtechApps,
                  padding: const EdgeInsets.only(top: 12),
                ),
                const SizedBox(height: 24),
                CustomText(
                  text: l10n.aboutFooter,
                  fontSize: 13.5,
                  color: palette.textSecondary,
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomText(
                      text: l10n.aboutMadeBy,
                      fontSize: 13,
                      color: palette.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    const BrandMark(),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AppHero extends StatelessWidget {
  const _AppHero({required this.info});

  final PackageInfo? info;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final info = this.info;
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            boxShadow: [
              BoxShadow(
                color: palette.brand.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.xl),
            child: Image.asset(Assets.iconsMark, width: 96, height: 96),
          ),
        ),
        const SizedBox(height: 14),
        CustomText(text: l10n.appName, fontSize: 22, fontFamily: AppFonts.bold),
        const SizedBox(height: 2),
        CustomText(
          text: l10n.heroTagline,
          fontSize: 14,
          color: palette.brandSoft,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 20,
          child: info == null
              ? null
              : CustomText(
                  key: const ValueKey('about-version'),
                  text: l10n.aboutVersion(info.version, info.buildNumber),
                  fontSize: 12.5,
                  color: palette.textSecondary,
                  maxLines: 1,
                ),
        ),
      ],
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gold = Color(
      isDark ? DeveloperInfo.goldOnDark : DeveloperInfo.goldOnLight,
    );
    return _Card(
      title: l10n.aboutDeveloperTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الاسم والمسمى والعلامة يتقروا من الشمال لليمين حتى في العربي.
          Text(
            DeveloperInfo.name,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 19,
              fontFamily: AppFonts.bold,
              color: gold,
              height: 1.3,
            ),
          ),
          Text(
            DeveloperInfo.title,
            textDirection: TextDirection.ltr,
            style: TextStyle(
              fontSize: 13.5,
              fontFamily: AppFonts.regular,
              color: context.palette.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          const BrandMark(),
          const SizedBox(height: 12),
          CustomText(
            text: l10n.aboutDeveloperBody(DeveloperInfo.brand),
            fontSize: 14.5,
            height: 1.7,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}

/// علامة MegTech + الاسم، من الشمال لليمين زي اللوجو.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key});

  static const double _markSize = 20;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        Image.asset(
          DeveloperInfo.mark,
          key: const ValueKey('megtech-mark'),
          width: _markSize,
          height: _markSize,
          semanticLabel: DeveloperInfo.brand,
        ),
        const SizedBox(width: 6),
        Text(
          DeveloperInfo.brand,
          textDirection: TextDirection.ltr,
          style: TextStyle(
            fontSize: 13.5,
            fontFamily: AppFonts.bold,
            color: context.palette.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// كارت بعنوان بنفس شكل كروت التطبيق.
class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: title,
              fontSize: 15.5,
              fontFamily: AppFonts.bold,
              textAlign: TextAlign.start,
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(color: palette.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.subtitleLtr = false,
    this.iconColor,
    this.trailing = Icons.chevron_right_rounded,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool subtitleLtr;
  final Color? iconColor;
  final IconData trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final accent = iconColor ?? palette.brand;
    final subtitle = this.subtitle;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadii.sm + 4),
              ),
              child: Icon(icon, color: accent, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    fontSize: 15,
                    textAlign: TextAlign.start,
                    height: 1.3,
                    maxLines: 2,
                  ),
                  if (subtitle != null)
                    Directionality(
                      textDirection: subtitleLtr
                          ? TextDirection.ltr
                          : Directionality.of(context),
                      child: CustomText(
                        text: subtitle,
                        fontSize: 12.5,
                        color: palette.textSecondary,
                        textAlign: TextAlign.start,
                        height: 1.4,
                        maxLines: 2,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(trailing, color: palette.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
