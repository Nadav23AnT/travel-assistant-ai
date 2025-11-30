// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'TripBuddy';

  @override
  String get home => 'Home';

  @override
  String get welcomeGreetingMorning => 'Buongiorno,';

  @override
  String get welcomeGreetingAfternoon => 'Buon pomeriggio,';

  @override
  String get welcomeGreetingEvening => 'Buonasera,';

  @override
  String get noActiveTrip => 'Nessun Viaggio Attivo';

  @override
  String get startPlanningAdventure =>
      'Inizia a pianificare la tua prossima avventura!';

  @override
  String get createNewTrip => 'Crea Nuovo Viaggio';

  @override
  String get quickActions => 'Azioni Rapide';

  @override
  String get newTrip => 'Nuovo Viaggio';

  @override
  String get addExpense => 'Aggiungi Spesa';

  @override
  String get aiChat => 'Chat IA';

  @override
  String get recentChats => 'Chat Recenti';

  @override
  String get recentExpenses => 'Spese Recenti';

  @override
  String get viewAll => 'Vedi Tutto';

  @override
  String get startConversation => 'Inizia una conversazione con TripBuddy!';

  @override
  String get newChat => 'Nuova Chat';

  @override
  String get noExpensesRecorded => 'Nessuna spesa registrata';

  @override
  String get today => 'Oggi';

  @override
  String get yesterday => 'Ieri';

  @override
  String get dates => 'Date';

  @override
  String get datesNotSet => 'Date non impostate';

  @override
  String get duration => 'Durata';

  @override
  String get notSet => 'Non impostato';

  @override
  String get startsIn => 'Inizia tra';

  @override
  String get status => 'Stato';

  @override
  String get completed => 'Completato';

  @override
  String get current => 'Attuale';

  @override
  String get day => 'giorno';

  @override
  String get days => 'giorni';

  @override
  String dayOfTotal(int current, int total) {
    return 'Giorno $current di $total';
  }

  @override
  String get createTrip => 'Crea Viaggio';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get confirm => 'Conferma';

  @override
  String get tripTitle => 'Titolo del Viaggio';

  @override
  String get tripTitleHint => 'es., Avventura a Parigi 2025';

  @override
  String get tripTitleRequired => 'Inserisci un titolo per il viaggio';

  @override
  String get destination => 'Destinazione';

  @override
  String get destinationHint => 'Inizia a digitare un paese...';

  @override
  String get destinationRequired => 'Seleziona una destinazione';

  @override
  String get tripDates => 'Date del Viaggio';

  @override
  String get selectDates => 'Seleziona date';

  @override
  String get pleaseSelectDates => 'Seleziona le date del viaggio';

  @override
  String get budget => 'Budget';

  @override
  String get currency => 'Valuta';

  @override
  String get description => 'Descrizione';

  @override
  String get descriptionHint => 'Cosa ti entusiasma di questo viaggio?';

  @override
  String get smartBudgetSuggestions => 'Suggerimenti Budget Intelligenti';

  @override
  String get smartBudgetInstructions =>
      'Dopo aver scelto una destinazione e le date, l\'app suggerira automaticamente un budget medio per i viaggiatori.';

  @override
  String get estimatedDailyBudget => 'Budget giornaliero stimato:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'Basato sui viaggiatori medi a $destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'Totale per $days giorni: $amount $currency';
  }

  @override
  String get apply => 'Applica';

  @override
  String get tripPreview => 'Anteprima Viaggio';

  @override
  String tripCreatedSuccess(String destination) {
    return 'Viaggio a $destination creato!';
  }

  @override
  String get failedToCreateTrip => 'Creazione viaggio fallita';

  @override
  String get expenses => 'Spese';

  @override
  String get amount => 'Importo';

  @override
  String get category => 'Categoria';

  @override
  String get date => 'Data';

  @override
  String get notes => 'Note';

  @override
  String get categoryTransport => 'Trasporto';

  @override
  String get categoryAccommodation => 'Alloggio';

  @override
  String get categoryFood => 'Cibo';

  @override
  String get categoryActivities => 'Attivita';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryOther => 'Altro';

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Scrivi un messaggio...';

  @override
  String get send => 'Invia';

  @override
  String get trips => 'Viaggi';

  @override
  String get myTrips => 'I Miei Viaggi';

  @override
  String get upcomingTrips => 'Viaggi in Arrivo';

  @override
  String get pastTrips => 'Viaggi Passati';

  @override
  String get activeTrip => 'Viaggio Attivo';

  @override
  String get profile => 'Profilo';

  @override
  String get settings => 'Impostazioni';

  @override
  String get signOut => 'Esci';

  @override
  String get signIn => 'Accedi';

  @override
  String get signUp => 'Registrati';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get generalSettings => 'Generale';

  @override
  String get appLanguage => 'Lingua App';

  @override
  String get defaultCurrency => 'Valuta Predefinita';

  @override
  String get dateFormat => 'Formato Data';

  @override
  String get distanceUnits => 'Unita di Distanza';

  @override
  String get kilometers => 'Chilometri';

  @override
  String get miles => 'Miglia';

  @override
  String get darkMode => 'Modalita Scura';

  @override
  String get notifications => 'Notifiche';

  @override
  String get pushNotifications => 'Notifiche Push';

  @override
  String get emailNotifications => 'Notifiche Email';

  @override
  String get tripReminders => 'Promemoria Viaggio';

  @override
  String get privacy => 'Privacy';

  @override
  String get shareAnalytics => 'Condividi Analisi Utilizzo';

  @override
  String get locationTracking => 'Tracciamento Posizione';

  @override
  String get account => 'Account';

  @override
  String get changePassword => 'Cambia Password';

  @override
  String get exportData => 'Esporta i Miei Dati';

  @override
  String get deleteAccount => 'Elimina Account';

  @override
  String get deleteAccountConfirmation =>
      'Sei sicuro di voler eliminare il tuo account? Questa azione non puo essere annullata.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'Reimposta';

  @override
  String get about => 'Info';

  @override
  String get appVersion => 'Versione App';

  @override
  String get termsOfService => 'Termini di Servizio';

  @override
  String get privacyPolicy => 'Informativa Privacy';

  @override
  String get rateApp => 'Valuta l\'App';

  @override
  String get error => 'Errore';

  @override
  String get errorOccurred => 'Si e verificato un errore';

  @override
  String get tryAgain => 'Riprova';

  @override
  String get loading => 'Caricamento...';

  @override
  String get noDate => 'Nessuna data';

  @override
  String get failedToLoadChats => 'Caricamento chat fallito';

  @override
  String get failedToLoadExpenses => 'Caricamento spese fallito';

  @override
  String get resetData => 'Reimposta Dati';

  @override
  String get resetDataTitle => 'Reimposta Dati Utente';

  @override
  String get resetDataMessage =>
      'Questo eliminera tutti i tuoi viaggi e reimposterà lo stato di onboarding. Verrai reindirizzato per ricominciare il processo di onboarding.\n\nQuesta azione non puo essere annullata.';

  @override
  String get dayTip => 'Consiglio del Giorno';

  @override
  String get dayTipDescription => 'Consigli di viaggio basati su IA';

  @override
  String get refreshTip => 'Aggiorna Consiglio';

  @override
  String get onboardingWelcome => 'Benvenuto su TripBuddy';

  @override
  String get onboardingLanguageTitle => 'Scegli la Tua Lingua';

  @override
  String get onboardingLanguageSubtitle =>
      'Seleziona la lingua preferita per l\'app';

  @override
  String get continueButton => 'Continua';

  @override
  String get skip => 'Salta';

  @override
  String get getStarted => 'Inizia';

  @override
  String get languageEnglish => 'Inglese';

  @override
  String get languageSpanish => 'Spagnolo';

  @override
  String get languageFrench => 'Francese';

  @override
  String get languageGerman => 'Tedesco';

  @override
  String get languageHebrew => 'Ebraico';

  @override
  String get languageJapanese => 'Giapponese';

  @override
  String get languageChinese => 'Cinese';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Portoghese';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageArabic => 'Arabo';

  @override
  String get chatHint => 'Chiedimi qualsiasi cosa sui viaggi...';

  @override
  String get deleteChat => 'Elimina Chat';

  @override
  String get deleteChatConfirmation =>
      'Sei sicuro di voler eliminare questa chat?';

  @override
  String get expenseAdded => 'Spesa aggiunta!';

  @override
  String get failedToAddExpense => 'Impossibile aggiungere la spesa';

  @override
  String get chatWelcomeTitle => 'Ciao, viaggiatore!';

  @override
  String get chatWelcomeDescription =>
      'Sono TripBuddy, il tuo compagno di viaggio! Sono qui per aiutarti a documentare le tue avventure, pianificare attivita e creare un bellissimo diario di viaggio.';

  @override
  String get chatWhatToDo => 'Cosa vorresti fare?';

  @override
  String get tellAboutDay => 'Raccontami della tua giornata';

  @override
  String get tellAboutDayDescription =>
      'Condividi cosa hai fatto, visto o vissuto';

  @override
  String get tellAboutDayPrompt =>
      'Lascia che ti racconti della mia giornata...';

  @override
  String get planActivity => 'Pianifica un\'attivita';

  @override
  String get planActivityDescription =>
      'Ottieni raccomandazioni sulle attivita';

  @override
  String get planActivityPrompt =>
      'Quali sono le buone attivita che posso fare qui?';

  @override
  String get logExpenseAction => 'Registra una spesa';

  @override
  String get logExpenseDescription => 'Tieni traccia delle spese del viaggio';

  @override
  String get logExpensePrompt => 'Voglio registrare una spesa';

  @override
  String get generateJournal => 'Genera il mio diario';

  @override
  String get generateJournalDescription =>
      'Crea la voce del diario di viaggio di oggi';

  @override
  String get generateJournalPrompt =>
      'Aiutami a scrivere il mio diario di viaggio per oggi';

  @override
  String get askAnything => 'Chiedi qualsiasi cosa';

  @override
  String get askAnythingDescription =>
      'Consigli di viaggio, info locali, raccomandazioni';

  @override
  String get aiChats => 'Chat IA';

  @override
  String get startNewChat => 'Inizia Nuova Chat';

  @override
  String get aiTravelAssistant => 'Assistente di Viaggio IA';

  @override
  String get aiTravelAssistantDescription =>
      'Inizia una conversazione con il tuo compagno di viaggio IA per pianificare viaggi, ottenere raccomandazioni e altro!';

  @override
  String get retry => 'Riprova';

  @override
  String get errorDeletingChat => 'Errore nell\'eliminazione della chat';

  @override
  String todayAt(String time) {
    return 'Oggi alle $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ieri alle $time';
  }

  @override
  String deleteChatTitle(String title) {
    return 'Eliminare \"$title\"? Questa azione non puo essere annullata.';
  }

  @override
  String get errorCreatingChat => 'Errore nella creazione della chat';

  @override
  String get errorLoadingChat => 'Errore nel caricamento della chat';

  @override
  String get createTripForTips =>
      'Crea un viaggio per ricevere consigli giornalieri!';

  @override
  String get overview => 'Panoramica';

  @override
  String expensesCount(int count) {
    return '$count spese';
  }

  @override
  String daysTracked(int count) {
    return '$count giorni tracciati';
  }

  @override
  String dayTrip(int count) {
    return 'Viaggio di $count giorni';
  }

  @override
  String daysLeft(int count) {
    return '$count giorni rimanenti';
  }

  @override
  String get byCategory => 'Per Categoria';

  @override
  String get spendingOverTime => 'Spese nel Tempo';

  @override
  String get noExpensesYet => 'Nessuna Spesa Ancora';

  @override
  String get startTrackingExpenses =>
      'Inizia a monitorare le tue spese di viaggio aggiungendo la prima spesa.';

  @override
  String get somethingWentWrong => 'Qualcosa e andato storto';

  @override
  String get homeCurrency => 'Valuta Locale';

  @override
  String get usDollar => 'Dollaro Americano';

  @override
  String get localCurrency => 'Valuta di Destinazione';

  @override
  String get foodAndDrinks => 'Cibo e Bevande';

  @override
  String get pleaseSelectTrip => 'Seleziona un viaggio';

  @override
  String get expenseAddedSuccess => 'Spesa aggiunta con successo!';

  @override
  String get noTripsFound =>
      'Nessun viaggio trovato. Crea prima un viaggio per aggiungere spese.';

  @override
  String get trip => 'Viaggio';

  @override
  String get pleaseEnterAmount => 'Inserisci un importo';

  @override
  String get pleaseEnterValidNumber => 'Inserisci un numero valido';

  @override
  String get pleaseEnterDescription => 'Inserisci una descrizione';

  @override
  String get descriptionHintExpense => 'es., Pranzo al Cafe';

  @override
  String get addReceiptPhoto => 'Aggiungi Foto Ricevuta';

  @override
  String get receiptPhotoComingSoon => 'Foto ricevuta in arrivo!';

  @override
  String get splitThisExpense => 'Dividere questa spesa?';

  @override
  String get selectTripMembersToSplit =>
      'Seleziona i compagni di viaggio per dividere';

  @override
  String get noTripMembersToSplit =>
      'Nessun compagno di viaggio. Crea prima un viaggio!';

  @override
  String get notesOptional => 'Note (opzionale)';

  @override
  String get additionalDetails => 'Qualsiasi dettaglio aggiuntivo...';

  @override
  String get countries => 'Paesi';

  @override
  String get helpAndSupport => 'Aiuto e Supporto';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get freePlan => 'Piano Gratuito';

  @override
  String get upgradeUnlockFeatures =>
      'Aggiorna per sbloccare viaggi illimitati e funzionalita IA';

  @override
  String get upgrade => 'Aggiorna';

  @override
  String get signOutConfirmation => 'Sei sicuro di voler disconnetterti?';

  @override
  String get failedToSignOut => 'Disconnessione fallita';

  @override
  String get notSignedIn => 'Non connesso';

  @override
  String get traveler => 'Viaggiatore';

  @override
  String memberSince(String date) {
    return 'Membro dal $date';
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
}
