import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/forgot_password_screen.dart';
import '../presentation/screens/auth/splash_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/trips/trips_screen.dart';
import '../presentation/screens/trips/trip_detail_screen.dart';
import '../presentation/screens/trips/create_trip_screen.dart';
import '../presentation/screens/chat/chat_list_screen.dart';
import '../presentation/screens/chat/chat_screen.dart';
import '../presentation/screens/expenses/expenses_screen.dart';
import '../presentation/screens/expenses/add_expense_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/profile/settings_screen.dart';
import '../presentation/widgets/common/main_scaffold.dart';

class AppRoutes {
  AppRoutes._();

  // Route paths
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String trips = '/trips';
  static const String tripDetail = '/trips/:id';
  static const String createTrip = '/trips/create';
  static const String editTrip = '/trips/:id/edit';
  static const String chat = '/chat';
  static const String chatDetail = '/chat/:id';
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String expenseDetail = '/expenses/:id';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Navigation keys
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  // Router configuration
  static GoRouter router({required bool isAuthenticated}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: splash,
      debugLogDiagnostics: true,
      redirect: (context, state) {
        final isOnAuthPage = state.matchedLocation == login ||
            state.matchedLocation == register ||
            state.matchedLocation == forgotPassword ||
            state.matchedLocation == splash;

        if (!isAuthenticated && !isOnAuthPage) {
          return login;
        }

        if (isAuthenticated && isOnAuthPage && state.matchedLocation != splash) {
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

        // Main app shell with bottom navigation
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
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
        GoRoute(
          path: tripDetail,
          builder: (context, state) {
            final tripId = state.pathParameters['id']!;
            return TripDetailScreen(tripId: tripId);
          },
        ),
        GoRoute(
          path: createTrip,
          builder: (context, state) => const CreateTripScreen(),
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
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Page not found: ${state.matchedLocation}'),
        ),
      ),
    );
  }
}
