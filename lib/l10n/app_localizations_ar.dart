// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'TripBuddy';

  @override
  String get home => 'الرئيسية';

  @override
  String get welcomeGreetingMorning => 'صباح الخير،';

  @override
  String get welcomeGreetingAfternoon => 'مساء الخير،';

  @override
  String get welcomeGreetingEvening => 'مساء الخير،';

  @override
  String get noActiveTrip => 'لا توجد رحلة نشطة';

  @override
  String get startPlanningAdventure => 'ابدأ في تخطيط مغامرتك القادمة!';

  @override
  String get createNewTrip => 'إنشاء رحلة جديدة';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get newTrip => 'رحلة جديدة';

  @override
  String get addExpense => 'إضافة مصروف';

  @override
  String get aiChat => 'دردشة AI';

  @override
  String get recentChats => 'الدردشات الأخيرة';

  @override
  String get recentExpenses => 'المصاريف الأخيرة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get startConversation => 'ابدأ محادثة مع TripBuddy!';

  @override
  String get newChat => 'دردشة جديدة';

  @override
  String get noExpensesRecorded => 'لا توجد مصاريف مسجلة';

  @override
  String get today => 'اليوم';

  @override
  String get yesterday => 'أمس';

  @override
  String get dates => 'التواريخ';

  @override
  String get datesNotSet => 'التواريخ غير محددة';

  @override
  String get duration => 'المدة';

  @override
  String get notSet => 'غير محدد';

  @override
  String get startsIn => 'تبدأ في';

  @override
  String get status => 'الحالة';

  @override
  String get completed => 'مكتمل';

  @override
  String get current => 'الحالي';

  @override
  String get day => 'يوم';

  @override
  String get days => 'أيام';

  @override
  String dayOfTotal(int current, int total) {
    return 'اليوم $current من $total';
  }

  @override
  String get createTrip => 'إنشاء رحلة';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get confirm => 'تأكيد';

  @override
  String get tripTitle => 'عنوان الرحلة';

  @override
  String get tripTitleHint => 'مثال: مغامرة باريس 2025';

  @override
  String get tripTitleRequired => 'يرجى إدخال عنوان للرحلة';

  @override
  String get destination => 'الوجهة';

  @override
  String get destinationHint => 'ابدأ بكتابة اسم البلد...';

  @override
  String get destinationRequired => 'يرجى اختيار وجهة';

  @override
  String get tripDates => 'تواريخ الرحلة';

  @override
  String get selectDates => 'اختيار التواريخ';

  @override
  String get pleaseSelectDates => 'يرجى اختيار تواريخ الرحلة';

  @override
  String get budget => 'الميزانية';

  @override
  String get currency => 'العملة';

  @override
  String get description => 'الوصف';

  @override
  String get descriptionHint => 'ما الذي يثيرك في هذه الرحلة؟';

  @override
  String get smartBudgetSuggestions => 'اقتراحات ميزانية ذكية';

  @override
  String get smartBudgetInstructions =>
      'بعد اختيار الوجهة والتواريخ، سيقترح التطبيق تلقائياً ميزانية متوسطة للمسافرين.';

  @override
  String get estimatedDailyBudget => 'الميزانية اليومية المتوقعة:';

  @override
  String basedOnAverageTravelers(String destination) {
    return 'بناءً على متوسط المسافرين في $destination.';
  }

  @override
  String totalForDays(int days, String amount, String currency) {
    return 'المجموع لـ $days أيام: $amount $currency';
  }

  @override
  String get apply => 'تطبيق';

  @override
  String get tripPreview => 'معاينة الرحلة';

  @override
  String tripCreatedSuccess(String destination) {
    return 'تم إنشاء رحلة إلى $destination!';
  }

  @override
  String get failedToCreateTrip => 'فشل في إنشاء الرحلة';

  @override
  String get expenses => 'المصاريف';

  @override
  String get amount => 'المبلغ';

  @override
  String get category => 'الفئة';

  @override
  String get date => 'التاريخ';

  @override
  String get notes => 'ملاحظات';

  @override
  String get categoryTransport => 'النقل';

  @override
  String get categoryAccommodation => 'الإقامة';

  @override
  String get categoryFood => 'الطعام';

  @override
  String get categoryActivities => 'الأنشطة';

  @override
  String get categoryShopping => 'التسوق';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get chat => 'الدردشة';

  @override
  String get typeMessage => 'اكتب رسالة...';

  @override
  String get send => 'إرسال';

  @override
  String get trips => 'الرحلات';

  @override
  String get myTrips => 'رحلاتي';

  @override
  String get upcomingTrips => 'الرحلات القادمة';

  @override
  String get pastTrips => 'الرحلات السابقة';

  @override
  String get activeTrip => 'الرحلة النشطة';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String get signOut => 'تسجيل خروج';

  @override
  String get signIn => 'تسجيل دخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get generalSettings => 'عام';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get defaultCurrency => 'العملة الافتراضية';

  @override
  String get dateFormat => 'تنسيق التاريخ';

  @override
  String get distanceUnits => 'وحدات المسافة';

  @override
  String get kilometers => 'كيلومترات';

  @override
  String get miles => 'أميال';

  @override
  String get darkMode => 'الوضع المظلم';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get pushNotifications => 'إشعارات الفورية';

  @override
  String get emailNotifications => 'إشعارات البريد الإلكتروني';

  @override
  String get tripReminders => 'تذكيرات الرحلة';

  @override
  String get privacy => 'الخصوصية';

  @override
  String get shareAnalytics => 'مشاركة تحليلات الاستخدام';

  @override
  String get locationTracking => 'تتبع الموقع';

  @override
  String get account => 'الحساب';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get exportData => 'تصدير بياناتي';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmation =>
      'هل أنت متأكد من رغبتك في حذف حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get resetAccount => 'Reset Account Data';

  @override
  String get resetAccountConfirmation =>
      'Are you sure you want to reset all your data? This will delete all your trips, expenses, chats, and journal entries. Your account will remain active.';

  @override
  String get accountResetSuccess => 'Account data has been reset successfully';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get about => 'حول';

  @override
  String get appVersion => 'إصدار التطبيق';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get rateApp => 'تقييم التطبيق';

  @override
  String get error => 'خطأ';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noDate => 'لا تاريخ';

  @override
  String get failedToLoadChats => 'فشل في تحميل الدردشات';

  @override
  String get failedToLoadExpenses => 'فشل في تحميل المصاريف';

  @override
  String get resetData => 'إعادة تعيين البيانات';

  @override
  String get resetDataTitle => 'إعادة تعيين بيانات المستخدم';

  @override
  String get resetDataMessage =>
      'سيحذف هذا جميع رحلاتك ويعيد تعيين حالة الإعداد. ستتم إعادة توجيهك لبدء عملية الإعداد من جديد.\n\nلا يمكن التراجع عن هذا الإجراء.';

  @override
  String get dayTip => 'نصيحة اليوم';

  @override
  String get dayTipDescription => 'توصيات سفر مستندة إلى AI';

  @override
  String get refreshTip => 'تحديث النصيحة';

  @override
  String get onboardingWelcome => 'مرحباً بك في TripBuddy';

  @override
  String get onboardingLanguageTitle => 'اختر لغتك';

  @override
  String get onboardingLanguageSubtitle => 'اختيار اللغة المفضلة للتطبيق';

  @override
  String get continueButton => 'متابعة';

  @override
  String get skip => 'تخطى';

  @override
  String get getStarted => 'ابدأ';

  @override
  String get languageEnglish => 'الإنجليزية';

  @override
  String get languageSpanish => 'الإسبانية';

  @override
  String get languageFrench => 'الفرنسية';

  @override
  String get languageGerman => 'الألمانية';

  @override
  String get languageHebrew => 'العبرية';

  @override
  String get languageJapanese => 'اليابانية';

  @override
  String get languageChinese => 'الصينية';

  @override
  String get languageKorean => 'الكورية';

  @override
  String get languageItalian => 'الإيطالية';

  @override
  String get languagePortuguese => 'البرتغالية';

  @override
  String get languageRussian => 'الروسية';

  @override
  String get languageArabic => 'العربية';

  @override
  String get chatHint => 'اسألني أي شيء عن السفر...';

  @override
  String get deleteChat => 'حذف الدردشة';

  @override
  String get deleteChatConfirmation =>
      'هل أنت متأكد من رغبتك في حذف هذه الدردشة؟';

  @override
  String get expenseAdded => 'تمت إضافة المصروف!';

  @override
  String get failedToAddExpense => 'فشل في إضافة المصروف';

  @override
  String get chatWelcomeTitle => 'مرحباً أيها المسافر!';

  @override
  String get chatWelcomeDescription =>
      'أنا TripBuddy، رفيقك في السفر! أنا هنا لمساعدتك في توثيق مغامراتك، تخطيط الأنشطة، وإنشاء يوميات سفر جميلة.';

  @override
  String get chatWhatToDo => 'ماذا تريد أن تفعل؟';

  @override
  String get tellAboutDay => 'أخبرني عن يومك';

  @override
  String get tellAboutDayDescription => 'شارك ما فعلته، رأيته، أو جربته';

  @override
  String get tellAboutDayPrompt => 'دعني أخبرك عن يومي...';

  @override
  String get planActivity => 'تخطيط نشاط';

  @override
  String get planActivityDescription => 'احصل على توصيات للأنشطة';

  @override
  String get planActivityPrompt =>
      'ما هي الأنشطة الجيدة التي يمكنني القيام بها هنا؟';

  @override
  String get logExpenseAction => 'تسجيل مصروف';

  @override
  String get logExpenseDescription => 'تتبع المصاريف في رحلتك';

  @override
  String get logExpensePrompt => 'أريد تسجيل مصروف';

  @override
  String get generateJournal => 'إنشاء يومياتي';

  @override
  String get generateJournalDescription => 'إنشاء يوميات السفر لهذا اليوم';

  @override
  String get generateJournalPrompt => 'ساعدني في كتابة يوميات سفري لهذا اليوم';

  @override
  String get askAnything => 'اسأل أي شيء';

  @override
  String get askAnythingDescription => 'نصائح السفر، معلومات محلية، توصيات';

  @override
  String get aiChats => 'دردشات AI';

  @override
  String get startNewChat => 'بدء دردشة جديدة';

  @override
  String get aiTravelAssistant => 'مساعد السفر AI';

  @override
  String get aiTravelAssistantDescription =>
      'ابدأ محادثة مع رفيق السفر AI الخاص بك لتخطيط الرحلات، والحصول على التوصيات، والمزيد!';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get errorDeletingChat => 'خطأ في حذف الدردشة';

  @override
  String todayAt(String time) {
    return 'اليوم في $time';
  }

  @override
  String yesterdayAt(String time) {
    return 'أمس في $time';
  }

  @override
  String deleteChatTitle(String title) {
    return 'حذف \"$title\"؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String get errorCreatingChat => 'خطأ في إنشاء الدردشة';

  @override
  String get errorLoadingChat => 'خطأ في تحميل الدردشة';

  @override
  String get createTripForTips => 'أنشئ رحلة للحصول على نصائح يومية!';

  @override
  String get overview => 'نظرة عامة';

  @override
  String expensesCount(int count) {
    return '$count مصروفات';
  }

  @override
  String daysTracked(int count) {
    return '$count أيام متتبعة';
  }

  @override
  String dayTrip(int count) {
    return 'رحلة $count أيام';
  }

  @override
  String daysLeft(int count) {
    return 'متبقي $count أيام';
  }

  @override
  String get byCategory => 'حسب الفئة';

  @override
  String get spendingOverTime => 'المصروفات عبر الوقت';

  @override
  String get noExpensesYet => 'لا توجد مصروفات بعد';

  @override
  String get startTrackingExpenses =>
      'ابدأ بتتبع مصاريف سفرك بإضافة أول مصروف.';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get homeCurrency => 'العملة المحلية';

  @override
  String get usDollar => 'الدولار الأمريكي';

  @override
  String get localCurrency => 'عملة الوجهة';

  @override
  String get foodAndDrinks => 'طعام ومشروبات';

  @override
  String get pleaseSelectTrip => 'الرجاء اختيار رحلة';

  @override
  String get expenseAddedSuccess => 'تمت إضافة المصروف بنجاح!';

  @override
  String get noTripsFound =>
      'لم يتم العثور على رحلات. أنشئ رحلة أولاً لإضافة المصاريف.';

  @override
  String get trip => 'رحلة';

  @override
  String get pleaseEnterAmount => 'الرجاء إدخال المبلغ';

  @override
  String get pleaseEnterValidNumber => 'الرجاء إدخال رقم صحيح';

  @override
  String get pleaseEnterDescription => 'الرجاء إدخال وصف';

  @override
  String get descriptionHintExpense => 'مثال: غداء في المقهى';

  @override
  String get addReceiptPhoto => 'إضافة صورة الإيصال';

  @override
  String get receiptPhotoComingSoon => 'صورة الإيصال قريباً!';

  @override
  String get splitThisExpense => 'تقسيم هذا المصروف؟';

  @override
  String get selectTripMembersToSplit => 'اختر رفاق السفر للتقسيم';

  @override
  String get noTripMembersToSplit =>
      'لا يوجد رفاق سفر للتقسيم. أنشئ رحلة أولاً!';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get additionalDetails => 'أي تفاصيل إضافية...';

  @override
  String get countries => 'البلدان';

  @override
  String get helpAndSupport => 'المساعدة والدعم';

  @override
  String get helpAndLegal => 'Help & Legal';

  @override
  String get freePlan => 'الخطة المجانية';

  @override
  String get upgradeUnlockFeatures =>
      'قم بالترقية لفتح رحلات غير محدودة وميزات AI';

  @override
  String get upgrade => 'ترقية';

  @override
  String get signOutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get failedToSignOut => 'فشل تسجيل الخروج';

  @override
  String get notSignedIn => 'غير مسجل الدخول';

  @override
  String get traveler => 'مسافر';

  @override
  String memberSince(String date) {
    return 'عضو منذ $date';
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
}
