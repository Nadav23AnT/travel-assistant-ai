// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'TripBuddy';

  @override
  String get home => '홈';

  @override
  String get welcomeGreetingMorning => '좋은 아침이에요,';

  @override
  String get welcomeGreetingAfternoon => '좋은 오후예요,';

  @override
  String get welcomeGreetingEvening => '좋은 저녁이에요,';

  @override
  String get noActiveTrip => '활성화된 여행이 없습니다';

  @override
  String get startPlanningAdventure => '다음 모험을 계획해 보세요!';

  @override
  String get createNewTrip => '새 여행 만들기';

  @override
  String get quickActions => '빠른 실행';

  @override
  String get newTrip => '새 여행';

  @override
  String get addExpense => '지출 추가';

  @override
  String get aiChat => 'AI 채팅';

  @override
  String get recentChats => '최근 채팅';

  @override
  String get recentExpenses => '최근 지출';

  @override
  String get viewAll => '전체 보기';

  @override
  String get startConversation => 'TripBuddy와 대화를 시작하세요!';

  @override
  String get newChat => '새 채팅';

  @override
  String get noExpensesRecorded => '기록된 지출이 없습니다';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get dates => '날짜';

  @override
  String get datesNotSet => '날짜 미설정';

  @override
  String get duration => '기간';

  @override
  String get notSet => '미설정';

  @override
  String get startsIn => '시작까지';

  @override
  String get status => '상태';

  @override
  String get completed => '완료';

  @override
  String get current => '현재';

  @override
  String get day => '일';

  @override
  String get days => '일';

  @override
  String dayOfTotal(int current, int total) {
    return '$current일째 / 총 $total일';
  }

  @override
  String get createTrip => '여행 만들기';

  @override
  String get save => '저장';

  @override
  String get cancel => '취소';

  @override
  String get delete => '삭제';

  @override
  String get edit => '편집';

  @override
  String get confirm => '확인';

  @override
  String get tripTitle => '여행 제목';

  @override
  String get tripTitleHint => '예: 파리 모험 2025';

  @override
  String get tripTitleRequired => '여행 제목을 입력하세요';

  @override
  String get destination => '목적지';

  @override
  String get destinationHint => '국가명을 입력하세요...';

  @override
  String get destinationRequired => '목적지를 선택하세요';

  @override
  String get tripDates => '여행 날짜';

  @override
  String get selectDates => '날짜 선택';

  @override
  String get pleaseSelectDates => '여행 날짜를 선택하세요';

  @override
  String get budget => '예산';

  @override
  String get currency => '통화';

  @override
  String get description => '설명';

  @override
  String get descriptionHint => '이 여행에서 기대되는 것은 무엇인가요?';

  @override
  String get smartBudgetSuggestions => '스마트 예산 제안';

  @override
  String get smartBudgetInstructions =>
      '목적지와 날짜를 선택하면 앱이 자동으로 평균 여행 예산을 제안합니다.';

  @override
  String get estimatedDailyBudget => '예상 일일 예산:';

  @override
  String basedOnAverageTravelers(String destination) {
    return '$destination의 평균 여행자 기준.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return '$days일 총합: $amount $currency';
  }

  @override
  String get apply => '적용';

  @override
  String get tripPreview => '여행 미리보기';

  @override
  String tripCreatedSuccess(String destination) {
    return '$destination으로의 여행이 생성되었습니다!';
  }

  @override
  String get failedToCreateTrip => '여행 생성 실패';

  @override
  String get expenses => '지출';

  @override
  String get amount => '금액';

  @override
  String get category => '범주';

  @override
  String get date => '날짜';

  @override
  String get notes => '메모';

  @override
  String get categoryTransport => '교통';

  @override
  String get categoryAccommodation => '숙박';

  @override
  String get categoryFood => '음식';

  @override
  String get categoryActivities => '활동';

  @override
  String get categoryShopping => '쇼핑';

  @override
  String get categoryOther => '기타';

  @override
  String get chat => '채팅';

  @override
  String get typeMessage => '메시지 입력...';

  @override
  String get send => '보내기';

  @override
  String get trips => '여행';

  @override
  String get myTrips => '내 여행';

  @override
  String get upcomingTrips => '다가오는 여행';

  @override
  String get pastTrips => '지난 여행';

  @override
  String get activeTrip => '활성화된 여행';

  @override
  String get profile => '프로필';

  @override
  String get settings => '설정';

  @override
  String get signOut => '로그아웃';

  @override
  String get signIn => '로그인';

  @override
  String get signUp => '회원가입';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get fullName => '성명';

  @override
  String get generalSettings => '일반';

  @override
  String get appLanguage => '앱 언어';

  @override
  String get defaultCurrency => '기본 통화';

  @override
  String get dateFormat => '날짜 형식';

  @override
  String get distanceUnits => '거리 단위';

  @override
  String get kilometers => '킬로미터';

  @override
  String get miles => '마일';

  @override
  String get darkMode => '다크 모드';

  @override
  String get notifications => '알림';

  @override
  String get pushNotifications => '푸시 알림';

  @override
  String get emailNotifications => '이메일 알림';

  @override
  String get tripReminders => '여행 알림';

  @override
  String get privacy => '개인정보';

  @override
  String get shareAnalytics => '사용 분석 공유';

  @override
  String get locationTracking => '위치 추적';

  @override
  String get account => '계정';

  @override
  String get changePassword => '비밀번호 변경';

  @override
  String get exportData => '내 데이터 내보내기';

  @override
  String get deleteAccount => '계정 삭제';

  @override
  String get deleteAccountConfirmation => '계정을 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => '초기화';

  @override
  String get about => '정보';

  @override
  String get appVersion => '앱 버전';

  @override
  String get termsOfService => '서비스 약관';

  @override
  String get privacyPolicy => '개인정보 정책';

  @override
  String get rateApp => '앱 평가';

  @override
  String get error => '오류';

  @override
  String get errorOccurred => '오류가 발생했습니다';

  @override
  String get tryAgain => '다시 시도';

  @override
  String get loading => '로딩 중...';

  @override
  String get noDate => '날짜 없음';

  @override
  String get failedToLoadChats => '채팅 로딩 실패';

  @override
  String get failedToLoadExpenses => '지출 로딩 실패';

  @override
  String get resetData => '데이터 초기화';

  @override
  String get resetDataTitle => '사용자 데이터 초기화';

  @override
  String get resetDataMessage =>
      '모든 여행이 삭제되고 온보딩 상태가 초기화됩니다. 온보딩 프로세스를 다시 시작하게 됩니다.\n\n이 작업은 취소할 수 없습니다.';

  @override
  String get dayTip => '오늘의 팁';

  @override
  String get dayTipDescription => 'AI 기반 여행 추천';

  @override
  String get refreshTip => '팁 새로고침';

  @override
  String get onboardingWelcome => 'TripBuddy에 오신 것을 환영합니다';

  @override
  String get onboardingLanguageTitle => '언어를 선택하세요';

  @override
  String get onboardingLanguageSubtitle => '앱 인터페이스 언어를 선택하세요';

  @override
  String get continueButton => '계속';

  @override
  String get skip => '건너뛰기';

  @override
  String get getStarted => '시작하기';

  @override
  String get languageEnglish => '영어';

  @override
  String get languageSpanish => '스페인어';

  @override
  String get languageFrench => '프랑스어';

  @override
  String get languageGerman => '독일어';

  @override
  String get languageHebrew => '히브리어';

  @override
  String get languageJapanese => '일본어';

  @override
  String get languageChinese => '중국어';

  @override
  String get languageKorean => '한국어';

  @override
  String get languageItalian => '이탈리아어';

  @override
  String get languagePortuguese => '포르투갈어';

  @override
  String get languageRussian => '러시아어';

  @override
  String get languageArabic => '아랍어';

  @override
  String get chatHint => '여행에 대해 무엇이든 물어보세요...';

  @override
  String get deleteChat => '채팅 삭제';

  @override
  String get deleteChatConfirmation => '이 채팅을 삭제하시겠습니까?';

  @override
  String get expenseAdded => '지출이 추가되었습니다!';

  @override
  String get failedToAddExpense => '지출 추가 실패';

  @override
  String get chatWelcomeTitle => '안녕하세요, 여행자님!';

  @override
  String get chatWelcomeDescription =>
      '저는 TripBuddy, 당신의 여행 동반자입니다! 모험을 기록하고, 활동을 계획하고, 아름다운 여행 일기를 만드는 것을 도와드립니다.';

  @override
  String get chatWhatToDo => '무엇을 하고 싶으세요?';

  @override
  String get tellAboutDay => '오늘에 대해 알려주세요';

  @override
  String get tellAboutDayDescription => '무엇을 했는지, 봤는지, 경험했는지 공유하세요';

  @override
  String get tellAboutDayPrompt => '오늘 있었던 일을 말씀드릴게요...';

  @override
  String get planActivity => '활동 계획';

  @override
  String get planActivityDescription => '활동 추천 받기';

  @override
  String get planActivityPrompt => '여기서 할 수 있는 좋은 활동이 무엇인가요?';

  @override
  String get logExpenseAction => '지출 기록';

  @override
  String get logExpenseDescription => '여행 지출 추적';

  @override
  String get logExpensePrompt => '지출을 기록하고 싶어요';

  @override
  String get generateJournal => '일기 생성';

  @override
  String get generateJournalDescription => '오늘의 여행 일기 작성';

  @override
  String get generateJournalPrompt => '오늘의 여행 일기를 작성하는 것을 도와주세요';

  @override
  String get askAnything => '무엇이든 질문';

  @override
  String get askAnythingDescription => '여행 팁, 현지 정보, 추천';

  @override
  String get aiChats => 'AI 채팅';

  @override
  String get startNewChat => '새 채팅 시작';

  @override
  String get aiTravelAssistant => 'AI 여행 어시스턴트';

  @override
  String get aiTravelAssistantDescription =>
      'AI 여행 버디와 대화를 시작하여 여행을 계획하고 추천을 받으세요!';

  @override
  String get retry => '재시도';

  @override
  String get errorDeletingChat => '채팅 삭제 오류';

  @override
  String todayAt(String time) {
    return '오늘 $time';
  }

  @override
  String yesterdayAt(String time) {
    return '어제 $time';
  }

  @override
  String deleteChatTitle(String title) {
    return '「$title」을(를) 삭제하시겠습니까? 이 작업은 취소할 수 없습니다.';
  }

  @override
  String get errorCreatingChat => '채팅 생성 오류';

  @override
  String get errorLoadingChat => '채팅 로딩 오류';

  @override
  String get createTripForTips => '매일 팁을 받으려면 여행을 만드세요!';

  @override
  String get overview => '개요';

  @override
  String expensesCount(int count) {
    return '$count개의 지출';
  }

  @override
  String daysTracked(int count) {
    return '$count일 추적됨';
  }

  @override
  String dayTrip(int count) {
    return '$count일 여행';
  }

  @override
  String daysLeft(int count) {
    return '$count일 남음';
  }

  @override
  String get byCategory => '카테고리별';

  @override
  String get spendingOverTime => '시간별 지출';

  @override
  String get noExpensesYet => '아직 지출이 없습니다';

  @override
  String get startTrackingExpenses => '첫 번째 지출을 추가하여 여행 경비 추적을 시작하세요.';

  @override
  String get somethingWentWrong => '문제가 발생했습니다';

  @override
  String get homeCurrency => '본국 통화';

  @override
  String get usDollar => '미국 달러';

  @override
  String get localCurrency => '현지 통화';

  @override
  String get foodAndDrinks => '음식 및 음료';

  @override
  String get pleaseSelectTrip => '여행을 선택해주세요';

  @override
  String get expenseAddedSuccess => '지출이 성공적으로 추가되었습니다!';

  @override
  String get noTripsFound => '여행을 찾을 수 없습니다. 지출을 추가하려면 먼저 여행을 만드세요.';

  @override
  String get trip => '여행';

  @override
  String get pleaseEnterAmount => '금액을 입력해주세요';

  @override
  String get pleaseEnterValidNumber => '유효한 숫자를 입력해주세요';

  @override
  String get pleaseEnterDescription => '설명을 입력해주세요';

  @override
  String get descriptionHintExpense => '예: 카페에서 점심';

  @override
  String get addReceiptPhoto => '영수증 사진 추가';

  @override
  String get receiptPhotoComingSoon => '영수증 사진 기능 곧 출시!';

  @override
  String get splitThisExpense => '이 지출을 나누시겠습니까?';

  @override
  String get selectTripMembersToSplit => '나눌 여행 멤버를 선택하세요';

  @override
  String get noTripMembersToSplit => '나눌 여행 멤버가 없습니다. 먼저 여행을 만드세요!';

  @override
  String get notesOptional => '메모 (선택사항)';

  @override
  String get additionalDetails => '추가 세부사항...';

  @override
  String get countries => '국가';

  @override
  String get helpAndSupport => '도움말 및 지원';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get freePlan => '무료 플랜';

  @override
  String get upgradeUnlockFeatures => '업그레이드하여 무제한 여행과 AI 기능 잠금 해제';

  @override
  String get upgrade => '업그레이드';

  @override
  String get signOutConfirmation => '로그아웃하시겠습니까?';

  @override
  String get failedToSignOut => '로그아웃 실패';

  @override
  String get notSignedIn => '로그인되지 않음';

  @override
  String get traveler => '여행자';

  @override
  String memberSince(String date) {
    return '$date부터 회원';
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
}
