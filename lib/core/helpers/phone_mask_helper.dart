class PhoneMaskHelper {
  static String maskPhoneNumbers(String text) {
    final RegExp phoneRegex = RegExp(
      r'(?:\+|00)?\d{1,3}[\s\-]?\(?\d{1,5}\)?[\s\-]?\d{1,5}[\s\-]?\d{1,5}',
    );
    return text.replaceAllMapped(phoneRegex, (match) {
      final phone = match.group(0)!;
      if (phone.length <= 4) return phone;
      return '${phone.substring(0, 2)}${'*' * (phone.length - 4)}${phone.substring(phone.length - 2)}';
    });
  }

  // String maskPhoneNumbers(String text) {
  //   // More robust phone detection
  //   final RegExp phoneRegex = RegExp(
  //     r'(?:\+?[0-9]{1,3}[-.\s]?)?(?:\([0-9]{2,5}\)|[0-9]{2,5})[-.\s]?[0-9]{3,5}[-.\s]?[0-9]{3,5}',
  //   );
  //   return text.replaceAllMapped(phoneRegex, (match) {
  //     final phone = match.group(0)!;
  //     if (phone.length <= 4) return phone;
  //     final visible = phone.length > 6 ? 3 : 2;
  //     return '${phone.substring(0, visible)}${'*' * (phone.length - visible * 2)}${phone.substring(phone.length - visible)}';
  //   });
  // }

  static bool isAdminPhone(String phone) {
    return phone == '01149504892' || phone == '01556464892';
  }

  static bool canDeleteMessage({
    required String messageSenderPhone,
    required String currentUserPhone,
    required String currentUserName,
  }) {
    return messageSenderPhone == currentUserPhone ||
        currentUserPhone == '01149504892' ||
        currentUserPhone == '01556464892' ||
        currentUserName == 'الآدمن';
  }
}
