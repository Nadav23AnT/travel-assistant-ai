// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Waylo';

  @override
  String get home => 'Главная';

  @override
  String get welcomeGreetingMorning => 'Доброе утро,';

  @override
  String get welcomeGreetingAfternoon => 'Добрый день,';

  @override
  String get welcomeGreetingEvening => 'Добрый вечер,';

  @override
  String get noActiveTrip => 'Нет активных поездок';

  @override
  String get startPlanningAdventure =>
      'Начните планировать следующее приключение!';

  @override
  String get createNewTrip => 'Создать новую поездку';

  @override
  String get quickActions => 'Быстрые действия';

  @override
  String get newTrip => 'Новая поездка';

  @override
  String get addExpense => 'Добавить расход';

  @override
  String get aiChat => 'AI чат';

  @override
  String get recentChats => 'Недавние чаты';

  @override
  String get recentExpenses => 'Недавние расходы';

  @override
  String get viewAll => 'Посмотреть все';

  @override
  String get startConversation => 'Начните разговор с Waylo!';

  @override
  String get newChat => 'Новый чат';

  @override
  String get noExpensesRecorded => 'Нет записанных расходов';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get dates => 'Даты';

  @override
  String get datesNotSet => 'Даты не установлены';

  @override
  String get duration => 'Продолжительность';

  @override
  String get notSet => 'Не установлено';

  @override
  String get startsIn => 'Начинается через';

  @override
  String get status => 'Статус';

  @override
  String get completed => 'Завершено';

  @override
  String get current => 'Текущий';

  @override
  String get day => 'день';

  @override
  String get days => 'дней';

  @override
  String dayOfTotal(int current, int total) {
    return 'День $current из $total';
  }

  @override
  String get createTrip => 'Создать поездку';

  @override
  String get save => 'Сохранить';

  @override
  String get cancel => 'Отмена';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get tripTitle => 'Название поездки';

  @override
  String get tripTitleHint => 'напр., Приключение в Париже 2025';

  @override
  String get tripTitleRequired => 'Пожалуйста, введите название поездки';

  @override
  String get destination => 'Назначение';

  @override
  String get destinationHint => 'Начните вводить страну...';

  @override
  String get destinationRequired => 'Пожалуйста, выберите назначение';

  @override
  String get tripDates => 'Даты поездки';

  @override
  String get selectDates => 'Выбрать даты';

  @override
  String get pleaseSelectDates => 'Пожалуйста, выберите даты поездки';

  @override
  String get budget => 'Бюджет';

  @override
  String get currency => 'Валюта';

  @override
  String get description => 'Описание';

  @override
  String get descriptionHint => 'Что вас вдохновляет в этой поездке?';

  @override
  String get smartBudgetSuggestions => 'Умные предложения по бюджету';

  @override
  String get smartBudgetInstructions =>
      'После выбора назначения и дат приложение автоматически предложит средний бюджет для путешественников.';

  @override
  String get estimatedDailyBudget => 'Предполагаемый дневной бюджет:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'На основе средних путешественников в $destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'Всего за $days дней: $amount $currency';
  }

  @override
  String get apply => 'Применить';

  @override
  String get tripPreview => 'Предпросмотр поездки';

  @override
  String tripCreatedSuccess(String destination) {
    return 'Поездка в $destination создана!';
  }

  @override
  String get failedToCreateTrip => 'Не удалось создать поездку';

  @override
  String get expenses => 'Расходы';

  @override
  String get amount => 'Сумма';

  @override
  String get category => 'Категория';

  @override
  String get date => 'Дата';

  @override
  String get notes => 'Заметки';

  @override
  String get categoryTransport => 'Транспорт';

  @override
  String get categoryAccommodation => 'Проживание';

  @override
  String get categoryFood => 'Еда';

  @override
  String get categoryActivities => 'Активности';

  @override
  String get categoryShopping => 'Покупки';

  @override
  String get categoryOther => 'Другое';

  @override
  String get chat => 'Чат';

  @override
  String get typeMessage => 'Введите сообщение...';

  @override
  String get send => 'Отправить';

  @override
  String get trips => 'Поездки';

  @override
  String get myTrips => 'Мои поездки';

  @override
  String get upcomingTrips => 'Предстоящие поездки';

  @override
  String get pastTrips => 'Прошлые поездки';

  @override
  String get activeTrip => 'Активная поездка';

  @override
  String get otherTrips => 'Other Trips';

  @override
  String get noTripsYet => 'No Trips Yet';

  @override
  String get noTripsDescription =>
      'Start planning your next adventure\nby creating a new trip.';

  @override
  String get profile => 'Профиль';

  @override
  String get settings => 'Настройки';

  @override
  String get signOut => 'Выйти';

  @override
  String get signIn => 'Войти';

  @override
  String get signUp => 'Регистрация';

  @override
  String get email => 'Email';

  @override
  String get password => 'Пароль';

  @override
  String get fullName => 'Полное имя';

  @override
  String get generalSettings => 'Основные';

  @override
  String get appLanguage => 'Язык приложения';

  @override
  String get defaultCurrency => 'Валюта по умолчанию';

  @override
  String get dateFormat => 'Формат даты';

  @override
  String get distanceUnits => 'Единицы расстояния';

  @override
  String get kilometers => 'Километры';

  @override
  String get miles => 'Мили';

  @override
  String get darkMode => 'Темный режим';

  @override
  String get notifications => 'Уведомления';

  @override
  String get pushNotifications => 'Push-уведомления';

  @override
  String get emailNotifications => 'Email-уведомления';

  @override
  String get tripReminders => 'Напоминания о поездке';

  @override
  String get privacy => 'Конфиденциальность';

  @override
  String get shareAnalytics => 'Поделиться аналитикой использования';

  @override
  String get locationTracking => 'Отслеживание местоположения';

  @override
  String get account => 'Аккаунт';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get exportData => 'Экспортировать мои данные';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountConfirmation =>
      'Вы уверены, что хотите удалить свой аккаунт? Это действие невозможно отменить.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'Сбросить';

  @override
  String get about => 'О приложении';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get termsOfService => 'Условия использования';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get rateApp => 'Оценить приложение';

  @override
  String get error => 'Ошибка';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get tryAgain => 'Повторить';

  @override
  String get loading => 'Загрузка...';

  @override
  String get noDate => 'Нет даты';

  @override
  String get failedToLoadChats => 'Не удалось загрузить чаты';

  @override
  String get failedToLoadExpenses => 'Не удалось загрузить расходы';

  @override
  String get resetData => 'Сбросить данные';

  @override
  String get resetDataTitle => 'Сбросить данные пользователя';

  @override
  String get resetDataMessage =>
      'Это удалит все ваши поездки и сбросит статус регистрации. Вы будете перенаправлены для повторного прохождения регистрации.\n\nЭто действие невозможно отменить.';

  @override
  String get dayTip => 'Совет дня';

  @override
  String get dayTipDescription => 'Рекомендации по путешествиям на основе AI';

  @override
  String get refreshTip => 'Обновить совет';

  @override
  String get onboardingWelcome => 'Добро пожаловать в Waylo';

  @override
  String get onboardingLanguageTitle => 'Выберите свой язык';

  @override
  String get onboardingLanguageSubtitle =>
      'Выберите предпочтительный язык для приложения';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get skip => 'Пропустить';

  @override
  String get getStarted => 'Начать';

  @override
  String get languageEnglish => 'Английский';

  @override
  String get languageSpanish => 'Испанский';

  @override
  String get languageFrench => 'Французский';

  @override
  String get languageGerman => 'Немецкий';

  @override
  String get languageHebrew => 'Иврит';

  @override
  String get languageJapanese => 'Японский';

  @override
  String get languageChinese => 'Китайский';

  @override
  String get languageKorean => 'Корейский';

  @override
  String get languageItalian => 'Итальянский';

  @override
  String get languagePortuguese => 'Португальский';

  @override
  String get languageRussian => 'Русский';

  @override
  String get languageArabic => 'Арабский';

  @override
  String get chatHint => 'Спросите меня о путешествиях...';

  @override
  String get deleteChat => 'Удалить чат';

  @override
  String get deleteChatConfirmation =>
      'Вы уверены, что хотите удалить этот чат?';

  @override
  String get expenseAdded => 'Расход добавлен!';

  @override
  String get failedToAddExpense => 'Не удалось добавить расход';

  @override
  String get chatWelcomeTitle => 'Привет, путешественник!';

  @override
  String get chatWelcomeDescription =>
      'Я Waylo, ваш спутник в путешествии! Я здесь, чтобы помочь вам документировать приключения, планировать активности и создавать красивый дневник путешествий.';

  @override
  String get chatWhatToDo => 'Что вы хотите сделать?';

  @override
  String get tellAboutDay => 'Расскажите о своем дне';

  @override
  String get tellAboutDayDescription =>
      'Поделитесь тем, что вы делали, видели или пережили';

  @override
  String get tellAboutDayPrompt => 'Позвольте рассказать о моем дне...';

  @override
  String get planActivity => 'Спланировать активность';

  @override
  String get planActivityDescription => 'Получить рекомендации по активностям';

  @override
  String get planActivityPrompt =>
      'Какие хорошие активности я могу здесь сделать?';

  @override
  String get logExpenseAction => 'Записать расход';

  @override
  String get logExpenseDescription => 'Отслеживать расходы в поездке';

  @override
  String get logExpensePrompt => 'Я хочу записать расход';

  @override
  String get generateJournal => 'Создать мой дневник';

  @override
  String get generateJournalDescription =>
      'Создать запись в дневнике путешествий за сегодня';

  @override
  String get generateJournalPrompt =>
      'Помогите мне написать мой дневник путешествий за сегодня';

  @override
  String get askAnything => 'Спросить что угодно';

  @override
  String get askAnythingDescription =>
      'Советы по путешествиям, местная информация, рекомендации';

  @override
  String get aiChats => 'AI чаты';

  @override
  String get startNewChat => 'Начать новый чат';

  @override
  String get aiTravelAssistant => 'AI помощник в путешествиях';

  @override
  String get aiTravelAssistantDescription =>
      'Начните разговор с вашим AI спутником, чтобы планировать поездки, получать рекомендации и многое другое!';

  @override
  String get retry => 'Повторить';

  @override
  String get errorDeletingChat => 'Ошибка удаления чата';

  @override
  String todayAt(String time) {
    return 'Сегодня в $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Вчера в $time';
  }

  @override
  String deleteChatTitle(String title) {
    return 'Удалить «$title»? Это действие невозможно отменить.';
  }

  @override
  String get errorCreatingChat => 'Ошибка создания чата';

  @override
  String get errorLoadingChat => 'Ошибка загрузки чата';

  @override
  String get createTripForTips =>
      'Создайте поездку, чтобы получать ежедневные советы!';

  @override
  String get overview => 'Обзор';

  @override
  String expensesCount(int count) {
    return '$count расходов';
  }

  @override
  String daysTracked(int count) {
    return 'Отслежено $count дней';
  }

  @override
  String dayTrip(int count) {
    return 'Поездка на $count дней';
  }

  @override
  String daysLeft(int count) {
    return 'Осталось $count дней';
  }

  @override
  String get byCategory => 'По категориям';

  @override
  String get spendingOverTime => 'Расходы со временем';

  @override
  String get noExpensesYet => 'Пока нет расходов';

  @override
  String get startTrackingExpenses =>
      'Начните отслеживать расходы в путешествии, добавив первый расход.';

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get homeCurrency => 'Домашняя валюта';

  @override
  String get usDollar => 'Доллар США';

  @override
  String get localCurrency => 'Местная валюта';

  @override
  String get foodAndDrinks => 'Еда и напитки';

  @override
  String get pleaseSelectTrip => 'Пожалуйста, выберите поездку';

  @override
  String get expenseAddedSuccess => 'Расход успешно добавлен!';

  @override
  String get noTripsFound =>
      'Поездки не найдены. Сначала создайте поездку, чтобы добавить расходы.';

  @override
  String get trip => 'Поездка';

  @override
  String get pleaseEnterAmount => 'Пожалуйста, введите сумму';

  @override
  String get pleaseEnterValidNumber => 'Пожалуйста, введите корректное число';

  @override
  String get pleaseEnterDescription => 'Пожалуйста, введите описание';

  @override
  String get descriptionHintExpense => 'напр., Обед в кафе';

  @override
  String get addReceiptPhoto => 'Добавить фото чека';

  @override
  String get receiptPhotoComingSoon => 'Фото чека скоро!';

  @override
  String get splitThisExpense => 'Разделить этот расход?';

  @override
  String get selectTripMembersToSplit => 'Выберите попутчиков для разделения';

  @override
  String get noTripMembersToSplit =>
      'Нет попутчиков для разделения. Сначала создайте поездку!';

  @override
  String get notesOptional => 'Заметки (необязательно)';

  @override
  String get additionalDetails => 'Любые дополнительные детали...';

  @override
  String get countries => 'Страны';

  @override
  String get helpAndSupport => 'Помощь и поддержка';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get legalAndPolicies => 'Legal & Policies';

  @override
  String get freePlan => 'Бесплатный план';

  @override
  String get upgradeUnlockFeatures =>
      'Обновите, чтобы разблокировать неограниченные поездки и функции AI';

  @override
  String get upgrade => 'Обновить';

  @override
  String get signOutConfirmation => 'Вы уверены, что хотите выйти?';

  @override
  String get failedToSignOut => 'Не удалось выйти';

  @override
  String get notSignedIn => 'Не авторизован';

  @override
  String get traveler => 'Путешественник';

  @override
  String memberSince(String date) {
    return 'Участник с $date';
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
