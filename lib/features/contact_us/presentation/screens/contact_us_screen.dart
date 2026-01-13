import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screw_calculator/components/bottom_nav_text.dart';
import 'package:screw_calculator/components/custom_appbar.dart';
import 'package:screw_calculator/components/custom_text.dart';
import 'package:screw_calculator/features/contact_us/data/datasources/url_launcher_data_source.dart';
import 'package:screw_calculator/features/contact_us/data/repositories/contact_repository_impl.dart';
import 'package:screw_calculator/features/contact_us/domain/usecases/launch_contact_url_usecase.dart';
import 'package:screw_calculator/features/contact_us/presentation/cubit/contact_cubit.dart';
import 'package:screw_calculator/features/contact_us/presentation/widgets/social_media_button.dart';
import 'package:screw_calculator/generated/assets.dart';
import 'package:screw_calculator/utility/app_theme.dart';
import 'package:screw_calculator/utility/sochial_links.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _createContactCubit(),
      child: const _ContactUsView(),
    );
  }

  ContactCubit _createContactCubit() {
    final dataSource = UrlLauncherDataSourceImpl();
    final repository = ContactRepositoryImpl(dataSource: dataSource);
    final useCase = LaunchContactUrlUseCase(repository);
    return ContactCubit(launchContactUrlUseCase: useCase);
  }
}

class _ContactUsView extends StatelessWidget {
  const _ContactUsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'للتواصل وتقديم الاقتراحات'),
      backgroundColor: AppColors.bg,
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: CustomText(text: 'آهلا بيك يا صديقي', fontSize: 16),
                  ),
                  const CustomText(
                    text: 'يمكنك محادثتنا للأسئلة والاستفسارات من خلال',
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CustomText(
                text:
                    'نحن لا نبيع اللعبة ولكن يمكنك الارسال لمساعدتنا بتحسين التطبيق ومعرفة اخر التطبيقات',
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
