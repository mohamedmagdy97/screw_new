import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screw_calculator/core/models/player_model.dart';
import 'package:screw_calculator/core/theme/app_theme.dart';
import 'package:screw_calculator/core/utils/validation_form.dart';
import 'package:screw_calculator/core/widgets/custom_button.dart';
import 'package:screw_calculator/core/widgets/custom_text.dart';
import 'package:screw_calculator/core/widgets/custom_text_field.dart';
import 'package:screw_calculator/features/dashboard/presentation/cubit/dashboard_cubit.dart';

/// يعرض [ScoreInputDialog] بانتقال تكبير/تلاشٍ ناعم.
Future<void> showScoreInputDialog({
  required BuildContext context,
  required DashboardCubit cubit,
  required PlayerModel player,
  bool isEdit = false,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, _, child) {
      final curved = Curves.easeInOut.transform(anim.value);
      return Transform.scale(
        scale: curved,
        child: Opacity(
          opacity: anim.value,
          child: ScoreInputDialog(
            cubit: cubit,
            player: player,
            isEdit: isEdit,
          ),
        ),
      );
    },
  );
}

/// نافذة إدخال/تعديل نتيجة لاعب في جولة.
///
/// تستبدل ~617 سطرًا من المنطق المكرّر في [AddValueDialog]/[EditValueDialog]
/// بمنطق موحّد يعتمد على [PlayerModel.addRoundScore]/[editLastRoundScore]
/// عبر [DashboardCubit].
class ScoreInputDialog extends StatefulWidget {
  const ScoreInputDialog({
    super.key,
    required this.cubit,
    required this.player,
    this.isEdit = false,
  });

  final DashboardCubit cubit;
  final PlayerModel player;
  final bool isEdit;

  @override
  State<ScoreInputDialog> createState() => _ScoreInputDialogState();
}

class _ScoreInputDialogState extends State<ScoreInputDialog> {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(int multiplier, {bool forceAdd = false}) {
    if (!_formKey.currentState!.validate()) return;
    final value = (int.tryParse(_controller.text.trim()) ?? 0) * multiplier;
    widget.cubit.applyScore(
      widget.player,
      value,
      edit: forceAdd ? false : widget.isEdit,
    );
    Navigator.pop(context);
  }

  void _submitScrew() {
    widget.cubit.applyScore(widget.player, 0, edit: widget.isEdit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final player = widget.player;
    final bool isFinalRound = player.filledRoundsCount == 4;
    final title = widget.isEdit
        ? 'تعديل نتيجة الاعب ${player.name} المضافة أخيراً'
        : 'إضافة نتيجة الاعب ${player.name} في الجولة';

    return AlertDialog(
      title: Directionality(
        textDirection: TextDirection.rtl,
        child: CustomText(
          text: title,
          fontSize: 14.sp,
          textAlign: TextAlign.center,
          color: AppColors.black,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _controller,
              hintText: '',
              labelText: '',
              containtPaddingRight: 0,
              inputType: TextInputType.number,
              fillColor: Colors.white,
              textColor: Colors.black,
              fillBorderColor: AppColors.grayy,
              textFieldVaidType: TextFieldValidatorType.number,
            ),
            const SizedBox(height: 16),
            CustomButton(text: 'التالي', onPressed: () => _submit(1)),
            const SizedBox(height: 16),
            CustomButton(
              text: ' 2 x احسب النتيجة ',
              onPressed: () => _submit(2),
            ),
            if (isFinalRound) ...[
              const SizedBox(height: 16),
              CustomButton(
                text: ' 4 x احسب النتيجة ',
                onPressed: () => _submit(4, forceAdd: true),
              ),
            ],
            const SizedBox(height: 16),
            CustomButton(text: ' سكرو (0) ', onPressed: _submitScrew),
            const SizedBox(height: 16),
            if (player.gw4!.isNotEmpty && player.gw5!.isEmpty)
              CustomText(
                text: 'انتبه لا يمكن التعديل على النتيجة',
                fontSize: 14.sp,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
          ],
        ),
      ),
    );
  }
}
