// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Waylo';

  @override
  String get home => 'Start';

  @override
  String get welcomeGreetingMorning => 'Guten Morgen,';

  @override
  String get welcomeGreetingAfternoon => 'Guten Tag,';

  @override
  String get welcomeGreetingEvening => 'Guten Abend,';

  @override
  String get noActiveTrip => 'Keine Aktive Reise';

  @override
  String get startPlanningAdventure => 'Planen Sie Ihr nachstes Abenteuer!';

  @override
  String get createNewTrip => 'Neue Reise Erstellen';

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get newTrip => 'Neue Reise';

  @override
  String get addExpense => 'Ausgabe Hinzufugen';

  @override
  String get aiChat => 'KI-Chat';

  @override
  String get recentChats => 'Letzte Chats';

  @override
  String get recentExpenses => 'Letzte Ausgaben';

  @override
  String get viewAll => 'Alle Anzeigen';

  @override
  String get startConversation => 'Starten Sie ein Gesprach mit Waylo!';

  @override
  String get newChat => 'Neuer Chat';

  @override
  String get noExpensesRecorded => 'Noch keine Ausgaben erfasst';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get dates => 'Daten';

  @override
  String get datesNotSet => 'Daten nicht festgelegt';

  @override
  String get duration => 'Dauer';

  @override
  String get notSet => 'Nicht festgelegt';

  @override
  String get startsIn => 'Beginnt in';

  @override
  String get status => 'Status';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get current => 'Aktuell';

  @override
  String get day => 'Tag';

  @override
  String get days => 'Tage';

  @override
  String dayOfTotal(int current, int total) {
    return 'Tag $current von $total';
  }

  @override
  String get createTrip => 'Reise Erstellen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Loschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get confirm => 'Bestatigen';

  @override
  String get tripTitle => 'Reisetitel';

  @override
  String get tripTitleHint => 'z.B. Paris Abenteuer 2025';

  @override
  String get tripTitleRequired => 'Bitte geben Sie einen Reisetitel ein';

  @override
  String get destination => 'Reiseziel';

  @override
  String get destinationHint => 'Beginnen Sie mit der Eingabe eines Landes...';

  @override
  String get destinationRequired => 'Bitte wahlen Sie ein Reiseziel';

  @override
  String get tripDates => 'Reisedaten';

  @override
  String get selectDates => 'Daten auswahlen';

  @override
  String get pleaseSelectDates => 'Bitte wahlen Sie die Reisedaten';

  @override
  String get budget => 'Budget';

  @override
  String get currency => 'Wahrung';

  @override
  String get description => 'Beschreibung';

  @override
  String get descriptionHint => 'Worauf freuen Sie sich bei dieser Reise?';

  @override
  String get smartBudgetSuggestions => 'Intelligente Budgetvorschlage';

  @override
  String get smartBudgetInstructions =>
      'Nach Auswahl eines Reiseziels und der Daten wird die App automatisch ein durchschnittliches Reisebudget vorschlagen.';

  @override
  String get estimatedDailyBudget => 'Geschatztes Tagesbudget:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'Basierend auf Durchschnittsreisenden in $destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'Gesamt fur $days Tage: $amount $currency';
  }

  @override
  String get apply => 'Anwenden';

  @override
  String get tripPreview => 'Reisevorschau';

  @override
  String tripCreatedSuccess(String destination) {
    return 'Reise nach $destination erstellt!';
  }

  @override
  String get failedToCreateTrip => 'Reise konnte nicht erstellt werden';

  @override
  String get expenses => 'Ausgaben';

  @override
  String get amount => 'Betrag';

  @override
  String get category => 'Kategorie';

  @override
  String get date => 'Datum';

  @override
  String get notes => 'Notizen';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryAccommodation => 'Unterkunft';

  @override
  String get categoryFood => 'Essen';

  @override
  String get categoryActivities => 'Aktivitaten';

  @override
  String get categoryShopping => 'Einkaufen';

  @override
  String get categoryOther => 'Sonstiges';

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Nachricht eingeben...';

  @override
  String get send => 'Senden';

  @override
  String get trips => 'Reisen';

  @override
  String get myTrips => 'Meine Reisen';

  @override
  String get upcomingTrips => 'Kommende Reisen';

  @override
  String get pastTrips => 'Vergangene Reisen';

  @override
  String get activeTrip => 'Aktive Reise';

  @override
  String get otherTrips => 'Other Trips';

  @override
  String get noTripsYet => 'No Trips Yet';

  @override
  String get noTripsDescription =>
      'Start planning your next adventure\nby creating a new trip.';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Einstellungen';

  @override
  String get signOut => 'Abmelden';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signUp => 'Registrieren';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get fullName => 'Vollstandiger Name';

  @override
  String get generalSettings => 'Allgemein';

  @override
  String get appLanguage => 'App-Sprache';

  @override
  String get defaultCurrency => 'Standardwahrung';

  @override
  String get dateFormat => 'Datumsformat';

  @override
  String get distanceUnits => 'Entfernungseinheiten';

  @override
  String get kilometers => 'Kilometer';

  @override
  String get miles => 'Meilen';

  @override
  String get darkMode => 'Dunkelmodus';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get pushNotifications => 'Push-Benachrichtigungen';

  @override
  String get emailNotifications => 'E-Mail-Benachrichtigungen';

  @override
  String get tripReminders => 'Reiseerinnerungen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get shareAnalytics => 'Nutzungsanalysen Teilen';

  @override
  String get locationTracking => 'Standortverfolgung';

  @override
  String get account => 'Konto';

  @override
  String get changePassword => 'Passwort Andern';

  @override
  String get exportData => 'Meine Daten Exportieren';

  @override
  String get deleteAccount => 'Konto Loschen';

  @override
  String get deleteAccountConfirmation =>
      'Sind Sie sicher, dass Sie Ihr Konto loschen mochten? Diese Aktion kann nicht ruckgangig gemacht werden.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'Zurucksetzen';

  @override
  String get about => 'Uber';

  @override
  String get appVersion => 'App-Version';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get rateApp => 'App Bewerten';

  @override
  String get error => 'Fehler';

  @override
  String get errorOccurred => 'Ein Fehler ist aufgetreten';

  @override
  String get tryAgain => 'Erneut Versuchen';

  @override
  String get loading => 'Laden...';

  @override
  String get noDate => 'Kein Datum';

  @override
  String get failedToLoadChats => 'Chats konnten nicht geladen werden';

  @override
  String get failedToLoadExpenses => 'Ausgaben konnten nicht geladen werden';

  @override
  String get resetData => 'Daten Zurucksetzen';

  @override
  String get resetDataTitle => 'Benutzerdaten Zurucksetzen';

  @override
  String get resetDataMessage =>
      'Dies wird alle Ihre Reisen loschen und den Onboarding-Status zurucksetzen. Sie werden weitergeleitet, um den Onboarding-Prozess erneut zu starten.\n\nDiese Aktion kann nicht ruckgangig gemacht werden.';

  @override
  String get dayTip => 'Tageshinweis';

  @override
  String get dayTipDescription => 'KI-gestutzte Reiseempfehlungen';

  @override
  String get refreshTip => 'Tipp Aktualisieren';

  @override
  String get onboardingWelcome => 'Willkommen bei Waylo';

  @override
  String get onboardingLanguageTitle => 'Wahlen Sie Ihre Sprache';

  @override
  String get onboardingLanguageSubtitle =>
      'Wahlen Sie Ihre bevorzugte Sprache fur die App';

  @override
  String get continueButton => 'Weiter';

  @override
  String get skip => 'Uberspringen';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get languageEnglish => 'Englisch';

  @override
  String get languageSpanish => 'Spanisch';

  @override
  String get languageFrench => 'Franzosisch';

  @override
  String get languageGerman => 'Deutsch';

  @override
  String get languageHebrew => 'Hebraisch';

  @override
  String get languageJapanese => 'Japanisch';

  @override
  String get languageChinese => 'Chinesisch';

  @override
  String get languageKorean => 'Koreanisch';

  @override
  String get languageItalian => 'Italienisch';

  @override
  String get languagePortuguese => 'Portugiesisch';

  @override
  String get languageRussian => 'Russisch';

  @override
  String get languageArabic => 'Arabisch';

  @override
  String get chatHint => 'Fragen Sie mich alles uber Reisen...';

  @override
  String get deleteChat => 'Chat Loschen';

  @override
  String get deleteChatConfirmation =>
      'Sind Sie sicher, dass Sie diesen Chat loschen mochten?';

  @override
  String get expenseAdded => 'Ausgabe hinzugefugt!';

  @override
  String get failedToAddExpense => 'Ausgabe konnte nicht hinzugefugt werden';

  @override
  String get chatWelcomeTitle => 'Hallo, Reisender!';

  @override
  String get chatWelcomeDescription =>
      'Ich bin Waylo, Ihr Reisebegleiter! Ich bin hier, um Ihnen zu helfen, Ihre Abenteuer zu dokumentieren, Aktivitaten zu planen und ein schones Reisetagebuch zu erstellen.';

  @override
  String get chatWhatToDo => 'Was mochten Sie tun?';

  @override
  String get tellAboutDay => 'Erzahlen Sie mir von Ihrem Tag';

  @override
  String get tellAboutDayDescription =>
      'Teilen Sie, was Sie getan, gesehen oder erlebt haben';

  @override
  String get tellAboutDayPrompt =>
      'Lassen Sie mich Ihnen von meinem Tag erzahlen...';

  @override
  String get planActivity => 'Eine Aktivitat planen';

  @override
  String get planActivityDescription => 'Aktivitatsempfehlungen erhalten';

  @override
  String get planActivityPrompt =>
      'Welche guten Aktivitaten kann ich hier machen?';

  @override
  String get logExpenseAction => 'Eine Ausgabe erfassen';

  @override
  String get logExpenseDescription => 'Ausgaben auf Ihrer Reise verfolgen';

  @override
  String get logExpensePrompt => 'Ich mochte eine Ausgabe erfassen';

  @override
  String get generateJournal => 'Mein Tagebuch erstellen';

  @override
  String get generateJournalDescription =>
      'Den heutigen Reisetagebucheintrag erstellen';

  @override
  String get generateJournalPrompt =>
      'Helfen Sie mir, mein Reisetagebuch fur heute zu schreiben';

  @override
  String get askAnything => 'Fragen Sie alles';

  @override
  String get askAnythingDescription => 'Reisetipps, lokale Infos, Empfehlungen';

  @override
  String get aiChats => 'KI-Chats';

  @override
  String get startNewChat => 'Neuen Chat Starten';

  @override
  String get aiTravelAssistant => 'KI-Reiseassistent';

  @override
  String get aiTravelAssistantDescription =>
      'Starten Sie ein Gesprach mit Ihrem KI-Reisebegleiter, um Reisen zu planen, Empfehlungen zu erhalten und mehr!';

  @override
  String get retry => 'Erneut Versuchen';

  @override
  String get errorDeletingChat => 'Fehler beim Loschen des Chats';

  @override
  String todayAt(String time) {
    return 'Heute um $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Gestern um $time';
  }

  @override
  String deleteChatTitle(String title) {
    return '\"$title\" loschen? Diese Aktion kann nicht ruckgangig gemacht werden.';
  }

  @override
  String get errorCreatingChat => 'Fehler beim Erstellen des Chats';

  @override
  String get errorLoadingChat => 'Fehler beim Laden des Chats';

  @override
  String get createTripForTips =>
      'Erstellen Sie eine Reise, um tagliche Tipps zu erhalten!';

  @override
  String get overview => 'Ubersicht';

  @override
  String expensesCount(int count) {
    return '$count Ausgaben';
  }

  @override
  String daysTracked(int count) {
    return '$count Tage erfasst';
  }

  @override
  String dayTrip(int count) {
    return '$count-tagige Reise';
  }

  @override
  String daysLeft(int count) {
    return 'Noch $count Tage';
  }

  @override
  String get byCategory => 'Nach Kategorie';

  @override
  String get spendingOverTime => 'Ausgaben im Zeitverlauf';

  @override
  String get noExpensesYet => 'Noch Keine Ausgaben';

  @override
  String get startTrackingExpenses =>
      'Beginnen Sie mit der Verfolgung Ihrer Reiseausgaben, indem Sie Ihre erste Ausgabe hinzufugen.';

  @override
  String get somethingWentWrong => 'Etwas ist schief gelaufen';

  @override
  String get homeCurrency => 'Heimatwahrung';

  @override
  String get usDollar => 'US-Dollar';

  @override
  String get localCurrency => 'Zielwahrung';

  @override
  String get foodAndDrinks => 'Essen und Getranke';

  @override
  String get pleaseSelectTrip => 'Bitte wahlen Sie eine Reise';

  @override
  String get expenseAddedSuccess => 'Ausgabe erfolgreich hinzugefugt!';

  @override
  String get noTripsFound =>
      'Keine Reisen gefunden. Erstellen Sie zuerst eine Reise, um Ausgaben hinzuzufugen.';

  @override
  String get trip => 'Reise';

  @override
  String get pleaseEnterAmount => 'Bitte geben Sie einen Betrag ein';

  @override
  String get pleaseEnterValidNumber => 'Bitte geben Sie eine gultige Zahl ein';

  @override
  String get pleaseEnterDescription => 'Bitte geben Sie eine Beschreibung ein';

  @override
  String get descriptionHintExpense => 'z.B. Mittagessen im Cafe';

  @override
  String get addReceiptPhoto => 'Belegfoto Hinzufugen';

  @override
  String get receiptPhotoComingSoon => 'Belegfoto kommt bald!';

  @override
  String get splitThisExpense => 'Diese Ausgabe teilen?';

  @override
  String get selectTripMembersToSplit => 'Reisepartner zum Teilen auswahlen';

  @override
  String get noTripMembersToSplit =>
      'Keine Reisepartner zum Teilen. Erstellen Sie zuerst eine Reise!';

  @override
  String get balances => 'Balances';

  @override
  String get settlements => 'Settlements';

  @override
  String get notesOptional => 'Notizen (optional)';

  @override
  String get additionalDetails => 'Zusatzliche Details...';

  @override
  String get countries => 'Lander';

  @override
  String get helpAndSupport => 'Hilfe und Support';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get legalAndPolicies => 'Legal & Policies';

  @override
  String get freePlan => 'Kostenloser Plan';

  @override
  String get upgradeUnlockFeatures =>
      'Upgraden Sie, um unbegrenzte Reisen und KI-Funktionen freizuschalten';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get signOutConfirmation =>
      'Sind Sie sicher, dass Sie sich abmelden mochten?';

  @override
  String get failedToSignOut => 'Abmeldung fehlgeschlagen';

  @override
  String get notSignedIn => 'Nicht angemeldet';

  @override
  String get traveler => 'Reisender';

  @override
  String memberSince(String date) {
    return 'Mitglied seit $date';
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

  @override
  String get yourTrip => 'Your Trip';

  @override
  String get journalReadyTitle => 'Your Trip Journal is Ready!';

  @override
  String journalReadyDescription(String count, String tripName) {
    return 'We\'ve created $count journal entries from your $tripName adventure.';
  }

  @override
  String get viewJournal => 'View Journal';

  @override
  String get journalAutoGenerated => 'Auto-generated from your activities';

  @override
  String get generatingJournals => 'Creating your journal entries...';

  @override
  String get inviteFriends => 'Invite Friends';

  @override
  String get inviteFriendsSubtitle => 'Get 50 free credits for each friend!';

  @override
  String get yourReferralCode => 'Your referral code';

  @override
  String get copy => 'Copy';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String friendsInvited(String count) {
    return '$count friends invited';
  }

  @override
  String creditsEarned(String count) {
    return '$count credits earned';
  }

  @override
  String get shareInvite => 'Share Invite';

  @override
  String get referralCode => 'Referral Code';

  @override
  String get referralCodeHint => 'Enter referral code (optional)';

  @override
  String get referralApplied =>
      'Referral code applied! You both get 50 credits.';

  @override
  String get invalidReferralCode => 'Invalid referral code';

  @override
  String get tripMembers => 'Trip Members';

  @override
  String get shareInviteCode => 'Share Invite Code';

  @override
  String get inviteCode => 'Invite Code';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopied => 'Code copied!';

  @override
  String get joinTrip => 'Join Trip';

  @override
  String get enterInviteCode => 'Enter invite code';

  @override
  String get joinTripSuccess => 'Successfully joined trip!';

  @override
  String get invalidInviteCode => 'Invalid invite code';

  @override
  String get alreadyMember => 'You\'re already a member of this trip';

  @override
  String get sharedWithYou => 'Shared with you';

  @override
  String get leaveTrip => 'Leave Trip';

  @override
  String get removeMember => 'Remove Member';

  @override
  String get confirmLeaveTrip => 'Are you sure you want to leave this trip?';

  @override
  String get tripOwner => 'Owner';

  @override
  String get tripMember => 'Member';

  @override
  String get inviteFriendsToTrip =>
      'Invite friends to collaborate on this trip!';

  @override
  String get noOtherMembers => 'No other members yet';

  @override
  String get shareCodeDescription =>
      'Share this code with friends so they can join your trip and collaborate on planning!';

  @override
  String get shareCodeInfo =>
      'Anyone with this code can join your trip and add expenses, edit the itinerary, and more.';

  @override
  String get joinTripTitle => 'Join a Trip';

  @override
  String get joinTripDescription =>
      'Enter the invite code from your friend to join their trip.';

  @override
  String get joining => 'Joining...';

  @override
  String get joinTripHelp =>
      'Ask your friend to share their trip invite code with you from the Trip Details screen.';

  @override
  String get invalidCodeLength => 'Code must be 8 characters';

  @override
  String get cannotJoinOwnTrip => 'You can\'t join your own trip';

  @override
  String get sharedTrip => 'Shared';

  @override
  String get exportJournal => 'Export Journal';

  @override
  String get chooseExportFormat => 'Choose export format:';

  @override
  String get exportPdf => 'PDF Journal';

  @override
  String get exportText => 'Text (.txt)';

  @override
  String get exportMarkdown => 'Markdown (.md)';

  @override
  String get generatingPdf => 'Generating your beautiful journal...';

  @override
  String get exportFailed => 'Export failed';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorTimeout => 'Request timed out. Please try again.';

  @override
  String get errorNoConnection =>
      'No internet connection. Please check your network.';

  @override
  String get errorServer => 'Server error. Please try again later.';

  @override
  String get errorRateLimited => 'Too many requests. Please wait a moment.';

  @override
  String get errorInvalidCredentials => 'Invalid email or password.';

  @override
  String get errorSessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get errorEmailNotVerified => 'Please verify your email address.';

  @override
  String get errorTokenLimit => 'You have reached your daily AI usage limit.';

  @override
  String get errorForbidden => 'You don\'t have permission to do this.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorNotFound => 'The requested item was not found.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get offline => 'You\'re offline';

  @override
  String get offlineMessage => 'Some features may be unavailable.';

  @override
  String get backOnline => 'You\'re back online';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get planning => 'Planning';

  @override
  String get expensesSummary => 'Expenses Summary';

  @override
  String get totalSpent => 'Total Spent';

  @override
  String get dailyAverage => 'Daily Avg';

  @override
  String get remainingBudget => 'Remaining';

  @override
  String get topCategory => 'Top Category';

  @override
  String get none => 'None';

  @override
  String get showMore => 'Show More';

  @override
  String get showLess => 'Show Less';

  @override
  String get journalReminder => 'Create Your Journal';

  @override
  String get journalReminderDescription =>
      'Your trip has ended! Tap here to create a beautiful travel journal.';

  @override
  String get expenseHistory => 'Expense History';

  @override
  String get expensesLabel => 'expenses';

  @override
  String get noExpenseHistory => 'No Expense History';

  @override
  String get noExpenseHistoryDescription =>
      'Your recorded expenses will appear here.';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteExpenseConfirmation =>
      'Are you sure you want to delete this expense? This action cannot be undone.';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get expenseUpdatedSuccess => 'Expense updated successfully!';

  @override
  String get failedToUpdateExpense => 'Failed to update expense';

  @override
  String get expenseDeletedSuccess => 'Expense deleted successfully!';

  @override
  String get failedToDeleteExpense => 'Failed to delete expense';

  @override
  String get editTrip => 'Edit Trip';

  @override
  String get tripUpdatedSuccess => 'Trip updated successfully!';

  @override
  String get failedToUpdateTrip => 'Failed to update trip';

  @override
  String get deleteTrip => 'Delete Trip';

  @override
  String get deleteTripConfirmation =>
      'Are you sure you want to delete this trip? This action cannot be undone.';

  @override
  String get deleteTripWarningTitle => 'This will permanently delete:';

  @override
  String get deleteTripExpenses => 'All expenses for this trip';

  @override
  String get deleteTripJournal => 'All journal entries';

  @override
  String get deleteTripMembers => 'Shared member access';

  @override
  String get tripDeletedSuccess => 'Trip deleted successfully!';

  @override
  String get failedToDeleteTrip => 'Failed to delete trip';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get chatDeleted => 'Chat deleted';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get discoverFeatures => 'Here\'s what you can do today';

  @override
  String get dailyTipsFeature => 'Daily Travel Tips';

  @override
  String get dailyTipsDescription =>
      'Get personalized AI-powered tips for your destination every day';

  @override
  String get multiCurrencyFeature => 'Multi-Currency Expenses';

  @override
  String get multiCurrencyDescription =>
      'Track expenses in any currency with automatic conversion to your home currency';

  @override
  String get aiChatFeature => 'AI Travel Assistant';

  @override
  String get aiChatDescription =>
      'Ask anything about your trip and get instant suggestions and recommendations';

  @override
  String get welcomeBackExplorer => 'Welcome Back, Explorer!';

  @override
  String get journeyStartsHere => 'Your journey starts here';

  @override
  String get startExploring => 'Start Exploring';

  @override
  String get maybeLater => 'Maybe later';
}
