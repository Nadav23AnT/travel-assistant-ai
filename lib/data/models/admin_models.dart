// Admin Dashboard Models
// Contains all models used for admin functionality including
// user management, support chat, and system statistics.

/// Extended user model for admin view with aggregated stats
class AdminUserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String defaultCurrency;
  final String planType;
  final bool isAdmin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Aggregated stats
  final int tripsCount;
  final int expensesCount;
  final double totalExpenses;
  final int chatSessionsCount;
  final int todayTokensUsed;
  final int dailyTokenLimit;
  final DateTime? lastActivityAt;

  // Subscription info
  final String? subscriptionStatus;
  final DateTime? subscriptionExpiresAt;

  const AdminUserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    required this.defaultCurrency,
    required this.planType,
    required this.isAdmin,
    required this.createdAt,
    this.updatedAt,
    this.tripsCount = 0,
    this.expensesCount = 0,
    this.totalExpenses = 0,
    this.chatSessionsCount = 0,
    this.todayTokensUsed = 0,
    this.dailyTokenLimit = 10000,
    this.lastActivityAt,
    this.subscriptionStatus,
    this.subscriptionExpiresAt,
  });

  factory AdminUserModel.fromJson(Map<String, dynamic> json) {
    return AdminUserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      defaultCurrency: json['default_currency'] as String? ?? 'USD',
      planType: json['plan_type'] as String? ?? 'free',
      isAdmin: json['is_admin'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      tripsCount: json['trips_count'] as int? ?? 0,
      expensesCount: json['expenses_count'] as int? ?? 0,
      totalExpenses: (json['total_expenses'] as num?)?.toDouble() ?? 0,
      chatSessionsCount: json['chat_sessions_count'] as int? ?? 0,
      todayTokensUsed: json['today_tokens_used'] as int? ?? 0,
      dailyTokenLimit: json['daily_token_limit'] as int? ?? 10000,
      lastActivityAt: json['last_activity_at'] != null
          ? DateTime.parse(json['last_activity_at'] as String)
          : null,
      subscriptionStatus: json['subscription_status'] as String?,
      subscriptionExpiresAt: json['subscription_expires_at'] != null
          ? DateTime.parse(json['subscription_expires_at'] as String)
          : null,
    );
  }

  /// Display name for the user
  String get displayName => fullName?.isNotEmpty == true ? fullName! : email;

  /// Check if user is premium/subscribed
  bool get isPremium => planType == 'subscription';

  /// Check if subscription is active
  bool get hasActiveSubscription =>
      subscriptionStatus == 'active' &&
      (subscriptionExpiresAt == null ||
          subscriptionExpiresAt!.isAfter(DateTime.now()));

  /// Token usage percentage
  double get tokenUsagePercent =>
      dailyTokenLimit > 0 ? (todayTokensUsed / dailyTokenLimit) * 100 : 0;

  /// Remaining tokens
  int get tokensRemaining =>
      dailyTokenLimit > todayTokensUsed ? dailyTokenLimit - todayTokensUsed : 0;
}

/// Support session model
class SupportSessionModel {
  final String id;
  final String userId;
  final String? adminId;
  final String subject;
  final SupportStatus status;
  final SupportPriority priority;
  final FeedbackType feedbackType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  final DateTime? lastMessageAt;
  final int unreadAdminCount;
  final int unreadUserCount;

  // Joined user info
  final String? userEmail;
  final String? userFullName;
  final String? userAvatarUrl;

  // Joined admin info
  final String? adminEmail;
  final String? adminFullName;

  const SupportSessionModel({
    required this.id,
    required this.userId,
    this.adminId,
    required this.subject,
    required this.status,
    required this.priority,
    this.feedbackType = FeedbackType.generalSupport,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    this.lastMessageAt,
    this.unreadAdminCount = 0,
    this.unreadUserCount = 0,
    this.userEmail,
    this.userFullName,
    this.userAvatarUrl,
    this.adminEmail,
    this.adminFullName,
  });

  factory SupportSessionModel.fromJson(Map<String, dynamic> json) {
    // Handle joined user data
    final userData = json['user'] as Map<String, dynamic>?;
    final adminData = json['admin'] as Map<String, dynamic>?;

    return SupportSessionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      adminId: json['admin_id'] as String?,
      subject: json['subject'] as String,
      status: SupportStatus.fromString(json['status'] as String? ?? 'open'),
      priority:
          SupportPriority.fromString(json['priority'] as String? ?? 'normal'),
      feedbackType: FeedbackType.fromString(
          json['feedback_type'] as String? ?? 'general_support'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'] as String)
          : null,
      unreadAdminCount: json['unread_admin_count'] as int? ?? 0,
      unreadUserCount: json['unread_user_count'] as int? ?? 0,
      userEmail: userData?['email'] as String?,
      userFullName: userData?['full_name'] as String?,
      userAvatarUrl: userData?['avatar_url'] as String?,
      adminEmail: adminData?['email'] as String?,
      adminFullName: adminData?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'admin_id': adminId,
        'subject': subject,
        'status': status.value,
        'priority': priority.value,
        'feedback_type': feedbackType.value,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'resolved_at': resolvedAt?.toIso8601String(),
        'last_message_at': lastMessageAt?.toIso8601String(),
        'unread_admin_count': unreadAdminCount,
        'unread_user_count': unreadUserCount,
      };

  /// User display name
  String get userDisplayName =>
      userFullName?.isNotEmpty == true ? userFullName! : (userEmail ?? 'User');

  /// Admin display name
  String get adminDisplayName =>
      adminFullName?.isNotEmpty == true ? adminFullName! : (adminEmail ?? 'Admin');

  /// Check if session is open
  bool get isOpen => status == SupportStatus.open || status == SupportStatus.inProgress;

  /// Check if assigned to an admin
  bool get isAssigned => adminId != null;

  SupportSessionModel copyWith({
    String? id,
    String? userId,
    String? adminId,
    String? subject,
    SupportStatus? status,
    SupportPriority? priority,
    FeedbackType? feedbackType,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    DateTime? lastMessageAt,
    int? unreadAdminCount,
    int? unreadUserCount,
    String? userEmail,
    String? userFullName,
    String? userAvatarUrl,
    String? adminEmail,
    String? adminFullName,
  }) {
    return SupportSessionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      adminId: adminId ?? this.adminId,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      feedbackType: feedbackType ?? this.feedbackType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadAdminCount: unreadAdminCount ?? this.unreadAdminCount,
      unreadUserCount: unreadUserCount ?? this.unreadUserCount,
      userEmail: userEmail ?? this.userEmail,
      userFullName: userFullName ?? this.userFullName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      adminEmail: adminEmail ?? this.adminEmail,
      adminFullName: adminFullName ?? this.adminFullName,
    );
  }
}

/// Support message model
class SupportMessageModel {
  final String id;
  final String sessionId;
  final String senderId;
  final SenderRole senderRole;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  // Joined sender info
  final String? senderEmail;
  final String? senderFullName;
  final String? senderAvatarUrl;

  const SupportMessageModel({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
    this.senderEmail,
    this.senderFullName,
    this.senderAvatarUrl,
  });

  factory SupportMessageModel.fromJson(Map<String, dynamic> json) {
    // Handle joined sender data
    final senderData = json['sender'] as Map<String, dynamic>?;

    return SupportMessageModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      senderId: json['sender_id'] as String,
      senderRole: SenderRole.fromString(json['sender_role'] as String),
      content: json['content'] as String,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      senderEmail: senderData?['email'] as String?,
      senderFullName: senderData?['full_name'] as String?,
      senderAvatarUrl: senderData?['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'session_id': sessionId,
        'sender_id': senderId,
        'sender_role': senderRole.value,
        'content': content,
        'is_read': isRead,
        'created_at': createdAt.toIso8601String(),
      };

  /// Check if message is from admin
  bool get isFromAdmin => senderRole == SenderRole.admin;

  /// Check if message is from user
  bool get isFromUser => senderRole == SenderRole.user;

  /// Sender display name
  String get senderDisplayName =>
      senderFullName?.isNotEmpty == true
          ? senderFullName!
          : (senderEmail ?? (isFromAdmin ? 'Admin' : 'User'));
}

/// System statistics model for admin dashboard
class SystemStatsModel {
  // Basic counts
  final int totalUsers;
  final int totalTrips;
  final int activeTrips;
  final int totalExpenses;
  final int totalChatSessions;
  final int openSupportTickets;

  // Growth stats
  final int usersToday;
  final int usersThisWeek;
  final int usersThisMonth;
  final int premiumUsers;

  // Active users
  final int activeUsersToday;
  final int activeUsersWeek;
  final int activeUsersMonth;
  final int liveUsers;

  // Token usage
  final int totalTokensToday;
  final int totalTokensWeek;
  final int avgTokensPerUser;
  final int totalRequestsToday;

  // Trip & expense stats
  final int tripsCreatedToday;
  final int tripsCreatedWeek;
  final int expensesLoggedToday;
  final double totalExpenseAmountToday;

  // Chat engagement
  final int chatMessagesToday;
  final int avgMessagesPerSession;

  const SystemStatsModel({
    required this.totalUsers,
    required this.totalTrips,
    required this.activeTrips,
    required this.totalExpenses,
    required this.totalChatSessions,
    required this.openSupportTickets,
    required this.usersToday,
    this.usersThisWeek = 0,
    this.usersThisMonth = 0,
    required this.premiumUsers,
    this.activeUsersToday = 0,
    this.activeUsersWeek = 0,
    this.activeUsersMonth = 0,
    this.liveUsers = 0,
    this.totalTokensToday = 0,
    this.totalTokensWeek = 0,
    this.avgTokensPerUser = 0,
    this.totalRequestsToday = 0,
    this.tripsCreatedToday = 0,
    this.tripsCreatedWeek = 0,
    this.expensesLoggedToday = 0,
    this.totalExpenseAmountToday = 0,
    this.chatMessagesToday = 0,
    this.avgMessagesPerSession = 0,
  });

  factory SystemStatsModel.fromJson(Map<String, dynamic> json) {
    return SystemStatsModel(
      totalUsers: json['total_users'] as int? ?? 0,
      totalTrips: json['total_trips'] as int? ?? 0,
      activeTrips: json['active_trips'] as int? ?? 0,
      totalExpenses: json['total_expenses'] as int? ?? 0,
      totalChatSessions: json['total_chat_sessions'] as int? ?? 0,
      openSupportTickets: json['open_support_tickets'] as int? ?? 0,
      usersToday: json['users_today'] as int? ?? 0,
      usersThisWeek: json['users_this_week'] as int? ?? 0,
      usersThisMonth: json['users_this_month'] as int? ?? 0,
      premiumUsers: json['premium_users'] as int? ?? 0,
      activeUsersToday: json['active_users_today'] as int? ?? 0,
      activeUsersWeek: json['active_users_week'] as int? ?? 0,
      activeUsersMonth: json['active_users_month'] as int? ?? 0,
      liveUsers: json['live_users'] as int? ?? 0,
      totalTokensToday: json['total_tokens_today'] as int? ?? 0,
      totalTokensWeek: json['total_tokens_week'] as int? ?? 0,
      avgTokensPerUser: json['avg_tokens_per_user'] as int? ?? 0,
      totalRequestsToday: json['total_requests_today'] as int? ?? 0,
      tripsCreatedToday: json['trips_created_today'] as int? ?? 0,
      tripsCreatedWeek: json['trips_created_week'] as int? ?? 0,
      expensesLoggedToday: json['expenses_logged_today'] as int? ?? 0,
      totalExpenseAmountToday: (json['total_expense_amount_today'] as num?)?.toDouble() ?? 0,
      chatMessagesToday: json['chat_messages_today'] as int? ?? 0,
      avgMessagesPerSession: json['avg_messages_per_session'] as int? ?? 0,
    );
  }

  /// Percentage of premium users
  double get premiumPercentage =>
      totalUsers > 0 ? (premiumUsers / totalUsers) * 100 : 0;

  /// Percentage of active trips
  double get activeTripsPercentage =>
      totalTrips > 0 ? (activeTrips / totalTrips) * 100 : 0;

  /// Retention rate (active users / total users)
  double get retentionRate =>
      totalUsers > 0 ? (activeUsersMonth / totalUsers) * 100 : 0;
}

/// Support ticket status enum
enum SupportStatus {
  open('open'),
  inProgress('in_progress'),
  resolved('resolved'),
  closed('closed');

  final String value;
  const SupportStatus(this.value);

  static SupportStatus fromString(String value) {
    return SupportStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => SupportStatus.open,
    );
  }

  String get displayName {
    switch (this) {
      case SupportStatus.open:
        return 'Open';
      case SupportStatus.inProgress:
        return 'In Progress';
      case SupportStatus.resolved:
        return 'Resolved';
      case SupportStatus.closed:
        return 'Closed';
    }
  }
}

/// Support ticket priority enum
enum SupportPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  final String value;
  const SupportPriority(this.value);

  static SupportPriority fromString(String value) {
    return SupportPriority.values.firstWhere(
      (p) => p.value == value,
      orElse: () => SupportPriority.normal,
    );
  }

  String get displayName {
    switch (this) {
      case SupportPriority.low:
        return 'Low';
      case SupportPriority.normal:
        return 'Normal';
      case SupportPriority.high:
        return 'High';
      case SupportPriority.urgent:
        return 'Urgent';
    }
  }
}

/// Message sender role enum
enum SenderRole {
  user('user'),
  admin('admin');

  final String value;
  const SenderRole(this.value);

  static SenderRole fromString(String value) {
    return SenderRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => SenderRole.user,
    );
  }
}

/// Feedback type enum for beta user feedback categorization
enum FeedbackType {
  bugReport('bug_report'),
  featureRequest('feature_request'),
  uxFeedback('ux_feedback'),
  generalSupport('general_support');

  final String value;
  const FeedbackType(this.value);

  static FeedbackType fromString(String value) {
    return FeedbackType.values.firstWhere(
      (f) => f.value == value,
      orElse: () => FeedbackType.generalSupport,
    );
  }

  String get displayName {
    switch (this) {
      case FeedbackType.bugReport:
        return 'Bug Report';
      case FeedbackType.featureRequest:
        return 'Feature Request';
      case FeedbackType.uxFeedback:
        return 'UX Feedback';
      case FeedbackType.generalSupport:
        return 'General Support';
    }
  }

  String get icon {
    switch (this) {
      case FeedbackType.bugReport:
        return 'bug_report';
      case FeedbackType.featureRequest:
        return 'lightbulb';
      case FeedbackType.uxFeedback:
        return 'touch_app';
      case FeedbackType.generalSupport:
        return 'help';
    }
  }
}

/// User data type for selective deletion
enum UserDataType {
  expenses,
  trips,
  chatHistory,
  journalEntries,
  tokenUsage,
  all;

  String get displayName {
    switch (this) {
      case UserDataType.expenses:
        return 'Expenses';
      case UserDataType.trips:
        return 'Trips';
      case UserDataType.chatHistory:
        return 'Chat History';
      case UserDataType.journalEntries:
        return 'Journal Entries';
      case UserDataType.tokenUsage:
        return 'Token Usage';
      case UserDataType.all:
        return 'All Data';
    }
  }
}

// ============================================
// Trend Data Models for Charts
// ============================================

/// User growth data point for charts
class UserGrowthPoint {
  final DateTime date;
  final int newUsers;
  final int cumulativeUsers;

  const UserGrowthPoint({
    required this.date,
    required this.newUsers,
    required this.cumulativeUsers,
  });

  factory UserGrowthPoint.fromJson(Map<String, dynamic> json) {
    return UserGrowthPoint(
      date: DateTime.parse(json['date'] as String),
      newUsers: json['new_users'] as int? ?? 0,
      cumulativeUsers: json['cumulative_users'] as int? ?? 0,
    );
  }
}

/// Token usage data point for charts
class TokenUsagePoint {
  final DateTime date;
  final int totalTokens;
  final int totalRequests;
  final int uniqueUsers;

  const TokenUsagePoint({
    required this.date,
    required this.totalTokens,
    required this.totalRequests,
    required this.uniqueUsers,
  });

  factory TokenUsagePoint.fromJson(Map<String, dynamic> json) {
    return TokenUsagePoint(
      date: DateTime.parse(json['date'] as String),
      totalTokens: json['total_tokens'] as int? ?? 0,
      totalRequests: json['total_requests'] as int? ?? 0,
      uniqueUsers: json['unique_users'] as int? ?? 0,
    );
  }
}

/// Peak hours data point for charts
class PeakHoursPoint {
  final int hour;
  final int messageCount;

  const PeakHoursPoint({
    required this.hour,
    required this.messageCount,
  });

  factory PeakHoursPoint.fromJson(Map<String, dynamic> json) {
    return PeakHoursPoint(
      hour: json['hour'] as int? ?? 0,
      messageCount: json['message_count'] as int? ?? 0,
    );
  }

  String get hourLabel {
    if (hour == 0) return '12 AM';
    if (hour == 12) return '12 PM';
    if (hour < 12) return '$hour AM';
    return '${hour - 12} PM';
  }
}
