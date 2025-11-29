import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_he.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('he'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// The app name
  ///
  /// In en, this message translates to:
  /// **'TripBuddy'**
  String get appTitle;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Morning greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get welcomeGreetingMorning;

  /// Afternoon greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get welcomeGreetingAfternoon;

  /// Evening greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get welcomeGreetingEvening;

  /// Title when no trip is active
  ///
  /// In en, this message translates to:
  /// **'No Active Trip'**
  String get noActiveTrip;

  /// Subtitle when no trip is active
  ///
  /// In en, this message translates to:
  /// **'Start planning your next adventure!'**
  String get startPlanningAdventure;

  /// Button to create a new trip
  ///
  /// In en, this message translates to:
  /// **'Create New Trip'**
  String get createNewTrip;

  /// Section title for quick actions
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Quick action for new trip
  ///
  /// In en, this message translates to:
  /// **'New Trip'**
  String get newTrip;

  /// Quick action for adding expense
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Quick action for AI chat
  ///
  /// In en, this message translates to:
  /// **'AI Chat'**
  String get aiChat;

  /// Section title for recent chats
  ///
  /// In en, this message translates to:
  /// **'Recent Chats'**
  String get recentChats;

  /// Section title for recent expenses
  ///
  /// In en, this message translates to:
  /// **'Recent Expenses'**
  String get recentExpenses;

  /// Link to view all items
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Prompt to start chatting
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with TripBuddy!'**
  String get startConversation;

  /// Button to start new chat
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// Message when no expenses exist
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded yet'**
  String get noExpensesRecorded;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Label for trip dates
  ///
  /// In en, this message translates to:
  /// **'Dates'**
  String get dates;

  /// Message when dates are not set
  ///
  /// In en, this message translates to:
  /// **'Dates not set'**
  String get datesNotSet;

  /// Label for trip duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Generic not set message
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// Label for days until trip starts
  ///
  /// In en, this message translates to:
  /// **'Starts in'**
  String get startsIn;

  /// Label for status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Current status
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Singular day
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// Plural days
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Current day of trip
  ///
  /// In en, this message translates to:
  /// **'Day {current} of {total}'**
  String dayOfTotal(int current, int total);

  /// Title for create trip screen
  ///
  /// In en, this message translates to:
  /// **'Create Trip'**
  String get createTrip;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Label for trip title field
  ///
  /// In en, this message translates to:
  /// **'Trip Title'**
  String get tripTitle;

  /// Hint for trip title field
  ///
  /// In en, this message translates to:
  /// **'e.g., Paris Adventure 2025'**
  String get tripTitleHint;

  /// Validation message for trip title
  ///
  /// In en, this message translates to:
  /// **'Please enter a trip title'**
  String get tripTitleRequired;

  /// Label for destination field
  ///
  /// In en, this message translates to:
  /// **'Destination'**
  String get destination;

  /// Hint for destination field
  ///
  /// In en, this message translates to:
  /// **'Start typing a country...'**
  String get destinationHint;

  /// Validation message for destination
  ///
  /// In en, this message translates to:
  /// **'Please select a destination'**
  String get destinationRequired;

  /// Label for trip dates field
  ///
  /// In en, this message translates to:
  /// **'Trip Dates'**
  String get tripDates;

  /// Hint for date selection
  ///
  /// In en, this message translates to:
  /// **'Select dates'**
  String get selectDates;

  /// Validation message for dates
  ///
  /// In en, this message translates to:
  /// **'Please select trip dates'**
  String get pleaseSelectDates;

  /// Label for budget field
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// Label for currency field
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Hint for description field
  ///
  /// In en, this message translates to:
  /// **'What are you excited about for this trip?'**
  String get descriptionHint;

  /// Title for budget suggestions card
  ///
  /// In en, this message translates to:
  /// **'Smart Budget Suggestions'**
  String get smartBudgetSuggestions;

  /// Instructions for budget suggestions
  ///
  /// In en, this message translates to:
  /// **'After choosing a destination and trip dates, the app will automatically suggest an average traveler budget for this trip.'**
  String get smartBudgetInstructions;

  /// Label for daily budget estimate
  ///
  /// In en, this message translates to:
  /// **'Estimated daily budget:'**
  String get estimatedDailyBudget;

  /// Note about budget estimate source
  ///
  /// In en, this message translates to:
  /// **'Based on average travelers in {destination}.'**
  String basedOnAverageTravelers(String destination);

  /// Total budget for trip duration
  ///
  /// In en, this message translates to:
  /// **'Total for {days} days: {amount} {currency}'**
  String totalForDays(int days, String amount, String currency);

  /// Apply button
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Default trip preview title
  ///
  /// In en, this message translates to:
  /// **'Trip Preview'**
  String get tripPreview;

  /// Success message when trip is created
  ///
  /// In en, this message translates to:
  /// **'Trip to {destination} created!'**
  String tripCreatedSuccess(String destination);

  /// Error message when trip creation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to create trip'**
  String get failedToCreateTrip;

  /// Expenses screen title
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Label for amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Label for category field
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Label for date field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Label for notes field
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Transport expense category
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// Accommodation expense category
  ///
  /// In en, this message translates to:
  /// **'Accommodation'**
  String get categoryAccommodation;

  /// Food expense category
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// Activities expense category
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get categoryActivities;

  /// Shopping expense category
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// Other expense category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// Chat screen title
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// Chat input placeholder
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// Send button
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// Trips screen title
  ///
  /// In en, this message translates to:
  /// **'Trips'**
  String get trips;

  /// My trips section title
  ///
  /// In en, this message translates to:
  /// **'My Trips'**
  String get myTrips;

  /// Upcoming trips section
  ///
  /// In en, this message translates to:
  /// **'Upcoming Trips'**
  String get upcomingTrips;

  /// Past trips section
  ///
  /// In en, this message translates to:
  /// **'Past Trips'**
  String get pastTrips;

  /// Active trip label
  ///
  /// In en, this message translates to:
  /// **'Active Trip'**
  String get activeTrip;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Sign out button
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Sign in button
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up button
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// General settings section
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get generalSettings;

  /// App language setting
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// Default currency setting
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get defaultCurrency;

  /// Date format setting
  ///
  /// In en, this message translates to:
  /// **'Date Format'**
  String get dateFormat;

  /// Distance units setting
  ///
  /// In en, this message translates to:
  /// **'Distance Units'**
  String get distanceUnits;

  /// Kilometers option
  ///
  /// In en, this message translates to:
  /// **'Kilometers'**
  String get kilometers;

  /// Miles option
  ///
  /// In en, this message translates to:
  /// **'Miles'**
  String get miles;

  /// Dark mode setting
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Notifications section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Push notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// Email notifications toggle
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get emailNotifications;

  /// Trip reminders toggle
  ///
  /// In en, this message translates to:
  /// **'Trip Reminders'**
  String get tripReminders;

  /// Privacy section
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// Analytics sharing toggle
  ///
  /// In en, this message translates to:
  /// **'Share Usage Analytics'**
  String get shareAnalytics;

  /// Location tracking toggle
  ///
  /// In en, this message translates to:
  /// **'Location Tracking'**
  String get locationTracking;

  /// Account section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Change password option
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Export data option
  ///
  /// In en, this message translates to:
  /// **'Export My Data'**
  String get exportData;

  /// Delete account option
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// Delete account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// Reset account data option
  ///
  /// In en, this message translates to:
  /// **'Reset Account Data'**
  String get resetAccount;

  /// Reset account confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.'**
  String get resetAccountConfirmation;

  /// Success message after resetting account
  ///
  /// In en, this message translates to:
  /// **'Account data has been reset successfully'**
  String get accountResetSuccess;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Rate app link
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get rateApp;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No date placeholder
  ///
  /// In en, this message translates to:
  /// **'No date'**
  String get noDate;

  /// Error loading chats
  ///
  /// In en, this message translates to:
  /// **'Failed to load chats'**
  String get failedToLoadChats;

  /// Error loading expenses
  ///
  /// In en, this message translates to:
  /// **'Failed to load expenses'**
  String get failedToLoadExpenses;

  /// Reset data button
  ///
  /// In en, this message translates to:
  /// **'Reset Data'**
  String get resetData;

  /// Reset data dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset User Data'**
  String get resetDataTitle;

  /// Reset data confirmation message
  ///
  /// In en, this message translates to:
  /// **'This will delete all your trips and reset the onboarding status. You will be redirected to start the onboarding process again.\n\nThis action cannot be undone.'**
  String get resetDataMessage;

  /// Day tip card title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Travel Tip'**
  String get dayTip;

  /// Day tip card subtitle
  ///
  /// In en, this message translates to:
  /// **'AI-powered travel recommendations'**
  String get dayTipDescription;

  /// Refresh tip button
  ///
  /// In en, this message translates to:
  /// **'Refresh Tip'**
  String get refreshTip;

  /// Onboarding welcome title
  ///
  /// In en, this message translates to:
  /// **'Welcome to TripBuddy'**
  String get onboardingWelcome;

  /// Language selection title
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get onboardingLanguageTitle;

  /// Language selection subtitle
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app'**
  String get onboardingLanguageSubtitle;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Spanish language name
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get languageSpanish;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get languageFrench;

  /// German language name
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get languageGerman;

  /// Hebrew language name
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get languageHebrew;

  /// Japanese language name
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get languageJapanese;

  /// Chinese language name
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageChinese;

  /// Korean language name
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get languageKorean;

  /// Italian language name
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// Portuguese language name
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get languagePortuguese;

  /// Russian language name
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get languageRussian;

  /// Arabic language name
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get languageArabic;

  /// Chat input hint
  ///
  /// In en, this message translates to:
  /// **'Ask me anything about travel...'**
  String get chatHint;

  /// Delete chat action
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// Delete chat confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this chat?'**
  String get deleteChatConfirmation;

  /// Expense added success message
  ///
  /// In en, this message translates to:
  /// **'Expense added!'**
  String get expenseAdded;

  /// Expense add failure message
  ///
  /// In en, this message translates to:
  /// **'Failed to add expense'**
  String get failedToAddExpense;

  /// Chat welcome title
  ///
  /// In en, this message translates to:
  /// **'Hey there, traveler!'**
  String get chatWelcomeTitle;

  /// Chat welcome description
  ///
  /// In en, this message translates to:
  /// **'I\'m TripBuddy, your travel companion! I\'m here to help you document your adventures, plan activities, and create a beautiful travel journal.'**
  String get chatWelcomeDescription;

  /// Chat action prompt
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get chatWhatToDo;

  /// Tell about day action
  ///
  /// In en, this message translates to:
  /// **'Tell me about your day'**
  String get tellAboutDay;

  /// Tell about day description
  ///
  /// In en, this message translates to:
  /// **'Share what you did, saw, or experienced'**
  String get tellAboutDayDescription;

  /// Prompt sent when clicking tell about day
  ///
  /// In en, this message translates to:
  /// **'Let me tell you about my day today...'**
  String get tellAboutDayPrompt;

  /// Plan activity action
  ///
  /// In en, this message translates to:
  /// **'Plan an activity'**
  String get planActivity;

  /// Plan activity description
  ///
  /// In en, this message translates to:
  /// **'Get recommendations for things to do'**
  String get planActivityDescription;

  /// Prompt sent when clicking plan activity
  ///
  /// In en, this message translates to:
  /// **'What are some good activities I should do here?'**
  String get planActivityPrompt;

  /// Log expense action
  ///
  /// In en, this message translates to:
  /// **'Log an expense'**
  String get logExpenseAction;

  /// Log expense description
  ///
  /// In en, this message translates to:
  /// **'Track spending on your trip'**
  String get logExpenseDescription;

  /// Prompt sent when clicking log expense
  ///
  /// In en, this message translates to:
  /// **'I want to log an expense'**
  String get logExpensePrompt;

  /// Generate journal action
  ///
  /// In en, this message translates to:
  /// **'Generate my journal'**
  String get generateJournal;

  /// Generate journal description
  ///
  /// In en, this message translates to:
  /// **'Create today\'s travel journal entry'**
  String get generateJournalDescription;

  /// Prompt sent when clicking generate journal
  ///
  /// In en, this message translates to:
  /// **'Help me write my travel journal for today'**
  String get generateJournalPrompt;

  /// Ask anything action
  ///
  /// In en, this message translates to:
  /// **'Ask anything'**
  String get askAnything;

  /// Ask anything description
  ///
  /// In en, this message translates to:
  /// **'Travel tips, local info, recommendations'**
  String get askAnythingDescription;

  /// AI Chats screen title
  ///
  /// In en, this message translates to:
  /// **'AI Chats'**
  String get aiChats;

  /// Start new chat button
  ///
  /// In en, this message translates to:
  /// **'Start New Chat'**
  String get startNewChat;

  /// AI assistant title
  ///
  /// In en, this message translates to:
  /// **'AI Travel Assistant'**
  String get aiTravelAssistant;

  /// AI assistant description
  ///
  /// In en, this message translates to:
  /// **'Start a conversation with your AI travel buddy to plan trips, get recommendations, and more!'**
  String get aiTravelAssistantDescription;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Error deleting chat message
  ///
  /// In en, this message translates to:
  /// **'Error deleting chat'**
  String get errorDeletingChat;

  /// Today at time
  ///
  /// In en, this message translates to:
  /// **'Today at {time}'**
  String todayAt(String time);

  /// Yesterday at time
  ///
  /// In en, this message translates to:
  /// **'Yesterday at {time}'**
  String yesterdayAt(String time);

  /// Delete chat title confirmation
  ///
  /// In en, this message translates to:
  /// **'Delete \"{title}\"? This cannot be undone.'**
  String deleteChatTitle(String title);

  /// Error creating chat message
  ///
  /// In en, this message translates to:
  /// **'Error creating chat'**
  String get errorCreatingChat;

  /// Error loading chat message
  ///
  /// In en, this message translates to:
  /// **'Error loading chat'**
  String get errorLoadingChat;

  /// Message when no trip for tips
  ///
  /// In en, this message translates to:
  /// **'Create a trip to get daily tips!'**
  String get createTripForTips;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Number of expenses
  ///
  /// In en, this message translates to:
  /// **'{count} expenses'**
  String expensesCount(int count);

  /// Number of days tracked
  ///
  /// In en, this message translates to:
  /// **'{count} days tracked'**
  String daysTracked(int count);

  /// Trip duration
  ///
  /// In en, this message translates to:
  /// **'{count} day trip'**
  String dayTrip(int count);

  /// Days remaining
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String daysLeft(int count);

  /// By category section title
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get byCategory;

  /// Spending over time section title
  ///
  /// In en, this message translates to:
  /// **'Spending Over Time'**
  String get spendingOverTime;

  /// No expenses title
  ///
  /// In en, this message translates to:
  /// **'No Expenses Yet'**
  String get noExpensesYet;

  /// No expenses description
  ///
  /// In en, this message translates to:
  /// **'Start tracking your travel expenses by adding your first expense.'**
  String get startTrackingExpenses;

  /// Error title
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Home currency tooltip
  ///
  /// In en, this message translates to:
  /// **'Home Currency'**
  String get homeCurrency;

  /// USD tooltip
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get usDollar;

  /// Local currency tooltip
  ///
  /// In en, this message translates to:
  /// **'Local Currency'**
  String get localCurrency;

  /// Food category name
  ///
  /// In en, this message translates to:
  /// **'Food & Drinks'**
  String get foodAndDrinks;

  /// Trip selection validation
  ///
  /// In en, this message translates to:
  /// **'Please select a trip'**
  String get pleaseSelectTrip;

  /// Expense added success message
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully!'**
  String get expenseAddedSuccess;

  /// No trips message
  ///
  /// In en, this message translates to:
  /// **'No trips found. Create a trip first to add expenses.'**
  String get noTripsFound;

  /// Trip label
  ///
  /// In en, this message translates to:
  /// **'Trip'**
  String get trip;

  /// Amount validation
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get pleaseEnterAmount;

  /// Number validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// Description validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a description'**
  String get pleaseEnterDescription;

  /// Expense description hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Lunch at Cafe'**
  String get descriptionHintExpense;

  /// Receipt photo button
  ///
  /// In en, this message translates to:
  /// **'Add Receipt Photo'**
  String get addReceiptPhoto;

  /// Receipt photo coming soon message
  ///
  /// In en, this message translates to:
  /// **'Receipt photo coming soon!'**
  String get receiptPhotoComingSoon;

  /// Split expense question
  ///
  /// In en, this message translates to:
  /// **'Split this expense?'**
  String get splitThisExpense;

  /// Split members instruction
  ///
  /// In en, this message translates to:
  /// **'Select trip members to split with'**
  String get selectTripMembersToSplit;

  /// No trip members message
  ///
  /// In en, this message translates to:
  /// **'No trip members to split with. Create a trip first!'**
  String get noTripMembersToSplit;

  /// Notes label
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// Notes hint
  ///
  /// In en, this message translates to:
  /// **'Any additional details...'**
  String get additionalDetails;

  /// Countries label
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get countries;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// Help and legal section header
  ///
  /// In en, this message translates to:
  /// **'Help & Legal'**
  String get helpAndLegal;

  /// Free subscription plan
  ///
  /// In en, this message translates to:
  /// **'Free Plan'**
  String get freePlan;

  /// Upgrade prompt
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock unlimited trips and AI features'**
  String get upgradeUnlockFeatures;

  /// Upgrade button
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// Sign out confirmation
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// Sign out error
  ///
  /// In en, this message translates to:
  /// **'Failed to sign out'**
  String get failedToSignOut;

  /// Not signed in message
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// Default traveler name
  ///
  /// In en, this message translates to:
  /// **'Traveler'**
  String get traveler;

  /// Member since date text
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String memberSince(String date);

  /// AI usage card title
  ///
  /// In en, this message translates to:
  /// **'AI Usage Today'**
  String get aiUsageToday;

  /// Premium subscription plan
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// Used label
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get used;

  /// Credits label
  ///
  /// In en, this message translates to:
  /// **'credits'**
  String get credits;

  /// Credits used count
  ///
  /// In en, this message translates to:
  /// **'{count} credits used'**
  String creditsUsedCount(String count);

  /// Credits remaining count
  ///
  /// In en, this message translates to:
  /// **'{count} remaining'**
  String creditsRemainingCount(String count);

  /// Daily credit limit
  ///
  /// In en, this message translates to:
  /// **'Daily limit: {count} credits'**
  String dailyLimitCredits(String count);

  /// Credit limit exceeded error message
  ///
  /// In en, this message translates to:
  /// **'Daily credit limit exceeded. Please try again tomorrow.'**
  String get creditLimitExceeded;

  /// Credit limit exceeded with upgrade suggestion
  ///
  /// In en, this message translates to:
  /// **'Daily credit limit reached. Upgrade to get more credits!'**
  String get creditLimitExceededUpgrade;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'he',
    'it',
    'ja',
    'ko',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'he':
      return AppLocalizationsHe();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
