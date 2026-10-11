import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/app/di/service_locator.dart';
import 'package:screw_calculator/core/constants/social_links.dart';
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
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: CustomText(
                      text: AppLocalizations.of(context).drawerGreeting,
                      fontSize: 16,
                    ),
                  ),
                  CustomText(
                    text: AppLocalizations.of(context).contactIntro,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    spacing: 32,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialMediaButton(
                        assetPath: Assets.whatsappIcon,
                        onTap: () => context
                            .read<ContactCubit>()
                            .launchContactUrl(SocialLinks.whatsapp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(
                text: AppLocalizations.of(context).contactNote,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
