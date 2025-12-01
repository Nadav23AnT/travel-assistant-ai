// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Waylo';

  @override
  String get home => '首页';

  @override
  String get welcomeGreetingMorning => '早上好，';

  @override
  String get welcomeGreetingAfternoon => '下午好，';

  @override
  String get welcomeGreetingEvening => '晚上好，';

  @override
  String get noActiveTrip => '没有活跃行程';

  @override
  String get startPlanningAdventure => '开始规划你的下一次冒险吧！';

  @override
  String get createNewTrip => '创建新行程';

  @override
  String get quickActions => '快速操作';

  @override
  String get newTrip => '新行程';

  @override
  String get addExpense => '添加支出';

  @override
  String get aiChat => 'AI聊天';

  @override
  String get recentChats => '最近聊天';

  @override
  String get recentExpenses => '最近支出';

  @override
  String get viewAll => '查看全部';

  @override
  String get startConversation => '开始与Waylo聊天！';

  @override
  String get newChat => '新聊天';

  @override
  String get noExpensesRecorded => '尚未记录支出';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get dates => '日期';

  @override
  String get datesNotSet => '未设置日期';

  @override
  String get duration => '时长';

  @override
  String get notSet => '未设置';

  @override
  String get startsIn => '开始于';

  @override
  String get status => '状态';

  @override
  String get completed => '已完成';

  @override
  String get current => '当前';

  @override
  String get day => '天';

  @override
  String get days => '天';

  @override
  String dayOfTotal(int current, int total) {
    return '第$current天，共$total天';
  }

  @override
  String get createTrip => '创建行程';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get edit => '编辑';

  @override
  String get confirm => '确认';

  @override
  String get tripTitle => '行程标题';

  @override
  String get tripTitleHint => '例如：巴黎冒险 2025';

  @override
  String get tripTitleRequired => '请输入行程标题';

  @override
  String get destination => '目的地';

  @override
  String get destinationHint => '开始输入国家...';

  @override
  String get destinationRequired => '请选择目的地';

  @override
  String get tripDates => '行程日期';

  @override
  String get selectDates => '选择日期';

  @override
  String get pleaseSelectDates => '请选择行程日期';

  @override
  String get budget => '预算';

  @override
  String get currency => '货币';

  @override
  String get description => '描述';

  @override
  String get descriptionHint => '你对这次旅行有什么期待？';

  @override
  String get smartBudgetSuggestions => '智能预算建议';

  @override
  String get smartBudgetInstructions => '选择目的地和日期后，应用会自动建议平均旅行预算。';

  @override
  String get estimatedDailyBudget => '估计每日预算：';

  @override
  String basedOnAverageTravelers(String destination) {
    return '基于$destination的平均旅行者。';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return '$days天总计：$amount $currency';
  }

  @override
  String get apply => '应用';

  @override
  String get tripPreview => '行程预览';

  @override
  String tripCreatedSuccess(String destination) {
    return '前往$destination的行程已创建！';
  }

  @override
  String get failedToCreateTrip => '创建行程失败';

  @override
  String get expenses => '支出';

  @override
  String get amount => '金额';

  @override
  String get category => '分类';

  @override
  String get date => '日期';

  @override
  String get notes => '备注';

  @override
  String get categoryTransport => '交通';

  @override
  String get categoryAccommodation => '住宿';

  @override
  String get categoryFood => '餐饮';

  @override
  String get categoryActivities => '活动';

  @override
  String get categoryShopping => '购物';

  @override
  String get categoryOther => '其他';

  @override
  String get chat => '聊天';

  @override
  String get typeMessage => '输入消息...';

  @override
  String get send => '发送';

  @override
  String get trips => '行程';

  @override
  String get myTrips => '我的行程';

  @override
  String get upcomingTrips => '即将到来的行程';

  @override
  String get pastTrips => '过去的行程';

  @override
  String get activeTrip => '活跃行程';

  @override
  String get otherTrips => 'Other Trips';

  @override
  String get noTripsYet => 'No Trips Yet';

  @override
  String get noTripsDescription =>
      'Start planning your next adventure\nby creating a new trip.';

  @override
  String get profile => '个人资料';

  @override
  String get settings => '设置';

  @override
  String get signOut => '退出';

  @override
  String get signIn => '登录';

  @override
  String get signUp => '注册';

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get fullName => '全名';

  @override
  String get generalSettings => '常规';

  @override
  String get appLanguage => '应用语言';

  @override
  String get defaultCurrency => '默认货币';

  @override
  String get dateFormat => '日期格式';

  @override
  String get distanceUnits => '距离单位';

  @override
  String get kilometers => '公里';

  @override
  String get miles => '英里';

  @override
  String get darkMode => '深色模式';

  @override
  String get notifications => '通知';

  @override
  String get pushNotifications => '推送通知';

  @override
  String get emailNotifications => '邮件通知';

  @override
  String get tripReminders => '行程提醒';

  @override
  String get privacy => '隐私';

  @override
  String get shareAnalytics => '分享使用分析';

  @override
  String get locationTracking => '位置跟踪';

  @override
  String get account => '账户';

  @override
  String get changePassword => '修改密码';

  @override
  String get exportData => '导出我的数据';

  @override
  String get deleteAccount => '删除账户';

  @override
  String get deleteAccountConfirmation => '确定要删除账户吗？此操作不可撤销。';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => '重置';

  @override
  String get about => '关于';

  @override
  String get appVersion => '应用版本';

  @override
  String get termsOfService => '服务条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get rateApp => '评价应用';

  @override
  String get error => '错误';

  @override
  String get errorOccurred => '发生了错误';

  @override
  String get tryAgain => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get noDate => '无日期';

  @override
  String get failedToLoadChats => '加载聊天失败';

  @override
  String get failedToLoadExpenses => '加载支出失败';

  @override
  String get resetData => '重置数据';

  @override
  String get resetDataTitle => '重置用户数据';

  @override
  String get resetDataMessage => '这将删除所有行程并重置引导状态。你将被引导重新开始引导流程。\n\n此操作不可撤销。';

  @override
  String get dayTip => '今日提示';

  @override
  String get dayTipDescription => 'AI驱动的旅行建议';

  @override
  String get refreshTip => '刷新提示';

  @override
  String get onboardingWelcome => '欢迎使用Waylo';

  @override
  String get onboardingLanguageTitle => '选择你的语言';

  @override
  String get onboardingLanguageSubtitle => '选择应用界面语言';

  @override
  String get continueButton => '继续';

  @override
  String get skip => '跳过';

  @override
  String get getStarted => '开始';

  @override
  String get languageEnglish => '英语';

  @override
  String get languageSpanish => '西班牙语';

  @override
  String get languageFrench => '法语';

  @override
  String get languageGerman => '德语';

  @override
  String get languageHebrew => '希伯来语';

  @override
  String get languageJapanese => '日语';

  @override
  String get languageChinese => '中文';

  @override
  String get languageKorean => '韩语';

  @override
  String get languageItalian => '意大利语';

  @override
  String get languagePortuguese => '葡萄牙语';

  @override
  String get languageRussian => '俄语';

  @override
  String get languageArabic => '阿拉伯语';

  @override
  String get chatHint => '问我任何关于旅行的问题...';

  @override
  String get deleteChat => '删除聊天';

  @override
  String get deleteChatConfirmation => '确定要删除这个聊天吗？';

  @override
  String get expenseAdded => '支出已添加！';

  @override
  String get failedToAddExpense => '添加支出失败';

  @override
  String get chatWelcomeTitle => '你好，旅行者！';

  @override
  String get chatWelcomeDescription =>
      '我是Waylo，你的旅行伙伴！我在这里帮助你记录冒险、计划活动，并创建美丽的旅行日记。';

  @override
  String get chatWhatToDo => '你想做什么？';

  @override
  String get tellAboutDay => '告诉我你的一天';

  @override
  String get tellAboutDayDescription => '分享你做了什么、看了什么、体验了什么';

  @override
  String get tellAboutDayPrompt => '让我告诉你今天发生的事...';

  @override
  String get planActivity => '计划活动';

  @override
  String get planActivityDescription => '获取活动推荐';

  @override
  String get planActivityPrompt => '这里有什么好的活动？';

  @override
  String get logExpenseAction => '记录支出';

  @override
  String get logExpenseDescription => '跟踪旅行支出';

  @override
  String get logExpensePrompt => '我想记录一笔支出';

  @override
  String get generateJournal => '生成我的日记';

  @override
  String get generateJournalDescription => '创建今天的旅行日记';

  @override
  String get generateJournalPrompt => '帮我写今天的旅行日记';

  @override
  String get askAnything => '问任何问题';

  @override
  String get askAnythingDescription => '旅行提示、当地信息、推荐';

  @override
  String get aiChats => 'AI聊天';

  @override
  String get startNewChat => '开始新聊天';

  @override
  String get aiTravelAssistant => 'AI旅行助手';

  @override
  String get aiTravelAssistantDescription => '与你的AI旅行伙伴开始对话，计划行程、获取推荐等！';

  @override
  String get retry => '重试';

  @override
  String get errorDeletingChat => '删除聊天时出错';

  @override
  String todayAt(String time) {
    return '今天 $time';
  }

  @override
  String yesterdayAt(String time) {
    return '昨天 $time';
  }

  @override
  String deleteChatTitle(String title) {
    return '删除「$title」？此操作不可撤销。';
  }

  @override
  String get errorCreatingChat => '创建聊天时出错';

  @override
  String get errorLoadingChat => '加载聊天时出错';

  @override
  String get createTripForTips => '创建行程以获取每日提示！';

  @override
  String get overview => '概览';

  @override
  String expensesCount(int count) {
    return '$count笔支出';
  }

  @override
  String daysTracked(int count) {
    return '已跟踪$count天';
  }

  @override
  String dayTrip(int count) {
    return '$count天行程';
  }

  @override
  String daysLeft(int count) {
    return '剩余$count天';
  }

  @override
  String get byCategory => '按类别';

  @override
  String get spendingOverTime => '随时间支出';

  @override
  String get noExpensesYet => '暂无支出';

  @override
  String get startTrackingExpenses => '添加您的第一笔支出，开始跟踪旅行开销。';

  @override
  String get somethingWentWrong => '出现了问题';

  @override
  String get homeCurrency => '本国货币';

  @override
  String get usDollar => '美元';

  @override
  String get localCurrency => '当地货币';

  @override
  String get foodAndDrinks => '餐饮';

  @override
  String get pleaseSelectTrip => '请选择一个行程';

  @override
  String get expenseAddedSuccess => '支出添加成功！';

  @override
  String get noTripsFound => '未找到行程。请先创建一个行程以添加支出。';

  @override
  String get trip => '行程';

  @override
  String get pleaseEnterAmount => '请输入金额';

  @override
  String get pleaseEnterValidNumber => '请输入有效数字';

  @override
  String get pleaseEnterDescription => '请输入描述';

  @override
  String get descriptionHintExpense => '例如：咖啡厅午餐';

  @override
  String get addReceiptPhoto => '添加收据照片';

  @override
  String get receiptPhotoComingSoon => '收据照片功能即将推出！';

  @override
  String get splitThisExpense => '分摊此支出？';

  @override
  String get selectTripMembersToSplit => '选择要分摊的旅伴';

  @override
  String get noTripMembersToSplit => '没有旅伴可分摊。请先创建行程！';

  @override
  String get notesOptional => '备注（可选）';

  @override
  String get additionalDetails => '任何其他详情...';

  @override
  String get countries => '国家';

  @override
  String get helpAndSupport => '帮助与支持';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get freePlan => '免费计划';

  @override
  String get upgradeUnlockFeatures => '升级以解锁无限行程和AI功能';

  @override
  String get upgrade => '升级';

  @override
  String get signOutConfirmation => '确定要退出登录吗？';

  @override
  String get failedToSignOut => '退出登录失败';

  @override
  String get notSignedIn => '未登录';

  @override
  String get traveler => '旅行者';

  @override
  String memberSince(String date) {
    return '会员自 $date';
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
}
