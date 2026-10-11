import 'package:screw_calculator/core/utils/reg_exp.dart';
import 'package:screw_calculator/l10n/app_localizations.dart';

enum TextFieldValidatorType { name, displayText, optional, number, phoneNumber }

String? validation({
  required AppLocalizations l10n,
  required TextFieldValidatorType type,
  required String value,
  required String firstPasswordForConfirm,
}) {
  if (type == TextFieldValidatorType.optional) {
    return null;
  } else if (type == TextFieldValidatorType.displayText) {
    if (value.isEmpty) {
      return l10n.fieldRequired;
    }
    // if (value.length < 2) {
    //   return GlobalWords.short_text.tr;
    // }
  } else if (type == TextFieldValidatorType.number) {
    if (value.isEmpty) {
      return l10n.fieldRequired;
    }

    if (!regExpNumber.hasMatch(value.trim().replaceAll('‎', '')) ||
        value.trim().contains('.') ||
        value.trim().contains(',')) {
      return l10n.noSpecialChars;
    }
  } else if (type == TextFieldValidatorType.phoneNumber) {
    if (value.isEmpty) {
      return l10n.fieldRequired;
    }

    if (value.trim().contains('.') || value.trim().contains(',')) {
      return l10n.noSpecialChars;
    }
    if (!regExpPhoneNumber.hasMatch(value.trim())) {
      return l10n.invalidPhone;
    }
  } else if (type == TextFieldValidatorType.name) {
    if (value.isEmpty) {
      return l10n.fieldRequired;
    }
    if (value.length < 2) {
      return l10n.nameTooShort;
    }
    if (value.length > 20) {
      return l10n.nameTooLong;
    }

    // if (!regExpName.hasMatch(value.trim().replaceAll('‎', ''))) {
    //   return l10n.noSpecialChars;
    // }

    return null;
  } else {
    if (value.isEmpty) {
      return l10n.fieldRequired;
    }
    if (value.length < 2) {
      return l10n.textTooShort;
    }

    return null;
  }
  return null;
}
