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
  String get generatedCards => 'Generated Flashcards:';

  @override
  String unsupportedFormat(Object ext) {
    return 'Unsupported format: .$ext';
  }

  @override
  String get fileReadError => 'Error reading file';

  @override
  String get parseError => 'Failed to parse AI response';

  @override
  String apiError(Object code) {
    return 'API error: $code';
  }

  @override
  String get cardsAdded => 'Flashcards added to deck!';

  @override
  String get confirmAddAll => 'Confirm & Add All to Deck';

  @override
  String get cancel => 'Cancel';
}
