// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'TripBuddy';

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
  String get startConversation => 'Inicia una conversacion con TripBuddy!';

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
  String get reset => 'Restablecer';

  @override
  String get dayTip => 'Consejo del Dia';

  @override
  String get dayTipDescription => 'Recomendaciones de viaje con IA';

  @override
  String get refreshTip => 'Actualizar Consejo';

  @override
  String get onboardingWelcome => 'Bienvenido a TripBuddy';

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
      'Soy TripBuddy, tu companero de viaje! Estoy aqui para ayudarte a documentar tus aventuras, planificar actividades y crear un hermoso diario de viaje.';

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
}
