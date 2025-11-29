// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TripBuddy';

  @override
  String get home => 'Home';

  @override
  String get welcomeGreetingMorning => 'Good morning,';

  @override
  String get welcomeGreetingAfternoon => 'Good afternoon,';

  @override
  String get welcomeGreetingEvening => 'Good evening,';

  @override
  String get noActiveTrip => 'No Active Trip';

  @override
  String get startPlanningAdventure => 'Start planning your next adventure!';

  @override
  String get createNewTrip => 'Create New Trip';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get newTrip => 'New Trip';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get aiChat => 'AI Chat';

  @override
  String get recentChats => 'Recent Chats';

  @override
  String get recentExpenses => 'Recent Expenses';

  @override
  String get viewAll => 'View All';

  @override
  String get startConversation => 'Start a conversation with TripBuddy!';

  @override
  String get newChat => 'New Chat';

  @override
  String get noExpensesRecorded => 'No expenses recorded yet';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get dates => 'Dates';

  @override
  String get datesNotSet => 'Dates not set';

  @override
  String get duration => 'Duration';

  @override
  String get notSet => 'Not set';

  @override
  String get startsIn => 'Starts in';

  @override
  String get status => 'Status';

  @override
  String get completed => 'Completed';

  @override
  String get current => 'Current';

  @override
  String get day => 'day';

  @override
  String get days => 'days';

  @override
  String dayOfTotal(int current, int total) {
    return 'Day $current of $total';
  }

  @override
  String get createTrip => 'Create Trip';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get tripTitle => 'Trip Title';

  @override
  String get tripTitleHint => 'e.g., Paris Adventure 2025';

  @override
  String get tripTitleRequired => 'Please enter a trip title';

  @override
  String get destination => 'Destination';

  @override
  String get destinationHint => 'Start typing a country...';

  @override
  String get destinationRequired => 'Please select a destination';

  @override
  String get tripDates => 'Trip Dates';

  @override
  String get selectDates => 'Select dates';

  @override
  String get pleaseSelectDates => 'Please select trip dates';

  @override
  String get budget => 'Budget';

  @override
  String get currency => 'Currency';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint => 'What are you excited about for this trip?';

  @override
  String get smartBudgetSuggestions => 'Smart Budget Suggestions';

  @override
  String get smartBudgetInstructions =>
      'After choosing a destination and trip dates, the app will automatically suggest an average traveler budget for this trip.';

  @override
  String get estimatedDailyBudget => 'Estimated daily budget:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'Based on average travelers in $destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'Total for $days days: $amount $currency';
  }

  @override
  String get apply => 'Apply';

  @override
  String get tripPreview => 'Trip Preview';

  @override
  String tripCreatedSuccess(String destination) {
    return 'Trip to $destination created!';
  }

  @override
  String get failedToCreateTrip => 'Failed to create trip';

  @override
  String get expenses => 'Expenses';

  @override
  String get amount => 'Amount';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get notes => 'Notes';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryAccommodation => 'Accommodation';

  @override
  String get categoryFood => 'Food';

  @override
  String get categoryActivities => 'Activities';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryOther => 'Other';

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Type a message...';

  @override
  String get send => 'Send';

  @override
  String get trips => 'Trips';

  @override
  String get myTrips => 'My Trips';

  @override
  String get upcomingTrips => 'Upcoming Trips';

  @override
  String get pastTrips => 'Past Trips';

  @override
  String get activeTrip => 'Active Trip';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get generalSettings => 'General';

  @override
  String get appLanguage => 'App Language';

  @override
  String get defaultCurrency => 'Default Currency';

  @override
  String get dateFormat => 'Date Format';

  @override
  String get distanceUnits => 'Distance Units';

  @override
  String get kilometers => 'Kilometers';

  @override
  String get miles => 'Miles';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get emailNotifications => 'Email Notifications';

  @override
  String get tripReminders => 'Trip Reminders';

  @override
  String get privacy => 'Privacy';

  @override
  String get shareAnalytics => 'Share Usage Analytics';

  @override
  String get locationTracking => 'Location Tracking';

  @override
  String get account => 'Account';

  @override
  String get changePassword => 'Change Password';

  @override
  String get exportData => 'Export My Data';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'Reset';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get rateApp => 'Rate the App';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get loading => 'Loading...';

  @override
  String get noDate => 'No date';

  @override
  String get failedToLoadChats => 'Failed to load chats';

  @override
  String get failedToLoadExpenses => 'Failed to load expenses';

  @override
  String get resetData => 'Reset Data';

  @override
  String get resetDataTitle => 'Reset User Data';

  @override
  String get resetDataMessage =>
      'This will delete all your trips and reset the onboarding status. You will be redirected to start the onboarding process again.\n\nThis action cannot be undone.';

  @override
  String get dayTip => 'Today\'s Travel Tip';

  @override
  String get dayTipDescription => 'AI-powered travel recommendations';

  @override
  String get refreshTip => 'Refresh Tip';

  @override
  String get onboardingWelcome => 'Welcome to TripBuddy';

  @override
  String get onboardingLanguageTitle => 'Choose Your Language';

  @override
  String get onboardingLanguageSubtitle =>
      'Select your preferred language for the app';

  @override
  String get continueButton => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get getStarted => 'Get Started';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageSpanish => 'Spanish';

  @override
  String get languageFrench => 'French';

  @override
  String get languageGerman => 'German';

  @override
  String get languageHebrew => 'Hebrew';

  @override
  String get languageJapanese => 'Japanese';

  @override
  String get languageChinese => 'Chinese';

  @override
  String get languageKorean => 'Korean';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languagePortuguese => 'Portuguese';

  @override
  String get languageRussian => 'Russian';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get chatHint => 'Ask me anything about travel...';

  @override
  String get deleteChat => 'Delete Chat';

  @override
  String get deleteChatConfirmation =>
      'Are you sure you want to delete this chat?';

  @override
  String get expenseAdded => 'Expense added!';

  @override
  String get failedToAddExpense => 'Failed to add expense';

  @override
  String get chatWelcomeTitle => 'Hey there, traveler!';

  @override
  String get chatWelcomeDescription =>
      'I\'m TripBuddy, your travel companion! I\'m here to help you document your adventures, plan activities, and create a beautiful travel journal.';

  @override
  String get chatWhatToDo => 'What would you like to do?';

  @override
  String get tellAboutDay => 'Tell me about your day';

  @override
  String get tellAboutDayDescription =>
      'Share what you did, saw, or experienced';

  @override
  String get tellAboutDayPrompt => 'Let me tell you about my day today...';

  @override
  String get planActivity => 'Plan an activity';

  @override
  String get planActivityDescription => 'Get recommendations for things to do';

  @override
  String get planActivityPrompt =>
      'What are some good activities I should do here?';

  @override
  String get logExpenseAction => 'Log an expense';

  @override
  String get logExpenseDescription => 'Track spending on your trip';

  @override
  String get logExpensePrompt => 'I want to log an expense';

  @override
  String get generateJournal => 'Generate my journal';

  @override
  String get generateJournalDescription =>
      'Create today\'s travel journal entry';

  @override
  String get generateJournalPrompt =>
      'Help me write my travel journal for today';

  @override
  String get askAnything => 'Ask anything';

  @override
  String get askAnythingDescription =>
      'Travel tips, local info, recommendations';

  @override
  String get aiChats => 'AI Chats';

  @override
  String get startNewChat => 'Start New Chat';

  @override
  String get aiTravelAssistant => 'AI Travel Assistant';

  @override
  String get aiTravelAssistantDescription =>
      'Start a conversation with your AI travel buddy to plan trips, get recommendations, and more!';

  @override
  String get retry => 'Retry';

  @override
  String get errorDeletingChat => 'Error deleting chat';

  @override
  String todayAt(String time) {
    return 'Today at $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Yesterday at $time';
  }

  @override
  String deleteChatTitle(String title) {
    return 'Delete \"$title\"? This cannot be undone.';
  }

  @override
  String get errorCreatingChat => 'Error creating chat';

  @override
  String get errorLoadingChat => 'Error loading chat';

  @override
  String get createTripForTips => 'Create a trip to get daily tips!';

  @override
  String get overview => 'Overview';

  @override
  String expensesCount(int count) {
    return '$count expenses';
  }

  @override
  String daysTracked(int count) {
    return '$count days tracked';
  }

  @override
  String dayTrip(int count) {
    return '$count day trip';
  }

  @override
  String daysLeft(int count) {
    return '$count days left';
  }

  @override
  String get byCategory => 'By Category';

  @override
  String get spendingOverTime => 'Spending Over Time';

  @override
  String get noExpensesYet => 'No Expenses Yet';

  @override
  String get startTrackingExpenses =>
      'Start tracking your travel expenses by adding your first expense.';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get homeCurrency => 'Home Currency';

  @override
  String get usDollar => 'US Dollar';

  @override
  String get localCurrency => 'Local Currency';

  @override
  String get foodAndDrinks => 'Food & Drinks';

  @override
  String get pleaseSelectTrip => 'Please select a trip';

  @override
  String get expenseAddedSuccess => 'Expense added successfully!';

  @override
  String get noTripsFound =>
      'No trips found. Create a trip first to add expenses.';

  @override
  String get trip => 'Trip';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get pleaseEnterDescription => 'Please enter a description';

  @override
  String get descriptionHintExpense => 'e.g., Lunch at Cafe';

  @override
  String get addReceiptPhoto => 'Add Receipt Photo';

  @override
  String get receiptPhotoComingSoon => 'Receipt photo coming soon!';

  @override
  String get splitThisExpense => 'Split this expense?';

  @override
  String get selectTripMembersToSplit => 'Select trip members to split with';

  @override
  String get noTripMembersToSplit =>
      'No trip members to split with. Create a trip first!';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get additionalDetails => 'Any additional details...';

  @override
  String get countries => 'Countries';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get freePlan => 'Free Plan';

  @override
  String get upgradeUnlockFeatures =>
      'Upgrade to unlock unlimited trips and AI features';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get failedToSignOut => 'Failed to sign out';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get traveler => 'Traveler';

  @override
  String memberSince(String date) {
    return 'Member since $date';
  }

  @override
  String get aiUsageToday => 'AI Usage Today';

  @override
  String get premiumPlan => 'Premium Plan';

  @override
  String get used => 'used';

  @override
  String get credits => 'credits';

  @override
  String creditsUsedCount(String count) {
    return '$count credits used';
  }

  @override
  String creditsRemainingCount(String count) {
    return '$count remaining';
  }

  @override
  String dailyLimitCredits(String count) {
    return 'Daily limit: $count credits';
  }

  @override
  String get creditLimitExceeded =>
      'Daily credit limit exceeded. Please try again tomorrow.';

  @override
  String get creditLimitExceededUpgrade =>
      'Daily credit limit reached. Upgrade to get more credits!';
}
