// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Waylo';

  @override
  String get home => 'Inicio';

  @override
  String get welcomeGreetingMorning => 'Buenos dias,';

  @override
  String get welcomeGreetingAfternoon => 'Buenas tardes,';

  @override
  String get welcomeGreetingEvening => 'Buenas noches,';

  @override
  String get noActiveTrip => 'Sin Viaje Activo';

  @override
  String get startPlanningAdventure =>
      'Comienza a planificar tu proxima aventura!';

  @override
  String get createNewTrip => 'Crear Nuevo Viaje';

  @override
  String get quickActions => 'Acciones Rapidas';

  @override
  String get newTrip => 'Nuevo Viaje';

  @override
  String get addExpense => 'Agregar Gasto';

  @override
  String get aiChat => 'Chat IA';

  @override
  String get recentChats => 'Chats Recientes';

  @override
  String get recentExpenses => 'Gastos Recientes';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get startConversation => 'Inicia una conversacion con Waylo!';

  @override
  String get newChat => 'Nuevo Chat';

  @override
  String get noExpensesRecorded => 'Aun no hay gastos registrados';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get dates => 'Fechas';

  @override
  String get datesNotSet => 'Fechas no establecidas';

  @override
  String get duration => 'Duracion';

  @override
  String get notSet => 'No establecido';

  @override
  String get startsIn => 'Comienza en';

  @override
  String get status => 'Estado';

  @override
  String get completed => 'Completado';

  @override
  String get current => 'Actual';

  @override
  String get day => 'dia';

  @override
  String get days => 'dias';

  @override
  String dayOfTotal(int current, int total) {
    return 'Dia $current de $total';
  }

  @override
  String get createTrip => 'Crear Viaje';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get tripTitle => 'Titulo del Viaje';

  @override
  String get tripTitleHint => 'ej., Aventura en Paris 2025';

  @override
  String get tripTitleRequired => 'Por favor ingresa un titulo para el viaje';

  @override
  String get destination => 'Destino';

  @override
  String get destinationHint => 'Comienza a escribir un pais...';

  @override
  String get destinationRequired => 'Por favor selecciona un destino';

  @override
  String get tripDates => 'Fechas del Viaje';

  @override
  String get selectDates => 'Seleccionar fechas';

  @override
  String get pleaseSelectDates => 'Por favor selecciona las fechas del viaje';

  @override
  String get budget => 'Presupuesto';

  @override
  String get currency => 'Moneda';

  @override
  String get description => 'Descripcion';

  @override
  String get descriptionHint => 'Que te emociona de este viaje?';

  @override
  String get smartBudgetSuggestions =>
      'Sugerencias Inteligentes de Presupuesto';

  @override
  String get smartBudgetInstructions =>
      'Despues de elegir un destino y fechas, la app sugerira automaticamente un presupuesto promedio para viajeros.';

  @override
  String get estimatedDailyBudget => 'Presupuesto diario estimado:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'Basado en viajeros promedio en $destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'Total por $days dias: $amount $currency';
  }

  @override
  String get apply => 'Aplicar';

  @override
  String get tripPreview => 'Vista Previa del Viaje';

  @override
  String tripCreatedSuccess(String destination) {
    return 'Viaje a $destination creado!';
  }

  @override
  String get failedToCreateTrip => 'Error al crear el viaje';

  @override
  String get expenses => 'Gastos';

  @override
  String get amount => 'Monto';

  @override
  String get category => 'Categoria';

  @override
  String get date => 'Fecha';

  @override
  String get notes => 'Notas';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryAccommodation => 'Alojamiento';

  @override
  String get categoryFood => 'Comida';

  @override
  String get categoryActivities => 'Actividades';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryOther => 'Otro';

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Escribe un mensaje...';

  @override
  String get send => 'Enviar';

  @override
  String get trips => 'Viajes';

  @override
  String get myTrips => 'Mis Viajes';

  @override
  String get upcomingTrips => 'Proximos Viajes';

  @override
  String get pastTrips => 'Viajes Anteriores';

  @override
  String get activeTrip => 'Viaje Activo';

  @override
  String get otherTrips => 'Other Trips';

  @override
  String get noTripsYet => 'No Trips Yet';

  @override
  String get noTripsDescription =>
      'Start planning your next adventure\nby creating a new trip.';

  @override
  String get profile => 'Perfil';

  @override
  String get settings => 'Configuracion';

  @override
  String get signOut => 'Cerrar Sesion';

  @override
  String get signIn => 'Iniciar Sesion';

  @override
  String get signUp => 'Registrarse';

  @override
  String get email => 'Correo Electronico';

  @override
  String get password => 'Contrasena';

  @override
  String get fullName => 'Nombre Completo';

  @override
  String get generalSettings => 'General';

  @override
  String get appLanguage => 'Idioma de la App';

  @override
  String get defaultCurrency => 'Moneda Predeterminada';

  @override
  String get dateFormat => 'Formato de Fecha';

  @override
  String get distanceUnits => 'Unidades de Distancia';

  @override
  String get kilometers => 'Kilometros';

  @override
  String get miles => 'Millas';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get pushNotifications => 'Notificaciones Push';

  @override
  String get emailNotifications => 'Notificaciones por Correo';

  @override
  String get tripReminders => 'Recordatorios de Viaje';

  @override
  String get privacy => 'Privacidad';

  @override
  String get shareAnalytics => 'Compartir Analiticas de Uso';

  @override
  String get locationTracking => 'Seguimiento de Ubicacion';

  @override
  String get account => 'Cuenta';

  @override
  String get changePassword => 'Cambiar Contrasena';

  @override
  String get exportData => 'Exportar Mis Datos';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get deleteAccountConfirmation =>
      'Estas seguro de que deseas eliminar tu cuenta? Esta accion no se puede deshacer.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'Restablecer';

  @override
  String get about => 'Acerca de';

  @override
  String get appVersion => 'Version de la App';

  @override
  String get termsOfService => 'Terminos de Servicio';

  @override
  String get privacyPolicy => 'Politica de Privacidad';

  @override
  String get rateApp => 'Calificar la App';

  @override
  String get error => 'Error';

  @override
  String get errorOccurred => 'Ocurrio un error';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get loading => 'Cargando...';

  @override
  String get noDate => 'Sin fecha';

  @override
  String get failedToLoadChats => 'Error al cargar chats';

  @override
  String get failedToLoadExpenses => 'Error al cargar gastos';

  @override
  String get resetData => 'Restablecer Datos';

  @override
  String get resetDataTitle => 'Restablecer Datos del Usuario';

  @override
  String get resetDataMessage =>
      'Esto eliminara todos tus viajes y restablecera el estado de incorporacion. Seras redirigido para comenzar el proceso de incorporacion nuevamente.\n\nEsta accion no se puede deshacer.';

  @override
  String get dayTip => 'Consejo del Dia';

  @override
  String get dayTipDescription => 'Recomendaciones de viaje con IA';

  @override
  String get refreshTip => 'Actualizar Consejo';

  @override
  String get onboardingWelcome => 'Bienvenido a Waylo';

  @override
  String get onboardingLanguageTitle => 'Elige Tu Idioma';

  @override
  String get onboardingLanguageSubtitle =>
      'Selecciona tu idioma preferido para la app';

  @override
  String get continueButton => 'Continuar';

  @override
  String get skip => 'Omitir';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get languageEnglish => 'Ingles';

  @override
  String get languageSpanish => 'Espanol';

  @override
  String get languageFrench => 'Frances';

  @override
  String get languageGerman => 'Aleman';

  @override
  String get languageHebrew => 'Hebreo';

  @override
  String get languageJapanese => 'Japones';

  @override
  String get languageChinese => 'Chino';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Portugues';

  @override
  String get languageRussian => 'Ruso';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get chatHint => 'Preguntame cualquier cosa sobre viajes...';

  @override
  String get deleteChat => 'Eliminar Chat';

  @override
  String get deleteChatConfirmation =>
      'Estas seguro de que deseas eliminar este chat?';

  @override
  String get expenseAdded => 'Gasto agregado!';

  @override
  String get failedToAddExpense => 'Error al agregar gasto';

  @override
  String get chatWelcomeTitle => 'Hola, viajero!';

  @override
  String get chatWelcomeDescription =>
      'Soy Waylo, tu companero de viaje! Estoy aqui para ayudarte a documentar tus aventuras, planificar actividades y crear un hermoso diario de viaje.';

  @override
  String get chatWhatToDo => 'Que te gustaria hacer?';

  @override
  String get tellAboutDay => 'Cuentame sobre tu dia';

  @override
  String get tellAboutDayDescription =>
      'Comparte lo que hiciste, viste o experimentaste';

  @override
  String get tellAboutDayPrompt => 'Dejame contarte sobre mi dia...';

  @override
  String get planActivity => 'Planificar una actividad';

  @override
  String get planActivityDescription =>
      'Obtener recomendaciones de actividades';

  @override
  String get planActivityPrompt =>
      'Cuales son buenas actividades que puedo hacer aqui?';

  @override
  String get logExpenseAction => 'Registrar un gasto';

  @override
  String get logExpenseDescription => 'Seguimiento de gastos en tu viaje';

  @override
  String get logExpensePrompt => 'Quiero registrar un gasto';

  @override
  String get generateJournal => 'Generar mi diario';

  @override
  String get generateJournalDescription =>
      'Crear la entrada del diario de viaje de hoy';

  @override
  String get generateJournalPrompt =>
      'Ayudame a escribir mi diario de viaje de hoy';

  @override
  String get askAnything => 'Preguntar cualquier cosa';

  @override
  String get askAnythingDescription =>
      'Consejos de viaje, informacion local, recomendaciones';

  @override
  String get aiChats => 'Chats IA';

  @override
  String get startNewChat => 'Iniciar Nuevo Chat';

  @override
  String get aiTravelAssistant => 'Asistente de Viaje IA';

  @override
  String get aiTravelAssistantDescription =>
      'Inicia una conversacion con tu companero de viaje IA para planificar viajes, obtener recomendaciones y mas!';

  @override
  String get retry => 'Reintentar';

  @override
  String get errorDeletingChat => 'Error al eliminar chat';

  @override
  String todayAt(String time) {
    return 'Hoy a las $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ayer a las $time';
  }

  @override
  String deleteChatTitle(String title) {
    return 'Eliminar \"$title\"? Esta accion no se puede deshacer.';
  }

  @override
  String get errorCreatingChat => 'Error al crear chat';

  @override
  String get errorLoadingChat => 'Error al cargar chat';

  @override
  String get createTripForTips =>
      'Crea un viaje para obtener consejos diarios!';

  @override
  String get overview => 'Resumen';

  @override
  String expensesCount(int count) {
    return '$count gastos';
  }

  @override
  String daysTracked(int count) {
    return '$count dias registrados';
  }

  @override
  String dayTrip(int count) {
    return 'Viaje de $count dias';
  }

  @override
  String daysLeft(int count) {
    return '$count dias restantes';
  }

  @override
  String get byCategory => 'Por Categoria';

  @override
  String get spendingOverTime => 'Gastos a lo Largo del Tiempo';

  @override
  String get noExpensesYet => 'Sin Gastos Aun';

  @override
  String get startTrackingExpenses =>
      'Comienza a registrar tus gastos de viaje agregando tu primer gasto.';

  @override
  String get somethingWentWrong => 'Algo salio mal';

  @override
  String get homeCurrency => 'Moneda Local';

  @override
  String get usDollar => 'Dolar Estadounidense';

  @override
  String get localCurrency => 'Moneda del Destino';

  @override
  String get foodAndDrinks => 'Comida y Bebidas';

  @override
  String get pleaseSelectTrip => 'Por favor selecciona un viaje';

  @override
  String get expenseAddedSuccess => 'Gasto agregado exitosamente!';

  @override
  String get noTripsFound =>
      'No se encontraron viajes. Crea un viaje primero para agregar gastos.';

  @override
  String get trip => 'Viaje';

  @override
  String get pleaseEnterAmount => 'Por favor ingresa un monto';

  @override
  String get pleaseEnterValidNumber => 'Por favor ingresa un numero valido';

  @override
  String get pleaseEnterDescription => 'Por favor ingresa una descripcion';

  @override
  String get descriptionHintExpense => 'ej., Almuerzo en el Cafe';

  @override
  String get addReceiptPhoto => 'Agregar Foto del Recibo';

  @override
  String get receiptPhotoComingSoon => 'Foto del recibo proximamente!';

  @override
  String get splitThisExpense => 'Dividir este gasto?';

  @override
  String get selectTripMembersToSplit =>
      'Selecciona companeros de viaje para dividir';

  @override
  String get noTripMembersToSplit =>
      'No hay companeros de viaje. Crea un viaje primero!';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get additionalDetails => 'Cualquier detalle adicional...';

  @override
  String get countries => 'Paises';

  @override
  String get helpAndSupport => 'Ayuda y Soporte';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get legalAndPolicies => 'Legal & Policies';

  @override
  String get freePlan => 'Plan Gratuito';

  @override
  String get upgradeUnlockFeatures =>
      'Actualiza para desbloquear viajes ilimitados y funciones de IA';

  @override
  String get upgrade => 'Actualizar';

  @override
  String get signOutConfirmation =>
      'Estas seguro de que quieres cerrar sesion?';

  @override
  String get failedToSignOut => 'Error al cerrar sesion';

  @override
  String get notSignedIn => 'No has iniciado sesion';

  @override
  String get traveler => 'Viajero';

  @override
  String memberSince(String date) {
    return 'Miembro desde $date';
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
}
