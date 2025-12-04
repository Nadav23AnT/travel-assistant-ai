// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Waylo';

  @override
  String get home => 'ホーム';

  @override
  String get welcomeGreetingMorning => 'おはようございます、';

  @override
  String get welcomeGreetingAfternoon => 'こんにちは、';

  @override
  String get welcomeGreetingEvening => 'こんばんは、';

  @override
  String get noActiveTrip => 'アクティブな旅行はありません';

  @override
  String get startPlanningAdventure => '次の冒険を計画しましょう！';

  @override
  String get createNewTrip => '新しい旅行を作成';

  @override
  String get quickActions => 'クイックアクション';

  @override
  String get newTrip => '新しい旅行';

  @override
  String get addExpense => '支出を追加';

  @override
  String get aiChat => 'AIチャット';

  @override
  String get recentChats => '最近のチャット';

  @override
  String get recentExpenses => '最近の支出';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get startConversation => 'Wayloと会話を始めましょう！';

  @override
  String get newChat => '新しいチャット';

  @override
  String get noExpensesRecorded => '支出は記録されていません';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get dates => '日付';

  @override
  String get datesNotSet => '日付が設定されていません';

  @override
  String get duration => '期間';

  @override
  String get notSet => '未設定';

  @override
  String get startsIn => '開始まで';

  @override
  String get status => 'ステータス';

  @override
  String get completed => '完了';

  @override
  String get current => '現在';

  @override
  String get day => '日';

  @override
  String get days => '日間';

  @override
  String dayOfTotal(int current, int total) {
    return '$current日目 / $total日間';
  }

  @override
  String get createTrip => '旅行を作成';

  @override
  String get save => '保存';

  @override
  String get cancel => 'キャンセル';

  @override
  String get delete => '削除';

  @override
  String get edit => '編集';

  @override
  String get confirm => '確認';

  @override
  String get tripTitle => '旅行のタイトル';

  @override
  String get tripTitleHint => '例: パリの冒険 2025';

  @override
  String get tripTitleRequired => '旅行のタイトルを入力してください';

  @override
  String get destination => '目的地';

  @override
  String get destinationHint => '国名を入力してください...';

  @override
  String get destinationRequired => '目的地を選択してください';

  @override
  String get tripDates => '旅行の日程';

  @override
  String get selectDates => '日付を選択';

  @override
  String get pleaseSelectDates => '旅行の日程を選択してください';

  @override
  String get budget => '予算';

  @override
  String get currency => '通貨';

  @override
  String get description => '説明';

  @override
  String get descriptionHint => 'この旅行で楽しみなことは何ですか？';

  @override
  String get smartBudgetSuggestions => 'スマート予算提案';

  @override
  String get smartBudgetInstructions => '目的地と日程を選択すると、アプリが自動で平均予算を提案します。';

  @override
  String get estimatedDailyBudget => '推定日額予算：';

  @override
  String basedOnAverageTravelers(String destination) {
    return '$destinationの平均的な旅行者に基づいています。';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return '$days日間の合計: $amount $currency';
  }

  @override
  String get apply => '適用';

  @override
  String get tripPreview => '旅行のプレビュー';

  @override
  String tripCreatedSuccess(String destination) {
    return '$destinationへの旅行が作成されました！';
  }

  @override
  String get failedToCreateTrip => '旅行の作成に失敗しました';

  @override
  String get expenses => '支出';

  @override
  String get amount => '金額';

  @override
  String get category => 'カテゴリ';

  @override
  String get date => '日付';

  @override
  String get notes => 'メモ';

  @override
  String get categoryTransport => '交通';

  @override
  String get categoryAccommodation => '宿泊';

  @override
  String get categoryFood => '食事';

  @override
  String get categoryActivities => 'アクティビティ';

  @override
  String get categoryShopping => 'ショッピング';

  @override
  String get categoryOther => 'その他';

  @override
  String get chat => 'チャット';

  @override
  String get typeMessage => 'メッセージを入力...';

  @override
  String get send => '送信';

  @override
  String get trips => '旅行';

  @override
  String get myTrips => '私の旅行';

  @override
  String get upcomingTrips => '予定の旅行';

  @override
  String get pastTrips => '過去の旅行';

  @override
  String get activeTrip => 'アクティブな旅行';

  @override
  String get otherTrips => 'Other Trips';

  @override
  String get noTripsYet => 'No Trips Yet';

  @override
  String get noTripsDescription =>
      'Start planning your next adventure\nby creating a new trip.';

  @override
  String get profile => 'プロフィール';

  @override
  String get settings => '設定';

  @override
  String get signOut => 'サインアウト';

  @override
  String get signIn => 'サインイン';

  @override
  String get signUp => '登録';

  @override
  String get email => 'メール';

  @override
  String get password => 'パスワード';

  @override
  String get fullName => '氏名';

  @override
  String get generalSettings => '一般';

  @override
  String get appLanguage => 'アプリの言語';

  @override
  String get defaultCurrency => 'デフォルト通貨';

  @override
  String get dateFormat => '日付形式';

  @override
  String get distanceUnits => '距離の単位';

  @override
  String get kilometers => 'キロメートル';

  @override
  String get miles => 'マイル';

  @override
  String get darkMode => 'ダークモード';

  @override
  String get notifications => '通知';

  @override
  String get pushNotifications => 'プッシュ通知';

  @override
  String get emailNotifications => 'メール通知';

  @override
  String get tripReminders => '旅行リマインダー';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get manageNotifications => 'Manage all notification preferences';

  @override
  String get doNotDisturb => 'Do Not Disturb';

  @override
  String get doNotDisturbDescription =>
      'Silence notifications during quiet hours';

  @override
  String get tripStatusChanges => 'Trip Status Changes';

  @override
  String get weatherWarnings => 'Weather Warnings';

  @override
  String get dailyTripSummary => 'Daily Trip Summary';

  @override
  String get expenseReminder => 'Expense Reminder';

  @override
  String get budgetAlerts => 'Budget Alerts';

  @override
  String get weeklySpendingSummary => 'Weekly Spending Summary';

  @override
  String get journalReady => 'Journal Ready';

  @override
  String get dailyJournalPrompt => 'Daily Journal Prompt';

  @override
  String get rateAppReminder => 'Rate App Reminder';

  @override
  String get newFeatureAnnouncements => 'New Feature Announcements';

  @override
  String get tipsAndRecommendations => 'Tips & Recommendations';

  @override
  String get supportReplyNotifications => 'Support Reply Notifications';

  @override
  String get ticketStatusUpdates => 'Ticket Status Updates';

  @override
  String get allNotificationsDisabled => 'All notifications are disabled';

  @override
  String get notificationsDisabledInSystem =>
      'Notifications are disabled in system settings';

  @override
  String get enable => 'Enable';

  @override
  String get privacy => 'プライバシー';

  @override
  String get shareAnalytics => '使用分析を共有';

  @override
  String get locationTracking => '位置追跡';

  @override
  String get account => 'アカウント';

  @override
  String get changePassword => 'パスワードを変更';

  @override
  String get exportData => 'データをエクスポート';

  @override
  String get deleteAccount => 'アカウントを削除';

  @override
  String get deleteAccountConfirmation => 'アカウントを削除してもよろしいですか？この操作は取り消せません。';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'リセット';

  @override
  String get about => 'アプリについて';

  @override
  String get appVersion => 'アプリバージョン';

  @override
  String get termsOfService => '利用規約';

  @override
  String get privacyPolicy => 'プライバシーポリシー';

  @override
  String get rateApp => 'アプリを評価';

  @override
  String get error => 'エラー';

  @override
  String get errorOccurred => 'エラーが発生しました';

  @override
  String get tryAgain => 'もう一度試す';

  @override
  String get loading => '読み込み中...';

  @override
  String get noDate => '日付なし';

  @override
  String get failedToLoadChats => 'チャットの読み込みに失敗';

  @override
  String get failedToLoadExpenses => '支出の読み込みに失敗';

  @override
  String get resetData => 'データをリセット';

  @override
  String get resetDataTitle => 'ユーザーデータをリセット';

  @override
  String get resetDataMessage =>
      'すべての旅行が削除され、オンボーディング状態がリセットされます。オンボーディングプロセスを最初からやり直します。\n\nこの操作は取り消せません。';

  @override
  String get dayTip => '今日のヒント';

  @override
  String get dayTipDescription => 'AIによる旅行のおすすめ';

  @override
  String get refreshTip => 'ヒントを更新';

  @override
  String get onboardingWelcome => 'Wayloへようこそ';

  @override
  String get onboardingLanguageTitle => '言語を選んでください';

  @override
  String get onboardingLanguageSubtitle => 'アプリの言語を選択してください';

  @override
  String get continueButton => '続ける';

  @override
  String get skip => 'スキップ';

  @override
  String get getStarted => '始める';

  @override
  String get languageEnglish => '英語';

  @override
  String get languageSpanish => 'スペイン語';

  @override
  String get languageFrench => 'フランス語';

  @override
  String get languageGerman => 'ドイツ語';

  @override
  String get languageHebrew => 'ヘブライ語';

  @override
  String get languageJapanese => '日本語';

  @override
  String get languageChinese => '中国語';

  @override
  String get languageKorean => '韓国語';

  @override
  String get languageItalian => 'イタリア語';

  @override
  String get languagePortuguese => 'ポルトガル語';

  @override
  String get languageRussian => 'ロシア語';

  @override
  String get languageArabic => 'アラビア語';

  @override
  String get chatHint => '旅行について何でも聞いてください...';

  @override
  String get deleteChat => 'チャットを削除';

  @override
  String get deleteChatConfirmation => 'このチャットを削除してもよろしいですか？';

  @override
  String get expenseAdded => '支出が追加されました！';

  @override
  String get failedToAddExpense => '支出の追加に失敗しました';

  @override
  String get chatWelcomeTitle => '旅行者さん、こんにちは！';

  @override
  String get chatWelcomeDescription =>
      '私はWaylo、あなたの旅のお供です！冒険を記録したり、アクティビティを計画したり、美しい旅行日記を作成するお手伝いをします。';

  @override
  String get chatWhatToDo => '何をしたいですか？';

  @override
  String get tellAboutDay => '今日のことを教えて';

  @override
  String get tellAboutDayDescription => '見たこと、したこと、体験したことを共有';

  @override
  String get tellAboutDayPrompt => '今日あったことを話させてください...';

  @override
  String get planActivity => 'アクティビティを計画';

  @override
  String get planActivityDescription => 'おすすめのアクティビティを取得';

  @override
  String get planActivityPrompt => 'ここでできる良いアクティビティは何ですか？';

  @override
  String get logExpenseAction => '支出を記録';

  @override
  String get logExpenseDescription => '旅行の支出を追跡';

  @override
  String get logExpensePrompt => '支出を記録したいです';

  @override
  String get generateJournal => '日記を作成';

  @override
  String get generateJournalDescription => '今日の旅行日記を作成';

  @override
  String get generateJournalPrompt => '今日の旅行日記を書くのを手伝ってください';

  @override
  String get askAnything => '何でも質問';

  @override
  String get askAnythingDescription => '旅行のヒント、地元情報、おすすめ';

  @override
  String get aiChats => 'AIチャット';

  @override
  String get startNewChat => '新しいチャットを開始';

  @override
  String get aiTravelAssistant => 'AI旅行アシスタント';

  @override
  String get aiTravelAssistantDescription =>
      'AI旅行バディと会話を始めて、旅行を計画したり、おすすめを得たりしましょう！';

  @override
  String get retry => '再試行';

  @override
  String get errorDeletingChat => 'チャットの削除エラー';

  @override
  String todayAt(String time) {
    return '今日 $time';
  }

  @override
  String yesterdayAt(String time) {
    return '昨日 $time';
  }

  @override
  String deleteChatTitle(String title) {
    return '「$title」を削除しますか？この操作は取り消せません。';
  }

  @override
  String get errorCreatingChat => 'チャットの作成エラー';

  @override
  String get errorLoadingChat => 'チャットの読み込みエラー';

  @override
  String get createTripForTips => '毎日のヒントを得るために旅行を作成してください！';

  @override
  String get overview => '概要';

  @override
  String expensesCount(int count) {
    return '$count件の支出';
  }

  @override
  String daysTracked(int count) {
    return '$count日追跡';
  }

  @override
  String dayTrip(int count) {
    return '$count日間の旅行';
  }

  @override
  String daysLeft(int count) {
    return '残り$count日';
  }

  @override
  String get byCategory => 'カテゴリ別';

  @override
  String get spendingOverTime => '時間経過による支出';

  @override
  String get noExpensesYet => 'まだ支出がありません';

  @override
  String get startTrackingExpenses => '最初の支出を追加して、旅行の支出を追跡し始めましょう。';

  @override
  String get somethingWentWrong => '問題が発生しました';

  @override
  String get homeCurrency => '自国通貨';

  @override
  String get usDollar => '米ドル';

  @override
  String get localCurrency => '現地通貨';

  @override
  String get foodAndDrinks => '食べ物と飲み物';

  @override
  String get pleaseSelectTrip => '旅行を選択してください';

  @override
  String get expenseAddedSuccess => '支出が正常に追加されました！';

  @override
  String get noTripsFound => '旅行が見つかりません。支出を追加するには、まず旅行を作成してください。';

  @override
  String get trip => '旅行';

  @override
  String get pleaseEnterAmount => '金額を入力してください';

  @override
  String get pleaseEnterValidNumber => '有効な数字を入力してください';

  @override
  String get pleaseEnterDescription => '説明を入力してください';

  @override
  String get descriptionHintExpense => '例：カフェでのランチ';

  @override
  String get addReceiptPhoto => 'レシート写真を追加';

  @override
  String get receiptPhotoComingSoon => 'レシート写真は近日公開！';

  @override
  String get splitThisExpense => 'この支出を分割しますか？';

  @override
  String get selectTripMembersToSplit => '分割する旅行メンバーを選択';

  @override
  String get noTripMembersToSplit => '分割する旅行メンバーがいません。まず旅行を作成してください！';

  @override
  String get notesOptional => 'メモ（任意）';

  @override
  String get additionalDetails => '追加の詳細...';

  @override
  String get countries => '国';

  @override
  String get helpAndSupport => 'ヘルプとサポート';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get legalAndPolicies => 'Legal & Policies';

  @override
  String get freePlan => '無料プラン';

  @override
  String get upgradeUnlockFeatures => 'アップグレードして無制限の旅行とAI機能をアンロック';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get signOutConfirmation => 'サインアウトしてもよろしいですか？';

  @override
  String get failedToSignOut => 'サインアウトに失敗しました';

  @override
  String get notSignedIn => 'サインインしていません';

  @override
  String get traveler => '旅行者';

  @override
  String memberSince(String date) {
    return '$dateから会員';
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
