import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/l10n/content_direction.dart';
import 'package:screw_calculator/core/utils/validation_form.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/custom_text_field.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

class BuildTeamFields extends StatelessWidget {
  final String teamName;
  final List<TextEditingController> controllers;

  const BuildTeamFields({
    super.key,
    required this.teamName,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: context.readStartCross,
      children: [
        CustomText(
          text: teamName,
          fontSize: 16.sp,
          textAlign: context.readStart,
        ),
        const SizedBox(height: 8),
        ...controllers.map(
          (controller) => CustomTextField(
            controller: controller,
            hintText: '',
            labelText: AppLocalizations.of(context).enterPlayerName,
            containtPaddingRight: 0,
            inputType: TextInputType.text,
            textFieldVaidType: TextFieldValidatorType.displayText,
          ),
        ),
      ],
    );
  }
}
