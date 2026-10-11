import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/constants/social_links.dart';
import 'package:screw_calculator/core/theme/app_palette.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/widgets/bottom_nav_text.dart';
import 'package:screw_calculator/core/widgets/custom_appbar.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/features/contact_us/presentation/cubit/contact_cubit.dart';
import 'package:screw_calculator/features/contact_us/presentation/widgets/social_media_button.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContactCubit>(),
      child: const _ContactUsView(),
    );
  }
}

class _ContactUsView extends StatelessWidget {
  const _ContactUsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context).contactTitle),
      bottomNavigationBar: const BottomNavigationText(),
      body: BlocListener<ContactCubit, ContactState>(
        listener: (context, state) {
          if (state is ContactError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context);
            final palette = context.palette;
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              children: [
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: palette.brandGradient,
                      boxShadow: [
                        BoxShadow(
                          color: palette.brand.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomText(
                  text: l10n.drawerGreeting,
                  fontSize: 22,
                  fontFamily: AppFonts.bold,
                ),
                const SizedBox(height: 8),
                CustomText(
                  text: l10n.contactIntro,
                  fontSize: 16,
                  color: palette.textSecondary,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(AppRadii.xl),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 32,
                    children: [
                      SocialMediaButton(
                        assetPath: Assets.whatsappIcon,
                        onTap: () => context
                            .read<ContactCubit>()
                            .launchContactUrl(SocialLinks.whatsapp),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.brand.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: CustomText(
                    text: l10n.contactNote,
                    fontSize: 14.5,
                    height: 1.7,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
