import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/email_verification_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/trips/trips_screen.dart';
import '../presentation/screens/trips/trip_detail_screen.dart';
import '../presentation/screens/trips/create_trip_screen.dart';
import '../presentation/screens/trips/join_trip_screen.dart';
import '../presentation/screens/chat/chat_list_screen.dart';
import '../presentation/screens/chat/chat_screen.dart';
import '../presentation/screens/expenses/expenses_screen.dart';
import '../presentation/screens/expenses/add_expense_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/edit_profile_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/screens/journal/journal_screen.dart';
import '../presentation/screens/legal/legal_document_screen.dart';
import '../presentation/screens/onboarding/language_selection_screen.dart';
import '../presentation/screens/admin/admin_dashboard_screen.dart';
import '../presentation/screens/admin/admin_users_screen.dart';
import '../presentation/screens/admin/admin_user_detail_screen.dart';
import '../presentation/screens/admin/admin_support_screen.dart';
import '../presentation/screens/admin/admin_support_chat_screen.dart';
import '../presentation/screens/support/support_screen.dart';
import '../presentation/screens/support/support_chat_screen.dart';
import '../presentation/screens/settings/notification_settings_screen.dart';
import '../presentation/screens/settings/dnd_schedule_screen.dart';
import '../presentation/screens/onboarding/currency_selection_screen.dart';
import '../presentation/screens/onboarding/destination_selection_screen.dart';
import '../presentation/screens/onboarding/travel_dates_screen.dart';
import '../presentation/widgets/common/main_scaffold.dart';

class AppRoutes {
  AppRoutes._();

  // Route paths
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String emailVerification = '/email-verification';

  // Onboarding routes
  static const String onboardingLanguages = '/onboarding/languages';
  static const String onboardingCurrency = '/onboarding/currency';
  static const String onboardingDestination = '/onboarding/destination';
  static const String onboardingDates = '/onboarding/dates';

  // Main app routes
  static const String home = '/home';
  static const String trips = '/trips';
  static const String tripDetail = '/trips/:id';
  static const String createTrip = '/trips/create';
  static const String joinTrip = '/trips/join';
  static const String editTrip = '/trips/:id/edit';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/:id';
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String expenseDetail = '/expenses/:id';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';
  static const String notificationSettings = '/settings/notifications';
  static const String dndSchedule = '/settings/notifications/dnd';
  static const String journal = '/trips/:id/journal';

  // Legal routes
  static const String privacyPolicy = '/legal/privacy-policy';
  static const String termsOfService = '/legal/terms-of-service';
  static const String helpSupport = '/legal/help-support';

  // Admin routes
  static const String admin = '/admin';
  static const String adminUsers = '/admin/users';
  static const String adminUserDetail = '/admin/users/:id';
  static const String adminSupport = '/admin/support';
  static const String adminSupportChat = '/admin/support/:id';

  // User support routes
  static const String support = '/support';
  static const String supportChat = '/support/:id';

  // Singleton router instance
  static GoRouter? _router;
  static bool _isAuthenticated = false;

  /// Get the router instance for navigation (e.g., from notification taps)
  /// Returns null if router hasn't been initialized yet
  static GoRouter? get instance => _router;

  // Router configuration - returns singleton instance
  static GoRouter router({required bool isAuthenticated}) {
    _isAuthenticated = isAuthenticated;

    if (_router != null) {
      // Refresh the router to re-evaluate redirects
      _router!.refresh();
      return _router!;
    }

    _router = GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final isOnAuthPage = state.matchedLocation == login ||
            state.matchedLocation == register ||
            state.matchedLocation == forgotPassword ||
            state.matchedLocation == emailVerification ||
            state.matchedLocation == splash;

        final isOnOnboardingPage =
            state.matchedLocation.startsWith('/onboarding');

        // Allow unauthenticated access to onboarding pages (they're protected by auth screens)
        if (!_isAuthenticated && !isOnAuthPage && !isOnOnboardingPage) {
          return login;
        }

        if (_isAuthenticated &&
            isOnAuthPage &&
            state.matchedLocation != splash) {
          return home;
        }

        return null;
      },
      routes: [
        // Splash screen
        GoRoute(
          path: splash,
          builder: (context, state) => const SplashScreen(),
        ),

        // Auth routes
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: emailVerification,
          builder: (context, state) {
            final email = state.uri.queryParameters['email'] ?? '';
            return EmailVerificationScreen(email: email);
          },
        ),

        // Onboarding routes
        GoRoute(
          path: onboardingLanguages,
          builder: (context, state) => const LanguageSelectionScreen(),
        ),
        GoRoute(
          path: onboardingCurrency,
          builder: (context, state) => const CurrencySelectionScreen(),
        ),
        GoRoute(
          path: onboardingDestination,
          builder: (context, state) => const DestinationSelectionScreen(),
        ),
        GoRoute(
          path: onboardingDates,
          builder: (context, state) => const TravelDatesScreen(),
        ),

        // Main app shell with bottom navigation
        ShellRoute(
          builder: (context, state, child) => MainScaffold(child: child),
          routes: [
            GoRoute(
              path: home,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomeScreen(),
              ),
            ),
            GoRoute(
              path: trips,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: TripsScreen(),
              ),
            ),
            GoRoute(
              path: chat,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ChatListScreen(),
              ),
            ),
            GoRoute(
              path: expenses,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ExpensesScreen(),
              ),
            ),
            GoRoute(
              path: profile,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
            ),
          ],
        ),

        // Detail routes (outside shell)
        // IMPORTANT: createTrip and joinTrip must come BEFORE tripDetail to avoid :id matching "create" or "join"
        GoRoute(
          path: createTrip,
          builder: (context, state) => const CreateTripScreen(),
        ),
        GoRoute(
          path: joinTrip,
          builder: (context, state) => const JoinTripScreen(),
        ),
        GoRoute(
          path: tripDetail,
          builder: (context, state) {
            final tripId = state.pathParameters['id']!;
            return TripDetailScreen(tripId: tripId);
          },
        ),
        GoRoute(
          path: chatDetail,
          builder: (context, state) {
            final sessionId = state.pathParameters['id']!;
            return ChatScreen(sessionId: sessionId);
          },
        ),
        GoRoute(
          path: addExpense,
          builder: (context, state) {
            final tripId = state.uri.queryParameters['tripId'];
            return AddExpenseScreen(tripId: tripId);
          },
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: notificationSettings,
          builder: (context, state) => const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: dndSchedule,
          builder: (context, state) => const DndScheduleScreen(),
        ),
        GoRoute(
          path: editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: journal,
          builder: (context, state) {
            final tripId = state.pathParameters['id']!;
            return JournalScreen(tripId: tripId);
          },
        ),

        // Legal routes
        GoRoute(
          path: privacyPolicy,
          builder: (context, state) => const LegalDocumentScreen(
            documentType: LegalDocumentType.privacyPolicy,
          ),
        ),
        GoRoute(
          path: termsOfService,
          builder: (context, state) => const LegalDocumentScreen(
            documentType: LegalDocumentType.termsOfService,
          ),
        ),
        GoRoute(
          path: helpSupport,
          builder: (context, state) => const LegalDocumentScreen(
            documentType: LegalDocumentType.helpSupport,
          ),
        ),

        // Admin routes
        GoRoute(
          path: admin,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: adminUsers,
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: adminUserDetail,
          builder: (context, state) {
            final userId = state.pathParameters['id']!;
            return AdminUserDetailScreen(userId: userId);
          },
        ),
        GoRoute(
          path: adminSupport,
          builder: (context, state) => const AdminSupportScreen(),
        ),
        GoRoute(
          path: adminSupportChat,
          builder: (context, state) {
            final sessionId = state.pathParameters['id']!;
            return AdminSupportChatScreen(sessionId: sessionId);
          },
        ),

        // User support routes
        GoRoute(
          path: support,
          builder: (context, state) => const SupportScreen(),
        ),
        GoRoute(
          path: supportChat,
          builder: (context, state) {
            final sessionId = state.pathParameters['id']!;
            return SupportChatScreen(sessionId: sessionId);
          },
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.matchedLocation}'),
        ),
      ),
    );

    return _router!;
  }
}
