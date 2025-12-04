import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../data/repositories/notification_settings_repository.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('NotificationService: Background message: ${message.messageId}');
}

/// Notification channel configuration
class NotificationChannels {
  static const String generalId = 'waylo_general';
  static const String generalName = 'General Notifications';
  static const String generalDesc = 'General app notifications';

  static const String tripId = 'waylo_trips';
  static const String tripName = 'Trip Notifications';
  static const String tripDesc = 'Trip reminders and updates';

  static const String expenseId = 'waylo_expenses';
  static const String expenseName = 'Expense Notifications';
  static const String expenseDesc = 'Expense reminders and budget alerts';

  static const String journalId = 'waylo_journal';
  static const String journalName = 'Journal Notifications';
  static const String journalDesc = 'Journal prompts and updates';

  static const String supportId = 'waylo_support';
  static const String supportName = 'Support Notifications';
  static const String supportDesc = 'Support ticket updates';
}

/// Service for managing push and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final NotificationSettingsRepository _settingsRepo =
      NotificationSettingsRepository();

  bool _initialized = false;
  String? _fcmToken;

  /// Get the current FCM token
  String? get fcmToken => _fcmToken;

  /// Check if service is initialized
  bool get isInitialized => _initialized;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone data
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('UTC'));

      // Initialize Firebase if not already done
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }

      // Set up background message handler
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await requestPermissions();

      // Get and store FCM token
      await _setupFcmToken();

      // Set up foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Set up notification tap handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Check for initial notification (app opened from terminated state)
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }

      _initialized = true;
      debugPrint('NotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('NotificationService: Initialization error: $e');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  /// Create Android notification channels
  Future<void> _createNotificationChannels() async {
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // General channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.generalId,
        NotificationChannels.generalName,
        description: NotificationChannels.generalDesc,
        importance: Importance.defaultImportance,
      ),
    );

    // Trip channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.tripId,
        NotificationChannels.tripName,
        description: NotificationChannels.tripDesc,
        importance: Importance.high,
      ),
    );

    // Expense channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.expenseId,
        NotificationChannels.expenseName,
        description: NotificationChannels.expenseDesc,
        importance: Importance.defaultImportance,
      ),
    );

    // Journal channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.journalId,
        NotificationChannels.journalName,
        description: NotificationChannels.journalDesc,
        importance: Importance.defaultImportance,
      ),
    );

    // Support channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.supportId,
        NotificationChannels.supportName,
        description: NotificationChannels.supportDesc,
        importance: Importance.high,
      ),
    );
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final granted = settings.authorizationStatus ==
              AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      debugPrint(
          'NotificationService: Permission status: ${settings.authorizationStatus}');

      return granted;
    } catch (e) {
      debugPrint('NotificationService: Permission request error: $e');
      return false;
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Set up FCM token and listen for refreshes
  Future<void> _setupFcmToken() async {
    try {
      // Get current token
      _fcmToken = await _messaging.getToken();
      debugPrint('NotificationService: FCM Token: $_fcmToken');

      // Save to Supabase
      await _saveFcmTokenToSupabase();

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) async {
        _fcmToken = newToken;
        await _saveFcmTokenToSupabase();
        debugPrint('NotificationService: FCM Token refreshed');
      });
    } catch (e) {
      debugPrint('NotificationService: FCM token error: $e');
    }
  }

  /// Save FCM token to Supabase
  Future<void> _saveFcmTokenToSupabase() async {
    if (_fcmToken == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await _settingsRepo.saveFcmToken(user.id, _fcmToken!);
  }

  /// Clear FCM token from Supabase (call on logout)
  Future<void> clearFcmToken() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await _settingsRepo.clearFcmToken(user.id);
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('NotificationService: Foreground message: ${message.messageId}');

    final notification = message.notification;
    if (notification == null) return;

    // Show local notification
    showLocalNotification(
      title: notification.title ?? 'Waylo',
      body: notification.body ?? '',
      payload: jsonEncode(message.data),
      channelId: _getChannelFromData(message.data),
    );
  }

  /// Handle notification tap (app in background)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('NotificationService: Notification tapped: ${message.data}');
    _navigateFromNotification(message.data);
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(NotificationResponse response) {
    debugPrint('NotificationService: Local notification tapped');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateFromNotification(data);
      } catch (e) {
        debugPrint('NotificationService: Error parsing payload: $e');
      }
    }
  }

  /// Navigate based on notification data
  void _navigateFromNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final id = data['id'] as String?;

    // Navigation will be handled by the app's navigation system
    // This could emit events or use a navigator key
    debugPrint('NotificationService: Navigate to type=$type, id=$id');

    // TODO: Implement navigation using GoRouter or a global navigator key
    // Example: navigatorKey.currentState?.pushNamed('/trips/$id')
  }

  /// Get appropriate channel from notification data
  String _getChannelFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'trip_reminder':
      case 'trip_status':
      case 'weather_warning':
        return NotificationChannels.tripId;
      case 'expense_reminder':
      case 'budget_alert':
        return NotificationChannels.expenseId;
      case 'journal_ready':
      case 'journal_prompt':
        return NotificationChannels.journalId;
      case 'support_reply':
      case 'ticket_update':
        return NotificationChannels.supportId;
      default:
        return NotificationChannels.generalId;
    }
  }

  /// Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = NotificationChannels.generalId,
    int? id,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule a local notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = NotificationChannels.generalId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  /// Schedule daily reminder at specific time
  Future<void> scheduleDailyReminder({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    String? payload,
    String channelId = NotificationChannels.generalId,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Calculate next occurrence of the time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      _convertToTZDateTime(scheduledDate),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  /// Cancel a scheduled notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Convert DateTime to TZDateTime for scheduling
  tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
    // Using local timezone
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case NotificationChannels.tripId:
        return NotificationChannels.tripName;
      case NotificationChannels.expenseId:
        return NotificationChannels.expenseName;
      case NotificationChannels.journalId:
        return NotificationChannels.journalName;
      case NotificationChannels.supportId:
        return NotificationChannels.supportName;
      default:
        return NotificationChannels.generalName;
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case NotificationChannels.tripId:
        return NotificationChannels.tripDesc;
      case NotificationChannels.expenseId:
        return NotificationChannels.expenseDesc;
      case NotificationChannels.journalId:
        return NotificationChannels.journalDesc;
      case NotificationChannels.supportId:
        return NotificationChannels.supportDesc;
      default:
        return NotificationChannels.generalDesc;
    }
  }
}

/// Notification IDs for scheduled notifications
class NotificationIds {
  static const int expenseReminder = 1001;
  static const int journalPrompt = 1002;
  static const int tripReminder = 1003;
  static const int weeklySpendingSummary = 1004;
  static const int rateAppReminder = 1005;
}
