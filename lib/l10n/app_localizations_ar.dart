// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'سكرو حاسبة';

  @override
  String get next => 'التالي';

  @override
  String get cancel => 'إلغاء';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'تمام';

  @override
  String get skip => 'تخطي';

  @override
  String get close => 'إغلاق';

  @override
  String get share => 'مشاركة';

  @override
  String get chooseGameMode => 'اختر وضع اللعبة';

  @override
  String get modeClassic => 'كلاسيك\n ( فردي )';

  @override
  String get modeFriends => 'صاحب صاحبه\n ( زوجي )';

  @override
  String get unfinishedGameTitle => 'لعبة غير مكتملة';

  @override
  String get unfinishedGameBody => 'عندك لعبة لم تنتهِ، تحب تكمّلها؟';

  @override
  String get startNewGame => 'بدء لعبة جديدة';

  @override
  String get resume => 'متابعة';

  @override
  String get pressBackAgain => 'للخروج اضغط مرتين';

  @override
  String get chooseNumberOfPlayers => 'أختر عدد الاعبيين';

  @override
  String get chooseNumberOfTeams => 'أختر عدد الفرق';

  @override
  String enterPlayerNameN(int n) {
    return 'ادخل اسم اللاعب $n';
  }

  @override
  String get enterPlayerName => 'ادخل اسم اللاعب';

  @override
  String get teamFirst => 'الفريق الأول';

  @override
  String get teamSecond => 'الفريق الثاني';

  @override
  String get teamThird => 'الفريق الثالث';

  @override
  String get teamFourth => 'الفريق الرابع';

  @override
  String get recentPlayers => 'لاعبون سابقون';

  @override
  String get results => 'النتائج';

  @override
  String get warning => 'تحذير';

  @override
  String get confirmResetRound => 'هل تريد إعادة بدأ الجولة؟';

  @override
  String get gameOver => 'انتهت اللعبة 🎉';

  @override
  String winnerLabel(String names) {
    return '👑 الفائز: $names';
  }

  @override
  String loserLabel(String names) {
    return '😅 الخاسر: $names';
  }

  @override
  String get andJoin => ' و ';

  @override
  String get roundsFinished => 'انتهت الجولات';

  @override
  String roundNumber(int n) {
    return 'الجولة رقم $n';
  }

  @override
  String get undo => 'تراجع';

  @override
  String get saveHint => 'الان يمكنك حفظ الجولة واستكمالها لاحقا';

  @override
  String get saveResult => '💾 حفظ النتيجة';

  @override
  String get resetRound => 'اعادة بدأ الجولة';

  @override
  String get shareResult => '📲 مشاركة النتيجة';

  @override
  String get shareNeed4 => 'لمشاركة النتائج يجب ادخال 4 جولات على الاقل';

  @override
  String get shareText => '📸 شوف نتيجتي! من تطبيق سكرو حاسبة';

  @override
  String get previewTitle => '📸 معاينة الصورة';

  @override
  String teamTotal(int total) {
    return 'المجموع: $total';
  }

  @override
  String get shareCardTitle => 'نتيجة اللعبة';

  @override
  String scoreDialogEdit(String name) {
    return 'تعديل نتيجة الاعب $name المضافة أخيراً';
  }

  @override
  String scoreDialogAdd(String name) {
    return 'إضافة نتيجة الاعب $name في الجولة';
  }

  @override
  String get times2 => ' 2 x احسب النتيجة ';

  @override
  String get times4 => ' 4 x احسب النتيجة ';

  @override
  String get screwZero => ' سكرو (0) ';

  @override
  String get cannotEditWarning => 'انتبه لا يمكن التعديل على النتيجة';

  @override
  String get roundSaved => 'تم حفظ الجولة';

  @override
  String get roundSaveFailed => 'تعذّر حفظ الجولة';

  @override
  String get statsTitle => 'إحصائيات اللاعبين';

  @override
  String get statsLoadError => 'تعذّر تحميل الإحصائيات';

  @override
  String get statsEmpty =>
      'لا توجد إحصائيات بعد.\nأكمل جولة واحدة واحفظها من لوحة النتائج وستظهر هنا.';

  @override
  String get bestWinRate => 'أعلى نسبة فوز';

  @override
  String get mostLosses => 'أكثر خسارة';

  @override
  String get winRate => 'نسبة الفوز';

  @override
  String get played => 'لعب';

  @override
  String get wins => 'فوز';

  @override
  String get lossesLabel => 'خسارة';

  @override
  String get avgScore => 'متوسط النقاط';

  @override
  String winRateSemantics(String name, int percent) {
    return '$name: نسبة الفوز $percent بالمئة';
  }

  @override
  String get onb1Title => 'احسب نقاط سكرو بسهولة';

  @override
  String get onb1Body =>
      'اختر وضع اللعب: فردي كلاسيك أو فرق (زوجي)، واكتب أسماء اللاعبين وابدأ.';

  @override
  String get onb2Title => 'سجّل كل جولة بلمسة';

  @override
  String get onb2Body =>
      'أدخل نتيجة كل لاعب، واضرب في 2 أو 4 عند الحاجة، وتراجع عن أي خطأ بزر \"تراجع\". الأقل نقاطًا يفوز.';

  @override
  String get onb3Title => 'لعبتك محفوظة وإحصائياتك جاهزة';

  @override
  String get onb3Body =>
      'تُحفظ اللعبة الجارية تلقائيًا لتكمّلها لاحقًا، وتتابع نسب الفوز، وتشارك النتيجة كصورة أنيقة.';

  @override
  String get startPlaying => 'ابدأ اللعب';

  @override
  String get drawerGreeting => 'آهلا بيك يا صديقي';

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get notifications => 'الاشعارات';

  @override
  String get rules => 'قوانين اللعبة';

  @override
  String get history => 'الجولات السابقة';

  @override
  String get statsMenu => 'إحصائيات اللاعبين';

  @override
  String get video => 'فيديو شرح اللعبة';

  @override
  String get sharedResults => 'مشاركات نتائج الاخرين';

  @override
  String get contactUs => 'للاقتراحات والتواصل معنا';

  @override
  String get publicChat => 'محادثة عامة';

  @override
  String get blockedUsers => 'المستخدمون المحظورون';

  @override
  String get rateUs => '⭐ قيمنا';

  @override
  String get lightMode => '☀️ الوضع الفاتح';

  @override
  String get darkMode => '🌙 الوضع الداكن';

  @override
  String get language => '🌐 English';

  @override
  String get enterYourData => 'ادخل بياناتك';

  @override
  String get firstNameHint => 'الاسم الاول';

  @override
  String get nameLabel => 'الاسم';

  @override
  String get phoneLabel => 'رقم الموبايل';

  @override
  String get cityHint => 'اسم المدينة أو المحافظة';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get ageHint => 'عندك كام سنة';

  @override
  String get ageLabel => 'العمر';

  @override
  String get chatUnavailableTitle => 'غير متاح';

  @override
  String get chatUnavailableBody => 'الدخول للشات غير متاح حاليًا';

  @override
  String get dontLetGameDistract => '🌙 لا تجعل اللعبة تلهيك عن الصلاة 🌙';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get noSpecialChars => 'لا يجب ان يحتوي علي حروف خاصة';

  @override
  String get invalidPhone => 'يجب ان يكون رقم موبايل صحيح';

  @override
  String get nameTooShort => 'عدد الحروف الاسم قصيرة';

  @override
  String get nameTooLong => 'عدد حروف الكلمه كبيرة';

  @override
  String get textTooShort => 'عدد حروف الكلمه قصيرة';

  @override
  String get reportMessage => 'إبلاغ عن الرسالة';

  @override
  String blockUserN(String name) {
    return 'حظر $name';
  }

  @override
  String get userExistsInvalidCity =>
      'هذه البيانات مسجلة بالفعل، يرجى إدخال المدينة كما كانت مسجلة سابقًا';

  @override
  String get userExistsPhone =>
      'رقم الهاتف مسجل بالفعل، يرجى إدخال الأسم والمدينة كما كانت مسجلة سابقًا';

  @override
  String get userExistsName =>
      'الاسم مسجل بالفعل، يرجى إدخال رقم الهاتف والمدينة لو كانت مسجلة مسبقًا او ادخل اسم اخر';

  @override
  String get historyTitle => 'الجولات السابقة';

  @override
  String get historyEmpty => 'لا يوجد سجلات سابقة';

  @override
  String gameN(int n) {
    return 'الجولة $n';
  }

  @override
  String lowestScoreWinner(String name) {
    return '($name) صاحب أقل سكور';
  }

  @override
  String get clearAllWarning => 'سيتم حذف جميع السجلات';

  @override
  String deleteGameWarning(int n) {
    return 'سيتم حذف الجولة رقم $n';
  }

  @override
  String get contactTitle => 'للتواصل وتقديم الاقتراحات';

  @override
  String get contactIntro => 'يمكنك محادثتنا للأسئلة والاستفسارات من خلال';

  @override
  String get contactNote =>
      'نحن لا نبيع اللعبة ولكن يمكنك الارسال لمساعدتنا بتحسين التطبيق ومعرفة اخر التطبيقات';

  @override
  String get notificationsTitle => 'الإشعارات';

  @override
  String get notificationsEmpty => 'لا توجد إشعارات حالياً';

  @override
  String get notificationHidden => ' ✅ تم اخفاء الاشعار ';

  @override
  String get deleteNotificationQuestion => '! هل تريد حذف الاشعار';

  @override
  String get videoTitle => 'شرح قواعد اللعبة';

  @override
  String get sharedTitle => 'مشاركات الاخرين';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'الأمس';

  @override
  String get deletedSuccessfully => 'تم الحذف بنجاح ✓';

  @override
  String get allResultsShown => 'تم عرض جميع النتائج';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmDeleteShare => 'هل أنت متأكد أنك تريد حذف هذه المشاركة؟';

  @override
  String get delete => 'حذف';

  @override
  String get noSharesYet => 'لا توجد مشاركات حالياً';

  @override
  String get forceUpdateTitle => 'تحديث إجباري';

  @override
  String forceUpdateBody(String version) {
    return 'يرجى تحديث التطبيق للإصدار $version للاستمرار في استخدام جميع المميزات.';
  }

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String newVersionAvailable(String version) {
    return 'إصدار جديد ($version) متاح 🎉\nجرّب أحدث المميزات الآن!';
  }

  @override
  String get update => 'تحديث';

  @override
  String get splashSalawat => 'صلي على النبي';

  @override
  String get weeklyReminderOn => '🔔 تذكير أسبوعي بلعبة: مفعّل';

  @override
  String get weeklyReminderOff => '🔕 تذكير أسبوعي بلعبة: متوقف';

  @override
  String get reminderTitle => 'وقت لعبة سكرو! 🃏';

  @override
  String get reminderBody =>
      'اجمع أصحابك والعبوا جولة وسجّلوا النتيجة في التطبيق.';

  @override
  String get reminderEnabled => 'تم تفعيل التذكير الأسبوعي (الجمعة 8 مساءً)';

  @override
  String get reminderDisabled => 'تم إيقاف التذكير الأسبوعي';

  @override
  String get reminderPermission =>
      'فعّل صلاحية الإشعارات من إعدادات الجهاز أولًا';

  @override
  String get tournamentMenu => '🏆 بطولة الأصدقاء';

  @override
  String get tournamentTitle => 'بطولة الأصدقاء';

  @override
  String get tournamentNameLabel => 'اسم البطولة';

  @override
  String get tournamentPlayersLabel => 'اللاعبون';

  @override
  String get tournamentPlayersHint =>
      'اكتب الأسماء مفصولة بفاصلة (من 2 إلى 8 لاعبين)';

  @override
  String get tournamentStart => 'ابدأ البطولة';

  @override
  String get tournamentInvalidPlayers => 'أدخل من 2 إلى 8 لاعبين بأسماء مختلفة';

  @override
  String get tournamentAddGame => 'إضافة نتيجة لعبة';

  @override
  String tournamentGameResultTitle(int n) {
    return 'نتيجة اللعبة $n';
  }

  @override
  String get tournamentSave => 'حفظ';

  @override
  String get tournamentRemoveLast => 'حذف آخر لعبة';

  @override
  String get tournamentEnd => 'إنهاء البطولة';

  @override
  String get tournamentEndConfirm => 'سيتم حذف البطولة ونتائجها. متأكد؟';

  @override
  String get tournamentPoints => 'نقطة';

  @override
  String get tournamentRulesNote =>
      'في كل لعبة: الأقل نقاطًا 3 نقاط، والثاني 2، والثالث 1.';

  @override
  String tournamentGamesPlayed(int n) {
    return 'عدد الألعاب: $n';
  }

  @override
  String get tournamentInvalidScore => 'أدخل رقمًا صحيحًا';

  @override
  String addScoreSemantic(String name) {
    return 'إضافة نتيجة $name';
  }

  @override
  String editScoreSemantic(String name) {
    return 'تعديل آخر نتيجة $name';
  }
}
