// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ByteCards';

  @override
  String get settings => 'Settings';

  @override
  String get home => 'Home';

  @override
  String get homeTitle => 'ByteCards';

  @override
  String get statisticsTitle => 'Study Statistics';

  @override
  String get statistics => 'Statistics';

  @override
  String get reminderFrequency => 'Reminder Frequency';

  @override
  String get language => 'Language';

  @override
  String get appTheme => 'App Theme';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get english => 'English';

  @override
  String get mandarin => 'Mandarin';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System Default';

  @override
  String get noDecksMessage => 'You have no decks yet. Tap + to create one.';

  @override
  String get statisticsDescription =>
      'View your learning progress and statistics.';

  @override
  String get generateFromAI => 'Generate from AI';

  @override
  String get practiceNow => 'Practice Now';

  @override
  String get manuallyAddCards => 'Manually Add Cards';

  @override
  String get cardsAdded => 'Cards Added';

  @override
  String get confirmAddAll => 'Confirm Add All Cards';

  @override
  String get unsupportedFormat => 'Unsupported format. Please use JSON format.';

  @override
  String get parseError => 'Error parsing the response. Please try again.';

  @override
  String get fileReadError =>
      'Error reading file. Please check the file format.';

  @override
  String apiError(String error) => 'An error occurred. Please try again.';

  @override
  String get cancel => 'Cancel';
}
