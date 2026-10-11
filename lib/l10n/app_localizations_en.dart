// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Screw Calculator';

  @override
  String get next => 'Next';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get skip => 'Skip';

  @override
  String get close => 'Close';

  @override
  String get share => 'Share';

  @override
  String get chooseGameMode => 'Choose game mode';

  @override
  String get modeClassic => 'Classic\n ( Solo )';

  @override
  String get modeFriends => 'Teams\n ( Pairs )';

  @override
  String get unfinishedGameTitle => 'Unfinished game';

  @override
  String get unfinishedGameBody => 'You have an unfinished game. Continue it?';

  @override
  String get startNewGame => 'Start a new game';

  @override
  String get resume => 'Resume';

  @override
  String get pressBackAgain => 'Press back again to exit';

  @override
  String get chooseNumberOfPlayers => 'Choose number of players';

  @override
  String get chooseNumberOfTeams => 'Choose number of teams';

  @override
  String enterPlayerNameN(int n) {
    return 'Enter player $n name';
  }

  @override
  String get enterPlayerName => 'Enter player name';

  @override
  String get teamFirst => 'Team 1';

  @override
  String get teamSecond => 'Team 2';

  @override
  String get teamThird => 'Team 3';

  @override
  String get teamFourth => 'Team 4';

  @override
  String get recentPlayers => 'Recent players';

  @override
  String get results => 'Results';

  @override
  String get warning => 'Warning';

  @override
  String get confirmResetRound => 'Do you want to restart the game?';

  @override
  String get gameOver => 'Game over 🎉';

  @override
  String winnerLabel(String names) {
    return '👑 Winner: $names';
  }

  @override
  String loserLabel(String names) {
    return '😅 Loser: $names';
  }

  @override
  String get andJoin => ' & ';

  @override
  String get roundsFinished => 'All rounds finished';

  @override
  String roundNumber(int n) {
    return 'Round $n';
  }

  @override
  String get undo => 'Undo';

  @override
  String get saveHint => 'You can save this game and continue it later';

  @override
  String get saveResult => '💾 Save result';

  @override
  String get resetRound => 'Restart game';

  @override
  String get shareResult => '📲 Share result';

  @override
  String get shareNeed4 => 'Enter at least 4 rounds to share the results';

  @override
  String get shareText =>
      '📸 Check out my result! From the Screw Calculator app';

  @override
  String get previewTitle => '📸 Image preview';

  @override
  String teamTotal(int total) {
    return 'Total: $total';
  }

  @override
  String get shareCardTitle => 'Game result';

  @override
  String scoreDialogEdit(String name) {
    return 'Edit the last score of $name';
  }

  @override
  String scoreDialogAdd(String name) {
    return 'Add $name\'s score for this round';
  }

  @override
  String get times2 => ' 2 x Calculate ';

  @override
  String get times4 => ' 4 x Calculate ';

  @override
  String get screwZero => ' Screw (0) ';

  @override
  String get cannotEditWarning => 'Careful: this score can no longer be edited';

  @override
  String get roundSaved => 'Game saved';

  @override
  String get roundSaveFailed => 'Could not save the game';

  @override
  String get statsTitle => 'Player statistics';

  @override
  String get statsLoadError => 'Could not load statistics';

  @override
  String get statsEmpty =>
      'No statistics yet.\nFinish a game and save it from the results screen to see it here.';

  @override
  String get bestWinRate => 'Best win rate';

  @override
  String get mostLosses => 'Most losses';

  @override
  String get winRate => 'Win rate';

  @override
  String get played => 'Played';

  @override
  String get wins => 'Wins';

  @override
  String get lossesLabel => 'Losses';

  @override
  String get avgScore => 'Avg. score';

  @override
  String winRateSemantics(String name, int percent) {
    return '$name: win rate $percent percent';
  }

  @override
  String get onb1Title => 'Score your Screw games easily';

  @override
  String get onb1Body =>
      'Pick a mode: classic solo or teams (pairs), enter the players and start.';

  @override
  String get onb2Title => 'Record every round in a tap';

  @override
  String get onb2Body =>
      'Enter each player\'s score, multiply by 2 or 4 when needed, and undo any mistake with the \"Undo\" button. Lowest score wins.';

  @override
  String get onb3Title => 'Your game is saved, your stats are ready';

  @override
  String get onb3Body =>
      'The current game is saved automatically so you can continue later, track win rates and share the result as a neat image.';

  @override
  String get startPlaying => 'Start playing';

  @override
  String get drawerGreeting => 'Welcome, friend';

  @override
  String get prayerTimes => 'Prayer times';

  @override
  String get notifications => 'Notifications';

  @override
  String get rules => 'Game rules';

  @override
  String get history => 'Previous games';

  @override
  String get statsMenu => 'Player statistics';

  @override
  String get video => 'How-to-play video';

  @override
  String get sharedResults => 'Others\' shared results';

  @override
  String get contactUs => 'Suggestions & contact us';

  @override
  String get publicChat => 'Public chat';

  @override
  String get blockedUsers => 'Blocked users';

  @override
  String get rateUs => '⭐ Rate us';

  @override
  String get lightMode => '☀️ Light mode';

  @override
  String get darkMode => '🌙 Dark mode';

  @override
  String get language => '🌐 العربية';

  @override
  String get enterYourData => 'Enter your details';

  @override
  String get firstNameHint => 'First name';

  @override
  String get nameLabel => 'Name';

  @override
  String get phoneLabel => 'Mobile number';

  @override
  String get cityHint => 'City or governorate';

  @override
  String get cityLabel => 'City';

  @override
  String get ageHint => 'How old are you';

  @override
  String get ageLabel => 'Age';

  @override
  String get chatUnavailableTitle => 'Unavailable';

  @override
  String get chatUnavailableBody => 'Chat is currently unavailable';

  @override
  String get dontLetGameDistract =>
      '🌙 Don\'t let the game distract you from prayer 🌙';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get noSpecialChars => 'Must not contain special characters';

  @override
  String get invalidPhone => 'Enter a valid mobile number';

  @override
  String get nameTooShort => 'Name is too short';

  @override
  String get nameTooLong => 'Text is too long';

  @override
  String get textTooShort => 'Text is too short';

  @override
  String get reportMessage => 'Report message';

  @override
  String blockUserN(String name) {
    return 'Block $name';
  }

  @override
  String get userExistsInvalidCity =>
      'This data is already registered. Please enter the city exactly as registered before.';

  @override
  String get userExistsPhone =>
      'This phone number is already registered. Please enter the name and city as registered before.';

  @override
  String get userExistsName =>
      'This name is already registered. Enter your phone number and city if you registered before, or choose another name.';

  @override
  String get historyTitle => 'Previous games';

  @override
  String get historyEmpty => 'No previous games';

  @override
  String gameN(int n) {
    return 'Game $n';
  }

  @override
  String lowestScoreWinner(String name) {
    return '($name) has the lowest score';
  }

  @override
  String get clearAllWarning => 'All records will be deleted';

  @override
  String deleteGameWarning(int n) {
    return 'Game $n will be deleted';
  }

  @override
  String get contactTitle => 'Contact & suggestions';

  @override
  String get contactIntro =>
      'You can chat with us for questions and inquiries via';

  @override
  String get contactNote =>
      'We do not sell the game, but you can message us to help improve the app and learn about our latest apps';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications right now';

  @override
  String get notificationHidden => ' ✅ Notification hidden ';

  @override
  String get deleteNotificationQuestion => 'Delete this notification?';

  @override
  String get videoTitle => 'Game rules video';

  @override
  String get sharedTitle => 'Shared results';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get deletedSuccessfully => 'Deleted successfully ✓';

  @override
  String get allResultsShown => 'All results shown';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String get confirmDeleteShare =>
      'Are you sure you want to delete this share?';

  @override
  String get delete => 'Delete';

  @override
  String get noSharesYet => 'No shares yet';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String forceUpdateBody(String version) {
    return 'Please update the app to version $version to keep using all features.';
  }

  @override
  String get updateNow => 'Update now';

  @override
  String newVersionAvailable(String version) {
    return 'A new version ($version) is available 🎉\nTry the latest features now!';
  }

  @override
  String get update => 'Update';

  @override
  String get splashSalawat => 'Send blessings upon the Prophet ﷺ';

  @override
  String get weeklyReminderOn => '🔔 Weekly game reminder: on';

  @override
  String get weeklyReminderOff => '🔕 Weekly game reminder: off';

  @override
  String get reminderTitle => 'Time for a Screw game! 🃏';

  @override
  String get reminderBody =>
      'Gather your friends for a round and score it in the app.';

  @override
  String get reminderEnabled => 'Weekly reminder enabled (Fridays 8 PM)';

  @override
  String get reminderDisabled => 'Weekly reminder disabled';

  @override
  String get reminderPermission =>
      'Please enable notifications in device settings first';

  @override
  String get tournamentMenu => '🏆 Friends tournament';

  @override
  String get tournamentTitle => 'Friends tournament';

  @override
  String get tournamentNameLabel => 'Tournament name';

  @override
  String get tournamentPlayersLabel => 'Players';

  @override
  String get tournamentPlayersHint =>
      'Type names separated by commas (2 to 8 players)';

  @override
  String get tournamentStart => 'Start tournament';

  @override
  String get tournamentInvalidPlayers =>
      'Enter 2 to 8 players with different names';

  @override
  String get tournamentAddGame => 'Add a game result';

  @override
  String tournamentGameResultTitle(int n) {
    return 'Game $n result';
  }

  @override
  String get tournamentSave => 'Save';

  @override
  String get tournamentRemoveLast => 'Remove last game';

  @override
  String get tournamentEnd => 'End tournament';

  @override
  String get tournamentEndConfirm =>
      'The tournament and its results will be deleted. Sure?';

  @override
  String get tournamentPoints => 'pts';

  @override
  String get tournamentRulesNote =>
      'In each game: lowest score gets 3 points, second 2, third 1.';

  @override
  String tournamentGamesPlayed(int n) {
    return 'Games played: $n';
  }

  @override
  String get tournamentInvalidScore => 'Enter a valid number';

  @override
  String addScoreSemantic(String name) {
    return 'Add score for $name';
  }

  @override
  String editScoreSemantic(String name) {
    return 'Edit last score of $name';
  }
}
