// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Waylo';

  @override
  String get home => 'Início';

  @override
  String get welcomeGreetingMorning => 'Bom dia,';

  @override
  String get welcomeGreetingAfternoon => 'Boa tarde,';

  @override
  String get welcomeGreetingEvening => 'Boa noite,';

  @override
  String get noActiveTrip => 'Nenhuma Viagem Ativa';

  @override
  String get startPlanningAdventure =>
      'Comece a planejar sua proxima aventura!';

  @override
  String get createNewTrip => 'Criar Nova Viagem';

  @override
  String get quickActions => 'Acoes Rapidas';

  @override
  String get newTrip => 'Nova Viagem';

  @override
  String get addExpense => 'Adicionar Despesa';

  @override
  String get aiChat => 'Chat IA';

  @override
  String get recentChats => 'Chats Recentes';

  @override
  String get recentExpenses => 'Despesas Recentes';

  @override
  String get viewAll => 'Ver Tudo';

  @override
  String get startConversation => 'Inicie uma conversa com Waylo!';

  @override
  String get newChat => 'Novo Chat';

  @override
  String get noExpensesRecorded => 'Nenhuma despesa registrada';

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get dates => 'Datas';

  @override
  String get datesNotSet => 'Datas nao definidas';

  @override
  String get duration => 'Duracao';

  @override
  String get notSet => 'Nao definido';

  @override
  String get startsIn => 'Comeca em';

  @override
  String get status => 'Status';

  @override
  String get completed => 'Concluido';

  @override
  String get current => 'Atual';

  @override
  String get day => 'dia';

  @override
  String get days => 'dias';

  @override
  String dayOfTotal(int current, int total) {
    return 'Dia $current de $total';
  }

  @override
  String get createTrip => 'Criar Viagem';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get tripTitle => 'Titulo da Viagem';

  @override
  String get tripTitleHint => 'ex., Aventura em Paris 2025';

  @override
  String get tripTitleRequired => 'Por favor, insira um titulo para a viagem';

  @override
  String get destination => 'Destino';

  @override
  String get destinationHint => 'Comece a digitar um pais...';

  @override
  String get destinationRequired => 'Por favor, selecione um destino';

  @override
  String get tripDates => 'Datas da Viagem';

  @override
  String get selectDates => 'Selecionar datas';

  @override
  String get pleaseSelectDates => 'Por favor, selecione as datas da viagem';

  @override
  String get budget => 'Orcamento';

  @override
  String get currency => 'Moeda';

  @override
  String get description => 'Descricao';

  @override
  String get descriptionHint => 'O que te empolga nesta viagem?';

  @override
  String get smartBudgetSuggestions => 'Sugestoes de Orcamento Inteligentes';

  @override
  String get smartBudgetInstructions =>
      'Apos escolher um destino e datas, o app sugerira automaticamente um orcamento medio para viajantes.';

  @override
  String get estimatedDailyBudget => 'Orcamento diario estimado:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'Baseado em viajantes medios em $destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'Total para $days dias: $amount $currency';
  }

  @override
  String get apply => 'Aplicar';

  @override
  String get tripPreview => 'Previa da Viagem';

  @override
  String tripCreatedSuccess(String destination) {
    return 'Viagem para $destination criada!';
  }

  @override
  String get failedToCreateTrip => 'Falha ao criar viagem';

  @override
  String get expenses => 'Despesas';

  @override
  String get amount => 'Valor';

  @override
  String get category => 'Categoria';

  @override
  String get date => 'Data';

  @override
  String get notes => 'Notas';

  @override
  String get categoryTransport => 'Transporte';

  @override
  String get categoryAccommodation => 'Hospedagem';

  @override
  String get categoryFood => 'Alimentacao';

  @override
  String get categoryActivities => 'Atividades';

  @override
  String get categoryShopping => 'Compras';

  @override
  String get categoryOther => 'Outro';

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Digite uma mensagem...';

  @override
  String get send => 'Enviar';

  @override
  String get trips => 'Viagens';

  @override
  String get myTrips => 'Minhas Viagens';

  @override
  String get upcomingTrips => 'Proximas Viagens';

  @override
  String get pastTrips => 'Viagens Anteriores';

  @override
  String get activeTrip => 'Viagem Ativa';

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
  String get settings => 'Configuracoes';

  @override
  String get signOut => 'Sair';

  @override
  String get signIn => 'Entrar';

  @override
  String get signUp => 'Cadastrar';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get generalSettings => 'Geral';

  @override
  String get appLanguage => 'Idioma do App';

  @override
  String get defaultCurrency => 'Moeda Padrao';

  @override
  String get dateFormat => 'Formato de Data';

  @override
  String get distanceUnits => 'Unidades de Distancia';

  @override
  String get kilometers => 'Quilometros';

  @override
  String get miles => 'Milhas';

  @override
  String get darkMode => 'Modo Escuro';

  @override
  String get notifications => 'Notificacoes';

  @override
  String get pushNotifications => 'Notificacoes Push';

  @override
  String get emailNotifications => 'Notificacoes por E-mail';

  @override
  String get tripReminders => 'Lembretes de Viagem';

  @override
  String get privacy => 'Privacidade';

  @override
  String get shareAnalytics => 'Compartilhar Analiticos de Uso';

  @override
  String get locationTracking => 'Rastreamento de Localizacao';

  @override
  String get account => 'Conta';

  @override
  String get changePassword => 'Alterar Senha';

  @override
  String get exportData => 'Exportar Meus Dados';

  @override
  String get deleteAccount => 'Excluir Conta';

  @override
  String get deleteAccountConfirmation =>
      'Tem certeza de que deseja excluir sua conta? Esta acao nao pode ser desfeita.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'Redefinir';

  @override
  String get about => 'Sobre';

  @override
  String get appVersion => 'Versao do App';

  @override
  String get termsOfService => 'Termos de Servico';

  @override
  String get privacyPolicy => 'Politica de Privacidade';

  @override
  String get rateApp => 'Avaliar o App';

  @override
  String get error => 'Erro';

  @override
  String get errorOccurred => 'Ocorreu um erro';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get loading => 'Carregando...';

  @override
  String get noDate => 'Sem data';

  @override
  String get failedToLoadChats => 'Falha ao carregar chats';

  @override
  String get failedToLoadExpenses => 'Falha ao carregar despesas';

  @override
  String get resetData => 'Redefinir Dados';

  @override
  String get resetDataTitle => 'Redefinir Dados do Usuario';

  @override
  String get resetDataMessage =>
      'Isso excluira todas as suas viagens e redefinira o status de integracao. Voce sera redirecionado para iniciar o processo de integracao novamente.\n\nEsta acao nao pode ser desfeita.';

  @override
  String get dayTip => 'Dica do Dia';

  @override
  String get dayTipDescription => 'Recomendacoes de viagem com IA';

  @override
  String get refreshTip => 'Atualizar Dica';

  @override
  String get onboardingWelcome => 'Bem-vindo ao Waylo';

  @override
  String get onboardingLanguageTitle => 'Escolha Seu Idioma';

  @override
  String get onboardingLanguageSubtitle =>
      'Selecione seu idioma preferido para o app';

  @override
  String get continueButton => 'Continuar';

  @override
  String get skip => 'Pular';

  @override
  String get getStarted => 'Comecar';

  @override
  String get languageEnglish => 'Ingles';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageFrench => 'Frances';

  @override
  String get languageGerman => 'Alemao';

  @override
  String get languageHebrew => 'Hebraico';

  @override
  String get languageJapanese => 'Japones';

  @override
  String get languageChinese => 'Chines';

  @override
  String get languageKorean => 'Coreano';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languagePortuguese => 'Portugues';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageArabic => 'Arabe';

  @override
  String get chatHint => 'Pergunte-me qualquer coisa sobre viagens...';

  @override
  String get deleteChat => 'Excluir Chat';

  @override
  String get deleteChatConfirmation =>
      'Tem certeza de que deseja excluir este chat?';

  @override
  String get expenseAdded => 'Despesa adicionada!';

  @override
  String get failedToAddExpense => 'Falha ao adicionar despesa';

  @override
  String get chatWelcomeTitle => 'Ola, viajante!';

  @override
  String get chatWelcomeDescription =>
      'Sou o Waylo, seu companheiro de viagem! Estou aqui para ajudar voce a documentar suas aventuras, planejar atividades e criar um lindo diario de viagem.';

  @override
  String get chatWhatToDo => 'O que voce gostaria de fazer?';

  @override
  String get tellAboutDay => 'Conte-me sobre seu dia';

  @override
  String get tellAboutDayDescription =>
      'Compartilhe o que voce fez, viu ou experimentou';

  @override
  String get tellAboutDayPrompt => 'Deixe-me contar sobre meu dia...';

  @override
  String get planActivity => 'Planejar uma atividade';

  @override
  String get planActivityDescription => 'Obter recomendacoes de atividades';

  @override
  String get planActivityPrompt =>
      'Quais sao boas atividades que posso fazer aqui?';

  @override
  String get logExpenseAction => 'Registrar uma despesa';

  @override
  String get logExpenseDescription => 'Rastrear gastos na sua viagem';

  @override
  String get logExpensePrompt => 'Quero registrar uma despesa';

  @override
  String get generateJournal => 'Gerar meu diario';

  @override
  String get generateJournalDescription =>
      'Criar a entrada do diario de viagem de hoje';

  @override
  String get generateJournalPrompt =>
      'Ajude-me a escrever meu diario de viagem de hoje';

  @override
  String get askAnything => 'Perguntar qualquer coisa';

  @override
  String get askAnythingDescription =>
      'Dicas de viagem, informacoes locais, recomendacoes';

  @override
  String get aiChats => 'Chats IA';

  @override
  String get startNewChat => 'Iniciar Novo Chat';

  @override
  String get aiTravelAssistant => 'Assistente de Viagem IA';

  @override
  String get aiTravelAssistantDescription =>
      'Inicie uma conversa com seu companheiro de viagem IA para planejar viagens, obter recomendacoes e mais!';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get errorDeletingChat => 'Erro ao excluir chat';

  @override
  String todayAt(String time) {
    return 'Hoje as $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'Ontem as $time';
  }

  @override
  String deleteChatTitle(String title) {
    return 'Excluir \"$title\"? Esta acao nao pode ser desfeita.';
  }

  @override
  String get errorCreatingChat => 'Erro ao criar chat';

  @override
  String get errorLoadingChat => 'Erro ao carregar chat';

  @override
  String get createTripForTips => 'Crie uma viagem para receber dicas diarias!';

  @override
  String get overview => 'Visao Geral';

  @override
  String expensesCount(int count) {
    return '$count despesas';
  }

  @override
  String daysTracked(int count) {
    return '$count dias rastreados';
  }

  @override
  String dayTrip(int count) {
    return 'Viagem de $count dias';
  }

  @override
  String daysLeft(int count) {
    return '$count dias restantes';
  }

  @override
  String get byCategory => 'Por Categoria';

  @override
  String get spendingOverTime => 'Gastos ao Longo do Tempo';

  @override
  String get noExpensesYet => 'Sem Despesas Ainda';

  @override
  String get startTrackingExpenses =>
      'Comece a rastrear suas despesas de viagem adicionando sua primeira despesa.';

  @override
  String get somethingWentWrong => 'Algo deu errado';

  @override
  String get homeCurrency => 'Moeda Local';

  @override
  String get usDollar => 'Dolar Americano';

  @override
  String get localCurrency => 'Moeda do Destino';

  @override
  String get foodAndDrinks => 'Comida e Bebidas';

  @override
  String get pleaseSelectTrip => 'Selecione uma viagem';

  @override
  String get expenseAddedSuccess => 'Despesa adicionada com sucesso!';

  @override
  String get noTripsFound =>
      'Nenhuma viagem encontrada. Crie uma viagem primeiro para adicionar despesas.';

  @override
  String get trip => 'Viagem';

  @override
  String get pleaseEnterAmount => 'Digite um valor';

  @override
  String get pleaseEnterValidNumber => 'Digite um numero valido';

  @override
  String get pleaseEnterDescription => 'Digite uma descricao';

  @override
  String get descriptionHintExpense => 'ex., Almoco no Cafe';

  @override
  String get addReceiptPhoto => 'Adicionar Foto do Recibo';

  @override
  String get receiptPhotoComingSoon => 'Foto do recibo em breve!';

  @override
  String get splitThisExpense => 'Dividir esta despesa?';

  @override
  String get selectTripMembersToSplit =>
      'Selecione os companheiros de viagem para dividir';

  @override
  String get noTripMembersToSplit =>
      'Sem companheiros de viagem. Crie uma viagem primeiro!';

  @override
  String get notesOptional => 'Notas (opcional)';

  @override
  String get additionalDetails => 'Quaisquer detalhes adicionais...';

  @override
  String get countries => 'Paises';

  @override
  String get helpAndSupport => 'Ajuda e Suporte';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get legalAndPolicies => 'Legal & Policies';

  @override
  String get freePlan => 'Plano Gratuito';

  @override
  String get upgradeUnlockFeatures =>
      'Atualize para desbloquear viagens ilimitadas e recursos de IA';

  @override
  String get upgrade => 'Atualizar';

  @override
  String get signOutConfirmation => 'Tem certeza de que deseja sair?';

  @override
  String get failedToSignOut => 'Falha ao sair';

  @override
  String get notSignedIn => 'Nao conectado';

  @override
  String get traveler => 'Viajante';

  @override
  String memberSince(String date) {
    return 'Membro desde $date';
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
