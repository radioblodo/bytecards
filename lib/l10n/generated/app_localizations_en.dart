// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get difficultyTitle => "Difficulty Reviews";

  @override
  String get easyLabel => "Easy";

  @override
  String get mediumLabel => "Medium";

  @override
  String get hardLabel => "Hard";

  @override
  String reviewsOnDate(int count, String date) =>
      '$count review${count == 1 ? "" : "s"} on $date';

  @override
  String noReviewsOnDate(String date) => 'No reviews on $date';

  @override
  String get reviewCalendar => "Review Calendar";

  @override
  String upcomingReviewsAmt(int count) => '$count card(s) due soon.';

  @override
  String get noUpcomingReviews => 'No upcoming reviews scheduled yet';

  @override
  String get upcomingReviews => "Upcoming Reviews";

  @override
  String cardsReviewedToday(int count) => 'You’ve reviewed $count cards today!';

  @override
  String get noCardsReviewedToday => "You've not reviewed any card today.";

  @override
  String get today => "Today";

  @override
  String get apiKeySaved => "API Key Saved";

  @override
  String get failedToOpenLink => "Could not open link";

  @override
  String get save => "Save";

  @override
  String get guideToObtainAPIKey => "🔗 How to get your API key?";

  @override
  String get enterAPIKey => 'Tap to enter API key';

  @override
  String get aiModelAPIKey => 'AI Model API Key';

  @override
  String get saveFlashcard => 'Save Flashcard';

  @override
  String get answer => 'Answer';

  @override
  String get question => 'Question';

  @override
  String get addFlashcard => "Add Flashcard";

  @override
  String get createDeck => 'Create a new deck';

  @override
  String get createDeckButton => 'Create Deck';

  @override
  String get deckName => 'Deck Name';

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

  @override
  String get flashcards => 'flashcards';

  @override
  String get noFlashcardsAvailable => 'No flashcards available.';

  @override
  String get practiceMode => 'Practice Mode';

  @override
  // TODO: implement cardCountsTitle
  String get cardCountsTitle => "Card Counts";

  @override
  String newCards(int count) => 'New: $count';

  @override
  String youngCards(int count) => 'Young: $count';

  @override
  String matureCards(int count) => 'Mature: $count';

  @override
  String get reviewIntervals => "Review Intervals";
}
