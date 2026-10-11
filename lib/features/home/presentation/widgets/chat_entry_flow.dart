import 'package:flutter/material.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/enums.dart';
import 'package:screw_calculator/core/utils/utilities.dart';
import 'package:screw_calculator/core/utils/validation_form.dart';
import 'package:screw_calculator/core/widgets/app_dialog.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text_field.dart';
import 'package:screw_calculator/features/chat/presentation/screens/chat_screen.dart';
import 'package:screw_calculator/features/home/presentation/controller/home_controller.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

/// يفتح الشات العام من القائمة الجانبية: يطلب بيانات المستخدم أول مرة، ثم
/// يتأكد من صلاحية الدخول ويفتح الشاشة.
///
/// [drawerContext] هو سياق القائمة الجانبية (يُغلق قبل فتح الشات).
Future<void> openPublicChat(
  BuildContext drawerContext,
  HomeController homeData,
) async {
  final l10n = AppLocalizations.of(drawerContext);
  final needsRegistration =
      homeData.userName == null ||
      homeData.userPhone == null ||
      homeData.userCountry == null;

  if (needsRegistration) {
    await showDialog<void>(
      context: drawerContext,
      builder: (ctx) => _RegistrationDialog(
        homeData: homeData,
        drawerContext: drawerContext,
        dialogContext: ctx,
      ),
    );
    return;
  }

  final canEnter = await homeData.canUserEnterChat(
    phone: homeData.userPhone!,
    name: homeData.userName!,
  );
  if (!drawerContext.mounted) return;
  if (!canEnter) {
    await showDialog<void>(
      context: drawerContext,
      builder: (ctx) => AppDialog(
        icon: Icons.lock_outline_rounded,
        tone: AppDialogTone.danger,
        title: l10n.chatUnavailableTitle,
        message: l10n.chatUnavailableBody,
        actions: [
          Expanded(
            child: AppDialogButton(
              label: l10n.close,
              primary: true,
              onPressed: () => Navigator.pop(ctx),
            ),
          ),
        ],
      ),
    );
    return;
  }
  await homeData.routeFromDrawer(drawerContext, const ChatScreen());
}

class _RegistrationDialog extends StatelessWidget {
  const _RegistrationDialog({
    required this.homeData,
    required this.drawerContext,
    required this.dialogContext,
  });

  final HomeController homeData;
  final BuildContext drawerContext;
  final BuildContext dialogContext;

  Future<void> _submit(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    if (!homeData.formKeyUserData.currentState!.validate()) return;

    final result = await homeData.validateUser(
      name: homeData.nameController.text.trim(),
      phone: homeData.phoneController.text.trim(),
      country: homeData.countryController.text.trim(),
      age: homeData.ageController.text.trim(),
    );
    if (!context.mounted) return;

    String? error;
    switch (result) {
      case UserValidationResult.notExists:
      case UserValidationResult.existsAndValidOwner:
        await homeData.addUserDataToDB();
        if (!context.mounted || !drawerContext.mounted) return;
        Navigator.pop(dialogContext);
        await homeData.routeFromDrawer(drawerContext, const ChatScreen());
        return;
      case UserValidationResult.existsButInvalidCountry:
        error = l10n.userExistsInvalidCity;
      case UserValidationResult.existsNumber:
        error = l10n.userExistsPhone;
      case UserValidationResult.existsName:
        error = l10n.userExistsName;
    }
    if (!context.mounted) return;
    Utilities().showCustomSnack(
      context,
      backgroundColor: AppColors.red,
      topPosition: true,
      txt: error,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppDialog(
      icon: Icons.person_add_alt_1_rounded,
      title: l10n.enterYourData,
      content: SingleChildScrollView(
        child: Form(
          key: homeData.formKeyUserData,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: homeData.nameController,
                hintText: l10n.firstNameHint,
                labelText: l10n.nameLabel,
                containtPaddingRight: 0,
                inputType: TextInputType.text,
                textFieldVaidType: TextFieldValidatorType.name,
              ),
              CustomTextField(
                controller: homeData.phoneController,
                hintText: '01*********',
                labelText: l10n.phoneLabel,
                containtPaddingRight: 0,
                inputType: TextInputType.phone,
                textFieldVaidType: TextFieldValidatorType.phoneNumber,
              ),
              CustomTextField(
                controller: homeData.countryController,
                hintText: l10n.cityHint,
                labelText: l10n.cityLabel,
                containtPaddingRight: 0,
                inputType: TextInputType.text,
                textFieldVaidType: TextFieldValidatorType.displayText,
              ),
              CustomTextField(
                controller: homeData.ageController,
                hintText: l10n.ageHint,
                labelText: l10n.ageLabel,
                containtPaddingRight: 0,
                inputType: TextInputType.number,
                textFieldVaidType: TextFieldValidatorType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Expanded(
          child: CustomButton(
            text: l10n.next,
            height: 50,
            onPressed: () => _submit(context),
          ),
        ),
      ],
    );
  }
}
