import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'سكرو حاسبة'**
  String get appName;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'تمام'**
  String get ok;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @share.
  ///
  /// In ar, this message translates to:
  /// **'مشاركة'**
  String get share;

  /// No description provided for @chooseGameMode.
  ///
  /// In ar, this message translates to:
  /// **'اختر وضع اللعبة'**
  String get chooseGameMode;

  /// No description provided for @modeClassic.
  ///
  /// In ar, this message translates to:
  /// **'كلاسيك\n ( فردي )'**
  String get modeClassic;

  /// No description provided for @modeFriends.
  ///
  /// In ar, this message translates to:
  /// **'صاحب صاحبه\n ( زوجي )'**
  String get modeFriends;

  /// No description provided for @unfinishedGameTitle.
  ///
  /// In ar, this message translates to:
  /// **'لعبة غير مكتملة'**
  String get unfinishedGameTitle;

  /// No description provided for @unfinishedGameBody.
  ///
  /// In ar, this message translates to:
  /// **'عندك لعبة لم تنتهِ، تحب تكمّلها؟'**
  String get unfinishedGameBody;

  /// No description provided for @startNewGame.
  ///
  /// In ar, this message translates to:
  /// **'بدء لعبة جديدة'**
  String get startNewGame;

  /// No description provided for @resume.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get resume;

  /// No description provided for @pressBackAgain.
  ///
  /// In ar, this message translates to:
  /// **'للخروج اضغط مرتين'**
  String get pressBackAgain;

  /// No description provided for @chooseNumberOfPlayers.
  ///
  /// In ar, this message translates to:
  /// **'أختر عدد الاعبيين'**
  String get chooseNumberOfPlayers;

  /// No description provided for @chooseNumberOfTeams.
  ///
  /// In ar, this message translates to:
  /// **'أختر عدد الفرق'**
  String get chooseNumberOfTeams;

  /// No description provided for @enterPlayerNameN.
  ///
  /// In ar, this message translates to:
  /// **'ادخل اسم اللاعب {n}'**
  String enterPlayerNameN(int n);

  /// No description provided for @enterPlayerName.
  ///
  /// In ar, this message translates to:
  /// **'ادخل اسم اللاعب'**
  String get enterPlayerName;

  /// No description provided for @teamFirst.
  ///
  /// In ar, this message translates to:
  /// **'الفريق الأول'**
  String get teamFirst;

  /// No description provided for @teamSecond.
  ///
  /// In ar, this message translates to:
  /// **'الفريق الثاني'**
  String get teamSecond;

  /// No description provided for @teamThird.
  ///
  /// In ar, this message translates to:
  /// **'الفريق الثالث'**
  String get teamThird;

  /// No description provided for @teamFourth.
  ///
  /// In ar, this message translates to:
  /// **'الفريق الرابع'**
  String get teamFourth;

  /// No description provided for @recentPlayers.
  ///
  /// In ar, this message translates to:
  /// **'لاعبون سابقون'**
  String get recentPlayers;

  /// No description provided for @results.
  ///
  /// In ar, this message translates to:
  /// **'النتائج'**
  String get results;

  /// No description provided for @warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get warning;

  /// No description provided for @confirmResetRound.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إعادة بدأ الجولة؟'**
  String get confirmResetRound;

  /// No description provided for @gameOver.
  ///
  /// In ar, this message translates to:
  /// **'انتهت اللعبة 🎉'**
  String get gameOver;

  /// No description provided for @winnerLabel.
  ///
  /// In ar, this message translates to:
  /// **'👑 الفائز: {names}'**
  String winnerLabel(String names);

  /// No description provided for @loserLabel.
  ///
  /// In ar, this message translates to:
  /// **'😅 الخاسر: {names}'**
  String loserLabel(String names);

  /// No description provided for @andJoin.
  ///
  /// In ar, this message translates to:
  /// **' و '**
  String get andJoin;

  /// No description provided for @roundsFinished.
  ///
  /// In ar, this message translates to:
  /// **'انتهت الجولات'**
  String get roundsFinished;

  /// No description provided for @roundNumber.
  ///
  /// In ar, this message translates to:
  /// **'الجولة رقم {n}'**
  String roundNumber(int n);

  /// No description provided for @undo.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get undo;

  /// No description provided for @saveHint.
  ///
  /// In ar, this message translates to:
  /// **'الان يمكنك حفظ الجولة واستكمالها لاحقا'**
  String get saveHint;

  /// No description provided for @saveResult.
  ///
  /// In ar, this message translates to:
  /// **'💾 حفظ النتيجة'**
  String get saveResult;

  /// No description provided for @resetRound.
  ///
  /// In ar, this message translates to:
  /// **'اعادة بدأ الجولة'**
  String get resetRound;

  /// No description provided for @shareResult.
  ///
  /// In ar, this message translates to:
  /// **'📲 مشاركة النتيجة'**
  String get shareResult;

  /// No description provided for @shareNeed4.
  ///
  /// In ar, this message translates to:
  /// **'لمشاركة النتائج يجب ادخال 4 جولات على الاقل'**
  String get shareNeed4;

  /// No description provided for @shareText.
  ///
  /// In ar, this message translates to:
  /// **'📸 شوف نتيجتي! من تطبيق سكرو حاسبة'**
  String get shareText;

  /// No description provided for @previewTitle.
  ///
  /// In ar, this message translates to:
  /// **'📸 معاينة الصورة'**
  String get previewTitle;

  /// No description provided for @teamTotal.
  ///
  /// In ar, this message translates to:
  /// **'المجموع: {total}'**
  String teamTotal(int total);

  /// No description provided for @shareCardTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة اللعبة'**
  String get shareCardTitle;

  /// No description provided for @scoreDialogEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل نتيجة الاعب {name} المضافة أخيراً'**
  String scoreDialogEdit(String name);

  /// No description provided for @scoreDialogAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة نتيجة الاعب {name} في الجولة'**
  String scoreDialogAdd(String name);

  /// No description provided for @times2.
  ///
  /// In ar, this message translates to:
  /// **' 2 x احسب النتيجة '**
  String get times2;

  /// No description provided for @times4.
  ///
  /// In ar, this message translates to:
  /// **' 4 x احسب النتيجة '**
  String get times4;

  /// No description provided for @screwZero.
  ///
  /// In ar, this message translates to:
  /// **' سكرو (0) '**
  String get screwZero;

  /// No description provided for @cannotEditWarning.
  ///
  /// In ar, this message translates to:
  /// **'انتبه لا يمكن التعديل على النتيجة'**
  String get cannotEditWarning;

  /// No description provided for @roundSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ الجولة'**
  String get roundSaved;

  /// No description provided for @roundSaveFailed.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر حفظ الجولة'**
  String get roundSaveFailed;

  /// No description provided for @statsTitle.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات اللاعبين'**
  String get statsTitle;

  /// No description provided for @statsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحميل الإحصائيات'**
  String get statsLoadError;

  /// No description provided for @statsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إحصائيات بعد.\nأكمل جولة واحدة واحفظها من لوحة النتائج وستظهر هنا.'**
  String get statsEmpty;

  /// No description provided for @bestWinRate.
  ///
  /// In ar, this message translates to:
  /// **'أعلى نسبة فوز'**
  String get bestWinRate;

  /// No description provided for @mostLosses.
  ///
  /// In ar, this message translates to:
  /// **'أكثر خسارة'**
  String get mostLosses;

  /// No description provided for @winRate.
  ///
  /// In ar, this message translates to:
  /// **'نسبة الفوز'**
  String get winRate;

  /// No description provided for @played.
  ///
  /// In ar, this message translates to:
  /// **'لعب'**
  String get played;

  /// No description provided for @wins.
  ///
  /// In ar, this message translates to:
  /// **'فوز'**
  String get wins;

  /// No description provided for @lossesLabel.
  ///
  /// In ar, this message translates to:
  /// **'خسارة'**
  String get lossesLabel;

  /// No description provided for @avgScore.
  ///
  /// In ar, this message translates to:
  /// **'متوسط النقاط'**
  String get avgScore;

  /// No description provided for @winRateSemantics.
  ///
  /// In ar, this message translates to:
  /// **'{name}: نسبة الفوز {percent} بالمئة'**
  String winRateSemantics(String name, int percent);

  /// No description provided for @onb1Title.
  ///
  /// In ar, this message translates to:
  /// **'احسب نقاط سكرو بسهولة'**
  String get onb1Title;

  /// No description provided for @onb1Body.
  ///
  /// In ar, this message translates to:
  /// **'اختر وضع اللعب: فردي كلاسيك أو فرق (زوجي)، واكتب أسماء اللاعبين وابدأ.'**
  String get onb1Body;

  /// No description provided for @onb2Title.
  ///
  /// In ar, this message translates to:
  /// **'سجّل كل جولة بلمسة'**
  String get onb2Title;

  /// No description provided for @onb2Body.
  ///
  /// In ar, this message translates to:
  /// **'أدخل نتيجة كل لاعب، واضرب في 2 أو 4 عند الحاجة، وتراجع عن أي خطأ بزر \"تراجع\". الأقل نقاطًا يفوز.'**
  String get onb2Body;

  /// No description provided for @onb3Title.
  ///
  /// In ar, this message translates to:
  /// **'لعبتك محفوظة وإحصائياتك جاهزة'**
  String get onb3Title;

  /// No description provided for @onb3Body.
  ///
  /// In ar, this message translates to:
  /// **'تُحفظ اللعبة الجارية تلقائيًا لتكمّلها لاحقًا، وتتابع نسب الفوز، وتشارك النتيجة كصورة أنيقة.'**
  String get onb3Body;

  /// No description provided for @startPlaying.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ اللعب'**
  String get startPlaying;

  /// No description provided for @drawerGreeting.
  ///
  /// In ar, this message translates to:
  /// **'آهلا بيك يا صديقي'**
  String get drawerGreeting;

  /// No description provided for @prayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimes;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'الاشعارات'**
  String get notifications;

  /// No description provided for @rules.
  ///
  /// In ar, this message translates to:
  /// **'قوانين اللعبة'**
  String get rules;

  /// No description provided for @history.
  ///
  /// In ar, this message translates to:
  /// **'الجولات السابقة'**
  String get history;

  /// No description provided for @statsMenu.
  ///
  /// In ar, this message translates to:
  /// **'إحصائيات اللاعبين'**
  String get statsMenu;

  /// No description provided for @video.
  ///
  /// In ar, this message translates to:
  /// **'فيديو شرح اللعبة'**
  String get video;

  /// No description provided for @sharedResults.
  ///
  /// In ar, this message translates to:
  /// **'مشاركات نتائج الاخرين'**
  String get sharedResults;

  /// No description provided for @contactUs.
  ///
  /// In ar, this message translates to:
  /// **'للاقتراحات والتواصل معنا'**
  String get contactUs;

  /// No description provided for @publicChat.
  ///
  /// In ar, this message translates to:
  /// **'محادثة عامة'**
  String get publicChat;

  /// No description provided for @blockedUsers.
  ///
  /// In ar, this message translates to:
  /// **'المستخدمون المحظورون'**
  String get blockedUsers;

  /// No description provided for @rateUs.
  ///
  /// In ar, this message translates to:
  /// **'⭐ قيمنا'**
  String get rateUs;

  /// No description provided for @lightMode.
  ///
  /// In ar, this message translates to:
  /// **'☀️ الوضع الفاتح'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'🌙 الوضع الداكن'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'🌐 English'**
  String get language;

  /// No description provided for @enterYourData.
  ///
  /// In ar, this message translates to:
  /// **'ادخل بياناتك'**
  String get enterYourData;

  /// No description provided for @firstNameHint.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الاول'**
  String get firstNameHint;

  /// No description provided for @nameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم'**
  String get nameLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الموبايل'**
  String get phoneLabel;

  /// No description provided for @cityHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدينة أو المحافظة'**
  String get cityHint;

  /// No description provided for @cityLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدينة'**
  String get cityLabel;

  /// No description provided for @ageHint.
  ///
  /// In ar, this message translates to:
  /// **'عندك كام سنة'**
  String get ageHint;

  /// No description provided for @ageLabel.
  ///
  /// In ar, this message translates to:
  /// **'العمر'**
  String get ageLabel;

  /// No description provided for @chatUnavailableTitle.
  ///
  /// In ar, this message translates to:
  /// **'غير متاح'**
  String get chatUnavailableTitle;

  /// No description provided for @chatUnavailableBody.
  ///
  /// In ar, this message translates to:
  /// **'الدخول للشات غير متاح حاليًا'**
  String get chatUnavailableBody;

  /// No description provided for @dontLetGameDistract.
  ///
  /// In ar, this message translates to:
  /// **'🌙 لا تجعل اللعبة تلهيك عن الصلاة 🌙'**
  String get dontLetGameDistract;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @noSpecialChars.
  ///
  /// In ar, this message translates to:
  /// **'لا يجب ان يحتوي علي حروف خاصة'**
  String get noSpecialChars;

  /// No description provided for @invalidPhone.
  ///
  /// In ar, this message translates to:
  /// **'يجب ان يكون رقم موبايل صحيح'**
  String get invalidPhone;

  /// No description provided for @nameTooShort.
  ///
  /// In ar, this message translates to:
  /// **'عدد الحروف الاسم قصيرة'**
  String get nameTooShort;

  /// No description provided for @nameTooLong.
  ///
  /// In ar, this message translates to:
  /// **'عدد حروف الكلمه كبيرة'**
  String get nameTooLong;

  /// No description provided for @textTooShort.
  ///
  /// In ar, this message translates to:
  /// **'عدد حروف الكلمه قصيرة'**
  String get textTooShort;

  /// No description provided for @reportMessage.
  ///
  /// In ar, this message translates to:
  /// **'إبلاغ عن الرسالة'**
  String get reportMessage;

  /// No description provided for @blockUserN.
  ///
  /// In ar, this message translates to:
  /// **'حظر {name}'**
  String blockUserN(String name);

  /// No description provided for @userExistsInvalidCity.
  ///
  /// In ar, this message translates to:
  /// **'هذه البيانات مسجلة بالفعل، يرجى إدخال المدينة كما كانت مسجلة سابقًا'**
  String get userExistsInvalidCity;

  /// No description provided for @userExistsPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مسجل بالفعل، يرجى إدخال الأسم والمدينة كما كانت مسجلة سابقًا'**
  String get userExistsPhone;

  /// No description provided for @userExistsName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم مسجل بالفعل، يرجى إدخال رقم الهاتف والمدينة لو كانت مسجلة مسبقًا او ادخل اسم اخر'**
  String get userExistsName;

  /// No description provided for @historyTitle.
  ///
  /// In ar, this message translates to:
  /// **'الجولات السابقة'**
  String get historyTitle;

  /// No description provided for @historyEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجلات سابقة'**
  String get historyEmpty;

  /// No description provided for @gameN.
  ///
  /// In ar, this message translates to:
  /// **'الجولة {n}'**
  String gameN(int n);

  /// No description provided for @lowestScoreWinner.
  ///
  /// In ar, this message translates to:
  /// **'({name}) صاحب أقل سكور'**
  String lowestScoreWinner(String name);

  /// No description provided for @clearAllWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف جميع السجلات'**
  String get clearAllWarning;

  /// No description provided for @deleteGameWarning.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف الجولة رقم {n}'**
  String deleteGameWarning(int n);

  /// No description provided for @contactTitle.
  ///
  /// In ar, this message translates to:
  /// **'للتواصل وتقديم الاقتراحات'**
  String get contactTitle;

  /// No description provided for @contactIntro.
  ///
  /// In ar, this message translates to:
  /// **'يمكنك محادثتنا للأسئلة والاستفسارات من خلال'**
  String get contactIntro;

  /// No description provided for @contactNote.
  ///
  /// In ar, this message translates to:
  /// **'نحن لا نبيع اللعبة ولكن يمكنك الارسال لمساعدتنا بتحسين التطبيق ومعرفة اخر التطبيقات'**
  String get contactNote;

  /// No description provided for @notificationsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات حالياً'**
  String get notificationsEmpty;

  /// No description provided for @notificationHidden.
  ///
  /// In ar, this message translates to:
  /// **' ✅ تم اخفاء الاشعار '**
  String get notificationHidden;

  /// No description provided for @deleteNotificationQuestion.
  ///
  /// In ar, this message translates to:
  /// **'! هل تريد حذف الاشعار'**
  String get deleteNotificationQuestion;

  /// No description provided for @videoTitle.
  ///
  /// In ar, this message translates to:
  /// **'شرح قواعد اللعبة'**
  String get videoTitle;

  /// No description provided for @sharedTitle.
  ///
  /// In ar, this message translates to:
  /// **'مشاركات الاخرين'**
  String get sharedTitle;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'الأمس'**
  String get yesterday;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم الحذف بنجاح ✓'**
  String get deletedSuccessfully;

  /// No description provided for @allResultsShown.
  ///
  /// In ar, this message translates to:
  /// **'تم عرض جميع النتائج'**
  String get allResultsShown;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteShare.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف هذه المشاركة؟'**
  String get confirmDeleteShare;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @noSharesYet.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مشاركات حالياً'**
  String get noSharesYet;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديث إجباري'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateBody.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تحديث التطبيق للإصدار {version} للاستمرار في استخدام جميع المميزات.'**
  String forceUpdateBody(String version);

  /// No description provided for @updateNow.
  ///
  /// In ar, this message translates to:
  /// **'تحديث الآن'**
  String get updateNow;

  /// No description provided for @newVersionAvailable.
  ///
  /// In ar, this message translates to:
  /// **'إصدار جديد ({version}) متاح 🎉\nجرّب أحدث المميزات الآن!'**
  String newVersionAvailable(String version);

  /// No description provided for @update.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get update;

  /// No description provided for @splashSalawat.
  ///
  /// In ar, this message translates to:
  /// **'صلي على النبي'**
  String get splashSalawat;

  /// No description provided for @weeklyReminderOn.
  ///
  /// In ar, this message translates to:
  /// **'🔔 تذكير أسبوعي بلعبة: مفعّل'**
  String get weeklyReminderOn;

  /// No description provided for @weeklyReminderOff.
  ///
  /// In ar, this message translates to:
  /// **'🔕 تذكير أسبوعي بلعبة: متوقف'**
  String get weeklyReminderOff;

  /// No description provided for @reminderTitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت لعبة سكرو! 🃏'**
  String get reminderTitle;

  /// No description provided for @reminderBody.
  ///
  /// In ar, this message translates to:
  /// **'اجمع أصحابك والعبوا جولة وسجّلوا النتيجة في التطبيق.'**
  String get reminderBody;

  /// No description provided for @reminderEnabled.
  ///
  /// In ar, this message translates to:
  /// **'تم تفعيل التذكير الأسبوعي (الجمعة 8 مساءً)'**
  String get reminderEnabled;

  /// No description provided for @reminderDisabled.
  ///
  /// In ar, this message translates to:
  /// **'تم إيقاف التذكير الأسبوعي'**
  String get reminderDisabled;

  /// No description provided for @reminderPermission.
  ///
  /// In ar, this message translates to:
  /// **'فعّل صلاحية الإشعارات من إعدادات الجهاز أولًا'**
  String get reminderPermission;

  /// No description provided for @tournamentMenu.
  ///
  /// In ar, this message translates to:
  /// **'🏆 بطولة الأصدقاء'**
  String get tournamentMenu;

  /// No description provided for @tournamentTitle.
  ///
  /// In ar, this message translates to:
  /// **'بطولة الأصدقاء'**
  String get tournamentTitle;

  /// No description provided for @tournamentNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'اسم البطولة'**
  String get tournamentNameLabel;

  /// No description provided for @tournamentPlayersLabel.
  ///
  /// In ar, this message translates to:
  /// **'اللاعبون'**
  String get tournamentPlayersLabel;

  /// No description provided for @tournamentPlayersHint.
  ///
  /// In ar, this message translates to:
  /// **'اكتب الأسماء مفصولة بفاصلة (من 2 إلى 8 لاعبين)'**
  String get tournamentPlayersHint;

  /// No description provided for @tournamentStart.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ البطولة'**
  String get tournamentStart;

  /// No description provided for @tournamentInvalidPlayers.
  ///
  /// In ar, this message translates to:
  /// **'أدخل من 2 إلى 8 لاعبين بأسماء مختلفة'**
  String get tournamentInvalidPlayers;

  /// No description provided for @tournamentAddGame.
  ///
  /// In ar, this message translates to:
  /// **'إضافة نتيجة لعبة'**
  String get tournamentAddGame;

  /// No description provided for @tournamentGameResultTitle.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة اللعبة {n}'**
  String tournamentGameResultTitle(int n);

  /// No description provided for @tournamentSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get tournamentSave;

  /// No description provided for @tournamentRemoveLast.
  ///
  /// In ar, this message translates to:
  /// **'حذف آخر لعبة'**
  String get tournamentRemoveLast;

  /// No description provided for @tournamentEnd.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء البطولة'**
  String get tournamentEnd;

  /// No description provided for @tournamentEndConfirm.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف البطولة ونتائجها. متأكد؟'**
  String get tournamentEndConfirm;

  /// No description provided for @tournamentPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقطة'**
  String get tournamentPoints;

  /// No description provided for @tournamentRulesNote.
  ///
  /// In ar, this message translates to:
  /// **'في كل لعبة: الأقل نقاطًا 3 نقاط، والثاني 2، والثالث 1.'**
  String get tournamentRulesNote;

  /// No description provided for @tournamentGamesPlayed.
  ///
  /// In ar, this message translates to:
  /// **'عدد الألعاب: {n}'**
  String tournamentGamesPlayed(int n);

  /// No description provided for @tournamentInvalidScore.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقمًا صحيحًا'**
  String get tournamentInvalidScore;

  /// No description provided for @addScoreSemantic.
  ///
  /// In ar, this message translates to:
  /// **'إضافة نتيجة {name}'**
  String addScoreSemantic(String name);

  /// No description provided for @editScoreSemantic.
  ///
  /// In ar, this message translates to:
  /// **'تعديل آخر نتيجة {name}'**
  String editScoreSemantic(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
