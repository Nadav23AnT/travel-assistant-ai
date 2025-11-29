// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'TripBuddy';

  @override
  String get home => 'Accueil';

  @override
  String get welcomeGreetingMorning => 'Bonjour,';

  @override
  String get welcomeGreetingAfternoon => 'Bon apres-midi,';

  @override
  String get welcomeGreetingEvening => 'Bonsoir,';

  @override
  String get noActiveTrip => 'Pas de Voyage Actif';

  @override
  String get startPlanningAdventure =>
      'Commencez a planifier votre prochaine aventure!';

  @override
  String get createNewTrip => 'Creer un Nouveau Voyage';

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get newTrip => 'Nouveau Voyage';

  @override
  String get addExpense => 'Ajouter une Depense';

  @override
  String get aiChat => 'Chat IA';

  @override
  String get recentChats => 'Chats Recents';

  @override
  String get recentExpenses => 'Depenses Recentes';

  @override
  String get viewAll => 'Voir Tout';

  @override
  String get startConversation => 'Commencez une conversation avec TripBuddy!';

  @override
  String get newChat => 'Nouveau Chat';

  @override
  String get noExpensesRecorded => 'Aucune depense enregistree';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get dates => 'Dates';

  @override
  String get datesNotSet => 'Dates non definies';

  @override
  String get duration => 'Duree';

  @override
  String get notSet => 'Non defini';

  @override
  String get startsIn => 'Commence dans';

  @override
  String get status => 'Statut';

  @override
  String get completed => 'Termine';

  @override
  String get current => 'Actuel';

  @override
  String get day => 'jour';

  @override
  String get days => 'jours';

  @override
  String dayOfTotal(int current, int total) {
    return 'Jour $current sur $total';
  }

  @override
  String get createTrip => 'Creer un Voyage';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get confirm => 'Confirmer';

  @override
  String get tripTitle => 'Titre du Voyage';

  @override
  String get tripTitleHint => 'ex., Aventure a Paris 2025';

  @override
  String get tripTitleRequired => 'Veuillez entrer un titre de voyage';

  @override
  String get destination => 'Destination';

  @override
  String get destinationHint => 'Commencez a taper un pays...';

  @override
  String get destinationRequired => 'Veuillez selectionner une destination';

  @override
  String get tripDates => 'Dates du Voyage';

  @override
  String get selectDates => 'Selectionner les dates';

  @override
  String get pleaseSelectDates => 'Veuillez selectionner les dates du voyage';

  @override
  String get budget => 'Budget';

  @override
  String get currency => 'Devise';

  @override
  String get description => 'Description';

  @override
  String get descriptionHint =>
      'Qu\'est-ce qui vous enthousiasme pour ce voyage?';

  @override
  String get smartBudgetSuggestions => 'Suggestions de Budget Intelligentes';

  @override
  String get smartBudgetInstructions =>
      'Apres avoir choisi une destination et des dates, l\'app suggerera automatiquement un budget moyen pour les voyageurs.';

  @override
  String get estimatedDailyBudget => 'Budget quotidien estime:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'Base sur les voyageurs moyens a $destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'Total pour $days jours: $amount $currency';
  }

  @override
  String get apply => 'Appliquer';

  @override
  String get tripPreview => 'Apercu du Voyage';

  @override
  String tripCreatedSuccess(String destination) {
    return 'Voyage a $destination cree!';
  }

  @override
  String get failedToCreateTrip => 'Echec de la creation du voyage';

  @override
  String get expenses => 'Depenses';

  @override
  String get amount => 'Montant';

  @override
  String get category => 'Categorie';

  @override
  String get date => 'Date';

  @override
  String get notes => 'Notes';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categoryAccommodation => 'Hebergement';

  @override
  String get categoryFood => 'Nourriture';

  @override
  String get categoryActivities => 'Activites';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryOther => 'Autre';

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Tapez un message...';

  @override
  String get send => 'Envoyer';

  @override
  String get trips => 'Voyages';

  @override
  String get myTrips => 'Mes Voyages';

  @override
  String get upcomingTrips => 'Voyages a Venir';

  @override
  String get pastTrips => 'Voyages Passes';

  @override
  String get activeTrip => 'Voyage Actif';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Parametres';

  @override
  String get signOut => 'Deconnexion';

  @override
  String get signIn => 'Connexion';

  @override
  String get signUp => 'Inscription';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get fullName => 'Nom Complet';

  @override
  String get generalSettings => 'General';

  @override
  String get appLanguage => 'Langue de l\'App';

  @override
  String get defaultCurrency => 'Devise par Defaut';

  @override
  String get dateFormat => 'Format de Date';

  @override
  String get distanceUnits => 'Unites de Distance';

  @override
  String get kilometers => 'Kilometres';

  @override
  String get miles => 'Miles';

  @override
  String get darkMode => 'Mode Sombre';

  @override
  String get notifications => 'Notifications';

  @override
  String get pushNotifications => 'Notifications Push';

  @override
  String get emailNotifications => 'Notifications par Email';

  @override
  String get tripReminders => 'Rappels de Voyage';

  @override
  String get privacy => 'Confidentialite';

  @override
  String get shareAnalytics => 'Partager les Analyses d\'Utilisation';

  @override
  String get locationTracking => 'Suivi de Localisation';

  @override
  String get account => 'Compte';

  @override
  String get changePassword => 'Changer le Mot de Passe';

  @override
  String get exportData => 'Exporter Mes Donnees';

  @override
  String get deleteAccount => 'Supprimer le Compte';

  @override
  String get deleteAccountConfirmation =>
      'Etes-vous sur de vouloir supprimer votre compte? Cette action est irreversible.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'Reinitialiser';

  @override
  String get about => 'A Propos';

  @override
  String get appVersion => 'Version de l\'App';

  @override
  String get termsOfService => 'Conditions d\'Utilisation';

  @override
  String get privacyPolicy => 'Politique de Confidentialite';

  @override
  String get rateApp => 'Noter l\'App';

  @override
  String get error => 'Erreur';

  @override
  String get errorOccurred => 'Une erreur s\'est produite';

  @override
  String get tryAgain => 'Reessayer';

  @override
  String get loading => 'Chargement...';

  @override
  String get noDate => 'Pas de date';

  @override
  String get failedToLoadChats => 'Echec du chargement des chats';

  @override
  String get failedToLoadExpenses => 'Echec du chargement des depenses';

  @override
  String get resetData => 'Reinitialiser les Donnees';

  @override
  String get resetDataTitle => 'Reinitialiser les Donnees Utilisateur';

  @override
  String get resetDataMessage =>
      'Cela supprimera tous vos voyages et reinitialiser l\'etat d\'accueil. Vous serez redirige pour recommencer le processus d\'accueil.\n\nCette action est irreversible.';

  @override
  String get dayTip => 'Conseil du Jour';

  @override
  String get dayTipDescription => 'Recommandations de voyage par IA';

  @override
  String get refreshTip => 'Actualiser le Conseil';

  @override
  String get onboardingWelcome => 'Bienvenue sur TripBuddy';

  @override
  String get onboardingLanguageTitle => 'Choisissez Votre Langue';

  @override
  String get onboardingLanguageSubtitle =>
      'Selectionnez votre langue preferee pour l\'app';

  @override
  String get continueButton => 'Continuer';

  @override
  String get skip => 'Ignorer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get languageEnglish => 'Anglais';

  @override
  String get languageSpanish => 'Espagnol';

  @override
  String get languageFrench => 'Francais';

  @override
  String get languageGerman => 'Allemand';

  @override
  String get languageHebrew => 'Hebreu';

  @override
  String get languageJapanese => 'Japonais';

  @override
  String get languageChinese => 'Chinois';

  @override
  String get languageKorean => 'Coreen';

  @override
  String get languageItalian => 'Italien';

  @override
  String get languagePortuguese => 'Portugais';

  @override
  String get languageRussian => 'Russe';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get chatHint =>
      'Posez-moi n\'importe quelle question sur les voyages...';

  @override
  String get deleteChat => 'Supprimer le Chat';

  @override
  String get deleteChatConfirmation =>
      'Etes-vous sur de vouloir supprimer ce chat?';

  @override
  String get expenseAdded => 'Depense ajoutee!';

  @override
  String get failedToAddExpense => 'Echec de l\'ajout de la depense';

  @override
  String get chatWelcomeTitle => 'Bonjour, voyageur!';

  @override
  String get chatWelcomeDescription =>
      'Je suis TripBuddy, votre compagnon de voyage! Je suis la pour vous aider a documenter vos aventures, planifier des activites et creer un beau journal de voyage.';

  @override
  String get chatWhatToDo => 'Que souhaitez-vous faire?';

  @override
  String get tellAboutDay => 'Racontez-moi votre journee';

  @override
  String get tellAboutDayDescription =>
      'Partagez ce que vous avez fait, vu ou vecu';

  @override
  String get tellAboutDayPrompt => 'Laissez-moi vous raconter ma journee...';

  @override
  String get planActivity => 'Planifier une activite';

  @override
  String get planActivityDescription =>
      'Obtenir des recommandations d\'activites';

  @override
  String get planActivityPrompt =>
      'Quelles sont les bonnes activites a faire ici?';

  @override
  String get logExpenseAction => 'Enregistrer une depense';

  @override
  String get logExpenseDescription => 'Suivre les depenses de votre voyage';

  @override
  String get logExpensePrompt => 'Je veux enregistrer une depense';

  @override
  String get generateJournal => 'Generer mon journal';

  @override
  String get generateJournalDescription =>
      'Creer l\'entree du journal de voyage d\'aujourd\'hui';

  @override
  String get generateJournalPrompt =>
      'Aidez-moi a ecrire mon journal de voyage pour aujourd\'hui';

  @override
  String get askAnything => 'Demander n\'importe quoi';

  @override
  String get askAnythingDescription =>
      'Conseils de voyage, infos locales, recommandations';

  @override
  String get aiChats => 'Chats IA';

  @override
  String get startNewChat => 'Demarrer un Nouveau Chat';

  @override
  String get aiTravelAssistant => 'Assistant de Voyage IA';

  @override
  String get aiTravelAssistantDescription =>
      'Commencez une conversation avec votre compagnon de voyage IA pour planifier des voyages, obtenir des recommandations et plus encore!';

  @override
  String get retry => 'Reessayer';

  @override
  String get errorDeletingChat => 'Erreur lors de la suppression du chat';

  @override
  String todayAt(String time) {
    return 'Aujourd\'hui a $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Hier a $time';
  }

  @override
  String deleteChatTitle(String title) {
    return 'Supprimer \"$title\"? Cette action est irreversible.';
  }

  @override
  String get errorCreatingChat => 'Erreur lors de la creation du chat';

  @override
  String get errorLoadingChat => 'Erreur lors du chargement du chat';

  @override
  String get createTripForTips =>
      'Creez un voyage pour obtenir des conseils quotidiens!';

  @override
  String get overview => 'Apercu';

  @override
  String expensesCount(int count) {
    return '$count depenses';
  }

  @override
  String daysTracked(int count) {
    return '$count jours suivis';
  }

  @override
  String dayTrip(int count) {
    return 'Voyage de $count jours';
  }

  @override
  String daysLeft(int count) {
    return '$count jours restants';
  }

  @override
  String get byCategory => 'Par Categorie';

  @override
  String get spendingOverTime => 'Depenses au Fil du Temps';

  @override
  String get noExpensesYet => 'Pas Encore de Depenses';

  @override
  String get startTrackingExpenses =>
      'Commencez a suivre vos depenses de voyage en ajoutant votre premiere depense.';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passe';

  @override
  String get homeCurrency => 'Devise Locale';

  @override
  String get usDollar => 'Dollar Americain';

  @override
  String get localCurrency => 'Devise de Destination';

  @override
  String get foodAndDrinks => 'Nourriture et Boissons';

  @override
  String get pleaseSelectTrip => 'Veuillez selectionner un voyage';

  @override
  String get expenseAddedSuccess => 'Depense ajoutee avec succes!';

  @override
  String get noTripsFound =>
      'Aucun voyage trouve. Creez d\'abord un voyage pour ajouter des depenses.';

  @override
  String get trip => 'Voyage';

  @override
  String get pleaseEnterAmount => 'Veuillez entrer un montant';

  @override
  String get pleaseEnterValidNumber => 'Veuillez entrer un nombre valide';

  @override
  String get pleaseEnterDescription => 'Veuillez entrer une description';

  @override
  String get descriptionHintExpense => 'ex., Dejeuner au Cafe';

  @override
  String get addReceiptPhoto => 'Ajouter une Photo du Recu';

  @override
  String get receiptPhotoComingSoon => 'Photo du recu bientot disponible!';

  @override
  String get splitThisExpense => 'Partager cette depense?';

  @override
  String get selectTripMembersToSplit =>
      'Selectionnez les compagnons de voyage pour partager';

  @override
  String get noTripMembersToSplit =>
      'Pas de compagnons de voyage. Creez d\'abord un voyage!';

  @override
  String get notesOptional => 'Notes (optionnel)';

  @override
  String get additionalDetails => 'Tous les details supplementaires...';

  @override
  String get countries => 'Pays';

  @override
  String get helpAndSupport => 'Aide et Support';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get freePlan => 'Plan Gratuit';

  @override
  String get upgradeUnlockFeatures =>
      'Passez a la version superieure pour debloquer des voyages illimites et des fonctionnalites IA';

  @override
  String get upgrade => 'Passer a la version superieure';

  @override
  String get signOutConfirmation =>
      'Etes-vous sur de vouloir vous deconnecter?';

  @override
  String get failedToSignOut => 'Echec de la deconnexion';

  @override
  String get notSignedIn => 'Non connecte';

  @override
  String get traveler => 'Voyageur';

  @override
  String memberSince(String date) {
    return 'Membre depuis $date';
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
