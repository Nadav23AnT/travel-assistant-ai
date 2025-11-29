// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'TripBuddy';

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
  String get startConversation => 'התחל שיחה עם TripBuddy!';

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
  String get reset => 'אפס';

  @override
  String get dayTip => 'טיפ יומי';

  @override
  String get dayTipDescription => 'המלצות טיול מבוססות AI';

  @override
  String get refreshTip => 'רענן טיפ';

  @override
  String get onboardingWelcome => 'ברוכים הבאים ל-TripBuddy';

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
      'אני TripBuddy, המלווה שלך לטיול! אני כאן כדי לעזור לך לתעד את ההרפתקאות שלך, לתכנן פעילויות, וליצור יומן טיול יפהפה.';

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
  String get selectTripMembersToSplit => 'בחר חברי טיול לפיצול';

  @override
  String get noTripMembersToSplit => 'אין חברי טיול לפיצול. צור טיול קודם!';

  @override
  String get notesOptional => 'הערות (אופציונלי)';

  @override
  String get additionalDetails => 'פרטים נוספים...';

  @override
  String get countries => 'מדינות';

  @override
  String get helpAndSupport => 'עזרה ותמיכה';

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
}
