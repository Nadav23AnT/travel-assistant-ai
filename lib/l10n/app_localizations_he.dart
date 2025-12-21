// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'Waylo';

  @override
  String get home => 'בית';

  @override
  String get welcomeGreetingMorning => 'בוקר טוב,';

  @override
  String get welcomeGreetingAfternoon => 'צהריים טובים,';

  @override
  String get welcomeGreetingEvening => 'ערב טוב,';

  @override
  String get noActiveTrip => 'אין טיול פעיל';

  @override
  String get startPlanningAdventure => 'התחל לתכנן את ההרפתקה הבאה שלך!';

  @override
  String get createNewTrip => 'צור טיול חדש';

  @override
  String get quickActions => 'פעולות מהירות';

  @override
  String get newTrip => 'טיול חדש';

  @override
  String get addExpense => 'הוסף הוצאה';

  @override
  String get aiChat => 'צ\'אט AI';

  @override
  String get recentChats => 'צ\'אטים אחרונים';

  @override
  String get recentExpenses => 'הוצאות אחרונות';

  @override
  String get viewAll => 'צפה בהכל';

  @override
  String get startConversation => 'התחל שיחה עם Waylo!';

  @override
  String get newChat => 'צ\'אט חדש';

  @override
  String get noExpensesRecorded => 'לא נרשמו הוצאות';

  @override
  String get today => 'היום';

  @override
  String get yesterday => 'אתמול';

  @override
  String get dates => 'תאריכים';

  @override
  String get datesNotSet => 'תאריכים לא נקבעו';

  @override
  String get duration => 'משך';

  @override
  String get notSet => 'לא נקבע';

  @override
  String get startsIn => 'מתחיל בעוד';

  @override
  String get status => 'סטטוס';

  @override
  String get completed => 'הושלם';

  @override
  String get current => 'נוכחי';

  @override
  String get day => 'יום';

  @override
  String get days => 'ימים';

  @override
  String dayOfTotal(int current, int total) {
    return 'יום $current מתוך $total';
  }

  @override
  String get createTrip => 'צור טיול';

  @override
  String get save => 'שמור';

  @override
  String get cancel => 'ביטול';

  @override
  String get delete => 'מחק';

  @override
  String get edit => 'ערוך';

  @override
  String get confirm => 'אשר';

  @override
  String get tripTitle => 'שם הטיול';

  @override
  String get tripTitleHint => 'לדוגמה: הרפתקה בפריז 2025';

  @override
  String get tripTitleRequired => 'נא להזין שם טיול';

  @override
  String get destination => 'יעד';

  @override
  String get destinationHint => 'התחל להקליד מדינה...';

  @override
  String get destinationRequired => 'נא לבחור יעד';

  @override
  String get tripDates => 'תאריכי הטיול';

  @override
  String get selectDates => 'בחר תאריכים';

  @override
  String get pleaseSelectDates => 'נא לבחור תאריכי טיול';

  @override
  String get budget => 'תקציב';

  @override
  String get currency => 'מטבע';

  @override
  String get description => 'תיאור';

  @override
  String get descriptionHint => 'מה מרגש אותך בטיול הזה?';

  @override
  String get smartBudgetSuggestions => 'הצעות תקציב חכמות';

  @override
  String get smartBudgetInstructions =>
      'לאחר בחירת יעד ותאריכים, האפליקציה תציע אוטומטית תקציב ממוצע למטיילים.';

  @override
  String get estimatedDailyBudget => 'תקציב יומי משוער:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'מבוסס על מטיילים ממוצעים ב$destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'סה\"כ ל$days ימים: $amount $currency';
  }

  @override
  String get apply => 'החל';

  @override
  String get tripPreview => 'תצוגה מקדימה';

  @override
  String tripCreatedSuccess(String destination) {
    return 'טיול ל$destination נוצר!';
  }

  @override
  String get failedToCreateTrip => 'נכשל ביצירת הטיול';

  @override
  String get expenses => 'הוצאות';

  @override
  String get amount => 'סכום';

  @override
  String get category => 'קטגוריה';

  @override
  String get date => 'תאריך';

  @override
  String get notes => 'הערות';

  @override
  String get categoryTransport => 'תחבורה';

  @override
  String get categoryAccommodation => 'לינה';

  @override
  String get categoryFood => 'אוכל';

  @override
  String get categoryActivities => 'פעילויות';

  @override
  String get categoryShopping => 'קניות';

  @override
  String get categoryOther => 'אחר';

  @override
  String get chat => 'צ\'אט';

  @override
  String get typeMessage => 'הקלד הודעה...';

  @override
  String get send => 'שלח';

  @override
  String get trips => 'טיולים';

  @override
  String get myTrips => 'הטיולים שלי';

  @override
  String get upcomingTrips => 'טיולים קרובים';

  @override
  String get pastTrips => 'טיולים שעברו';

  @override
  String get activeTrip => 'טיול פעיל';

  @override
  String get otherTrips => 'Other Trips';

  @override
  String get noTripsYet => 'No Trips Yet';

  @override
  String get noTripsDescription =>
      'Start planning your next adventure\nby creating a new trip.';

  @override
  String get profile => 'פרופיל';

  @override
  String get settings => 'הגדרות';

  @override
  String get signOut => 'התנתק';

  @override
  String get signIn => 'התחבר';

  @override
  String get signUp => 'הירשם';

  @override
  String get email => 'דוא\"ל';

  @override
  String get password => 'סיסמה';

  @override
  String get fullName => 'שם מלא';

  @override
  String get generalSettings => 'כללי';

  @override
  String get appLanguage => 'שפת האפליקציה';

  @override
  String get defaultCurrency => 'מטבע ברירת מחדל';

  @override
  String get dateFormat => 'פורמט תאריך';

  @override
  String get distanceUnits => 'יחידות מרחק';

  @override
  String get kilometers => 'קילומטרים';

  @override
  String get miles => 'מיילים';

  @override
  String get darkMode => 'מצב כהה';

  @override
  String get notifications => 'התראות';

  @override
  String get pushNotifications => 'התראות Push';

  @override
  String get emailNotifications => 'התראות בדוא\"ל';

  @override
  String get tripReminders => 'תזכורת טיול';

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
  String get privacy => 'פרטיות';

  @override
  String get shareAnalytics => 'שיתוף ניתוח שימוש';

  @override
  String get locationTracking => 'מעקב מיקום';

  @override
  String get account => 'חשבון';

  @override
  String get changePassword => 'שנה סיסמה';

  @override
  String get exportData => 'ייצא את הנתונים שלי';

  @override
  String get deleteAccount => 'מחק חשבון';

  @override
  String get deleteAccountConfirmation =>
      'האם אתה בטוח שברצונך למחוק את החשבון? פעולה זו לא ניתנת לביטול.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'אפס';

  @override
  String get about => 'אודות';

  @override
  String get appVersion => 'גרסה';

  @override
  String get termsOfService => 'תנאי שימוש';

  @override
  String get privacyPolicy => 'מדיניות פרטיות';

  @override
  String get rateApp => 'דרגו את האפליקציה';

  @override
  String get error => 'שגיאה';

  @override
  String get errorOccurred => 'אירעה שגיאה';

  @override
  String get tryAgain => 'נסה שוב';

  @override
  String get loading => 'טוען...';

  @override
  String get noDate => 'אין תאריך';

  @override
  String get failedToLoadChats => 'נכשל בטעינת צ\'אטים';

  @override
  String get failedToLoadExpenses => 'נכשל בטעינת הוצאות';

  @override
  String get resetData => 'אפס נתונים';

  @override
  String get resetDataTitle => 'איפוס נתונים';

  @override
  String get resetDataMessage =>
      'זה ימחק את כל הטיולים שלך ויאפס את מצב ההתחלה. תופנה להתחיל את תהליך ההתחלה מחדש.\n\nפעולה זו אינה ניתנת לביטול.';

  @override
  String get dayTip => 'טיפ יומי';

  @override
  String get dayTipDescription => 'המלצות טיול מבוססות AI';

  @override
  String get refreshTip => 'רענן טיפ';

  @override
  String get onboardingWelcome => 'ברוכים הבאים ל-Waylo';

  @override
  String get onboardingLanguageTitle => 'בחר את השפה שלך';

  @override
  String get onboardingLanguageSubtitle => 'בחר את השפה המועדפת לאפליקציה';

  @override
  String get continueButton => 'המשך';

  @override
  String get skip => 'דלג';

  @override
  String get getStarted => 'התחל';

  @override
  String get languageEnglish => 'אנגלית';

  @override
  String get languageSpanish => 'ספרדית';

  @override
  String get languageFrench => 'צרפתית';

  @override
  String get languageGerman => 'גרמנית';

  @override
  String get languageHebrew => 'עברית';

  @override
  String get languageJapanese => 'יפנית';

  @override
  String get languageChinese => 'סינית';

  @override
  String get languageKorean => 'קוריאנית';

  @override
  String get languageItalian => 'איטלקית';

  @override
  String get languagePortuguese => 'פורטוגזית';

  @override
  String get languageRussian => 'רוסית';

  @override
  String get languageArabic => 'ערבית';

  @override
  String get chatHint => 'שאל אותי כל דבר על טיולים...';

  @override
  String get deleteChat => 'מחק צ\'אט';

  @override
  String get deleteChatConfirmation =>
      'האם אתה בטוח שברצונך למחוק את הצ\'אט הזה?';

  @override
  String get expenseAdded => 'ההוצאה נוספה!';

  @override
  String get failedToAddExpense => 'נכשל בהוספת הוצאה';

  @override
  String get chatWelcomeTitle => 'היי מטייל!';

  @override
  String get chatWelcomeDescription =>
      'אני Waylo, המלווה שלך לטיול! אני כאן כדי לעזור לך לתעד את ההרפתקאות שלך, לתכנן פעילויות, וליצור יומן טיול יפהפה.';

  @override
  String get chatWhatToDo => 'מה תרצה לעשות?';

  @override
  String get tellAboutDay => 'ספר לי על היום שלך';

  @override
  String get tellAboutDayDescription => 'שתף מה עשית, ראית או חווית';

  @override
  String get tellAboutDayPrompt => 'בוא אספר לך על היום שלי היום...';

  @override
  String get planActivity => 'תכנן פעילות';

  @override
  String get planActivityDescription => 'קבל המלצות לדברים לעשות';

  @override
  String get planActivityPrompt => 'מהן כמה פעילויות טובות שכדאי לי לעשות כאן?';

  @override
  String get logExpenseAction => 'רשום הוצאה';

  @override
  String get logExpenseDescription => 'עקוב אחר הוצאות בטיול';

  @override
  String get logExpensePrompt => 'אני רוצה לרשום הוצאה';

  @override
  String get generateJournal => 'צור את היומן שלי';

  @override
  String get generateJournalDescription => 'צור את רשומת יומן הטיול של היום';

  @override
  String get generateJournalPrompt => 'עזור לי לכתוב את יומן הטיול שלי להיום';

  @override
  String get askAnything => 'שאל כל דבר';

  @override
  String get askAnythingDescription => 'טיפים לטיול, מידע מקומי, המלצות';

  @override
  String get aiChats => 'צ\'אטים AI';

  @override
  String get startNewChat => 'התחל צ\'אט חדש';

  @override
  String get aiTravelAssistant => 'עוזר טיולים AI';

  @override
  String get aiTravelAssistantDescription =>
      'התחל שיחה עם חבר הטיולים ה-AI שלך כדי לתכנן טיולים, לקבל המלצות ועוד!';

  @override
  String get retry => 'נסה שוב';

  @override
  String get errorDeletingChat => 'שגיאה במחיקת צ\'אט';

  @override
  String todayAt(String time) {
    return 'היום ב-$time';
  }

  @override
  String yesterdayAt(String time) {
    return 'אתמול ב-$time';
  }

  @override
  String deleteChatTitle(String title) {
    return 'למחוק את \"$title\"? לא ניתן לבטל פעולה זו.';
  }

  @override
  String get errorCreatingChat => 'שגיאה ביצירת צ\'אט';

  @override
  String get errorLoadingChat => 'שגיאה בטעינת צ\'אט';

  @override
  String get createTripForTips => 'צור טיול כדי לקבל טיפים יומיים!';

  @override
  String get overview => 'סקירה כללית';

  @override
  String expensesCount(int count) {
    return '$count הוצאות';
  }

  @override
  String daysTracked(int count) {
    return '$count ימים נמדדו';
  }

  @override
  String dayTrip(int count) {
    return 'טיול של $count ימים';
  }

  @override
  String daysLeft(int count) {
    return 'נותרו $count ימים';
  }

  @override
  String get byCategory => 'לפי קטגוריה';

  @override
  String get spendingOverTime => 'הוצאות לאורך זמן';

  @override
  String get noExpensesYet => 'עדיין אין הוצאות';

  @override
  String get startTrackingExpenses =>
      'התחל לעקוב אחר הוצאות הטיול שלך על ידי הוספת ההוצאה הראשונה.';

  @override
  String get somethingWentWrong => 'משהו השתבש';

  @override
  String get homeCurrency => 'מטבע בית';

  @override
  String get usDollar => 'דולר אמריקאי';

  @override
  String get localCurrency => 'מטבע מקומי';

  @override
  String get foodAndDrinks => 'אוכל ושתייה';

  @override
  String get pleaseSelectTrip => 'אנא בחר טיול';

  @override
  String get expenseAddedSuccess => 'ההוצאה נוספה בהצלחה!';

  @override
  String get noTripsFound =>
      'לא נמצאו טיולים. צור טיול קודם כדי להוסיף הוצאות.';

  @override
  String get trip => 'טיול';

  @override
  String get pleaseEnterAmount => 'אנא הזן סכום';

  @override
  String get pleaseEnterValidNumber => 'אנא הזן מספר תקין';

  @override
  String get pleaseEnterDescription => 'אנא הזן תיאור';

  @override
  String get descriptionHintExpense => 'לדוגמה: ארוחת צהריים בקפה';

  @override
  String get addReceiptPhoto => 'הוסף תמונת קבלה';

  @override
  String get receiptPhotoComingSoon => 'תמונת קבלה בקרוב!';

  @override
  String get splitThisExpense => 'לפצל הוצאה זו?';

  @override
  String get selectTrip => 'בחר טיול';

  @override
  String get failedToLoadTrips => 'טעינת הטיולים נכשלה';

  @override
  String get selectTripMembersToSplit => 'בחר חברי טיול לפיצול';

  @override
  String get noTripMembersToSplit => 'אין חברי טיול לפיצול. צור טיול קודם!';

  @override
  String get balances => 'Balances';

  @override
  String get settlements => 'Settlements';

  @override
  String get notesOptional => 'הערות (אופציונלי)';

  @override
  String get additionalDetails => 'פרטים נוספים...';

  @override
  String get countries => 'מדינות';

  @override
  String get helpAndSupport => 'עזרה ותמיכה';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get legalAndPolicies => 'Legal & Policies';

  @override
  String get freePlan => 'תכנית חינם';

  @override
  String get upgradeUnlockFeatures =>
      'שדרג כדי לפתוח טיולים ללא הגבלה ותכונות AI';

  @override
  String get upgrade => 'שדרג';

  @override
  String get signOutConfirmation => 'האם אתה בטוח שברצונך להתנתק?';

  @override
  String get failedToSignOut => 'ההתנתקות נכשלה';

  @override
  String get notSignedIn => 'לא מחובר';

  @override
  String get traveler => 'מטייל';

  @override
  String memberSince(String date) {
    return 'חבר מאז $date';
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
  String get inviteFriends => 'הזמן חברים';

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
  String get tripMembers => 'משתתפי הטיול';

  @override
  String get shareInviteCode => 'שתף קוד הזמנה';

  @override
  String get inviteCode => 'קוד הזמנה';

  @override
  String get copyCode => 'העתק קוד';

  @override
  String get codeCopied => 'הקוד הועתק!';

  @override
  String get joinTrip => 'הצטרף לטיול';

  @override
  String get enterInviteCode => 'הזן קוד הזמנה';

  @override
  String get joinTripSuccess => 'הצטרפת לטיול בהצלחה!';

  @override
  String get invalidInviteCode => 'קוד הזמנה לא תקין';

  @override
  String get alreadyMember => 'אתה כבר משתתף בטיול הזה';

  @override
  String get sharedWithYou => 'שותף איתך';

  @override
  String get leaveTrip => 'עזוב טיול';

  @override
  String get removeMember => 'הסר משתתף';

  @override
  String get confirmLeaveTrip => 'האם אתה בטוח שברצונך לעזוב את הטיול?';

  @override
  String get tripOwner => 'מארגן';

  @override
  String get tripMember => 'משתתף';

  @override
  String get inviteFriendsToTrip => 'הזמן חברים לשתף פעולה בטיול!';

  @override
  String get noOtherMembers => 'עדיין אין משתתפים נוספים';

  @override
  String get shareCodeDescription =>
      'שתף קוד זה עם חברים כדי שיוכלו להצטרף לטיול ולשתף פעולה בתכנון!';

  @override
  String get shareCodeInfo =>
      'כל מי שיש לו קוד זה יכול להצטרף לטיול ולהוסיף הוצאות, לערוך את המסלול ועוד.';

  @override
  String get joinTripTitle => 'הצטרף לטיול';

  @override
  String get joinTripDescription =>
      'הזן את קוד ההזמנה מהחבר שלך כדי להצטרף לטיול שלו.';

  @override
  String get joining => 'מצטרף...';

  @override
  String get joinTripHelp =>
      'בקש מהחבר שלך לשתף את קוד ההזמנה לטיול שלו ממסך פרטי הטיול.';

  @override
  String get invalidCodeLength => 'הקוד חייב להכיל 8 תווים';

  @override
  String get cannotJoinOwnTrip => 'לא ניתן להצטרף לטיול שלך עצמך';

  @override
  String get sharedTrip => 'משותף';

  @override
  String get exportJournal => 'ייצא יומן';

  @override
  String get chooseExportFormat => 'בחר פורמט ייצוא:';

  @override
  String get exportPdf => 'יומן PDF';

  @override
  String get exportText => 'טקסט (.txt)';

  @override
  String get exportMarkdown => 'Markdown (.md)';

  @override
  String get generatingPdf => 'יוצר את היומן היפהפה שלך...';

  @override
  String get exportFailed => 'הייצוא נכשל';

  @override
  String get errorNetwork => 'שגיאת רשת. אנא בדוק את החיבור שלך.';

  @override
  String get errorTimeout => 'הבקשה נכשלה בגלל זמן המתנה. אנא נסה שוב.';

  @override
  String get errorNoConnection => 'אין חיבור לאינטרנט. אנא בדוק את הרשת שלך.';

  @override
  String get errorServer => 'שגיאת שרת. אנא נסה שוב מאוחר יותר.';

  @override
  String get errorRateLimited => 'יותר מדי בקשות. אנא המתן רגע.';

  @override
  String get errorInvalidCredentials => 'אימייל או סיסמה שגויים.';

  @override
  String get errorSessionExpired => 'פג תוקף ההתחברות. אנא התחבר שוב.';

  @override
  String get errorEmailNotVerified => 'אנא אמת את כתובת האימייל שלך.';

  @override
  String get errorTokenLimit => 'הגעת למגבלת השימוש היומית ב-AI.';

  @override
  String get errorForbidden => 'אין לך הרשאה לבצע פעולה זו.';

  @override
  String get errorUnauthorized => 'אנא התחבר כדי להמשיך.';

  @override
  String get errorNotFound => 'הפריט המבוקש לא נמצא.';

  @override
  String get errorGeneric => 'משהו השתבש. אנא נסה שוב.';

  @override
  String get offline => 'אתה במצב לא מקוון';

  @override
  String get offlineMessage => 'חלק מהתכונות עשויות להיות לא זמינות.';

  @override
  String get backOnline => 'אתה שוב מחובר';

  @override
  String get ongoing => 'פעיל';

  @override
  String get planning => 'בתכנון';

  @override
  String get expensesSummary => 'סיכום הוצאות';

  @override
  String get totalSpent => 'סה\"כ הוצאות';

  @override
  String get dailyAverage => 'ממוצע יומי';

  @override
  String get remainingBudget => 'נותר';

  @override
  String get topCategory => 'קטגוריה מובילה';

  @override
  String get none => 'אין';

  @override
  String get showMore => 'הצג עוד';

  @override
  String get showLess => 'הצג פחות';

  @override
  String get journalReminder => 'צור יומן מסע';

  @override
  String get journalReminderDescription =>
      'הטיול שלך הסתיים! הקש כאן ליצירת יומן מסע יפהפה.';

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
  String get welcomeBack => '!ברוך הבא';

  @override
  String get discoverFeatures => 'הנה מה שאתה יכול לעשות היום';

  @override
  String get dailyTipsFeature => 'טיפים יומיים לטיול';

  @override
  String get dailyTipsDescription =>
      'קבל טיפים מותאמים אישית מבינה מלאכותית ליעד שלך כל יום';

  @override
  String get multiCurrencyFeature => 'הוצאות במטבעות מרובים';

  @override
  String get multiCurrencyDescription =>
      'עקוב אחר הוצאות בכל מטבע עם המרה אוטומטית למטבע הבית שלך';

  @override
  String get aiChatFeature => 'עוזר נסיעות AI';

  @override
  String get aiChatDescription =>
      'שאל כל דבר על הטיול שלך וקבל הצעות והמלצות מיידיות';

  @override
  String get welcomeBackExplorer => '!ברוך שובך, חוקר';

  @override
  String get journeyStartsHere => 'המסע שלך מתחיל כאן';

  @override
  String get startExploring => 'התחל לחקור';

  @override
  String get maybeLater => 'אולי אחר כך';
}
