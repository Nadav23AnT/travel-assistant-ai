import 'package:equatable/equatable.dart';

/// Represents a split portion of an expense owed by a user
class ExpenseSplitModel extends Equatable {
  final String id;
  final String expenseId;
  final String userId;
  final double amount;
  final bool isSettled;
  final DateTime? settledAt;
  final DateTime createdAt;

  /// Optional: User info if joined with profiles
  final String? userName;
  final String? userAvatarUrl;
  final String? userEmail;

  /// Optional: Expense info if joined with expenses
  final String? expensePaidBy;
  final String? expenseCurrency;
  final double? expenseAmount;
  final String? expenseDescription;

  /// Optional: Payer's profile info if joined
  final String? payerName;
  final String? payerAvatarUrl;
  final String? payerEmail;

  const ExpenseSplitModel({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.amount,
    this.isSettled = false,
    this.settledAt,
    required this.createdAt,
    this.userName,
    this.userAvatarUrl,
    this.userEmail,
    this.expensePaidBy,
    this.expenseCurrency,
    this.expenseAmount,
    this.expenseDescription,
    this.payerName,
    this.payerAvatarUrl,
    this.payerEmail,
  });

  /// Display name for the payer
  String get payerDisplayName {
    if (payerName != null && payerName!.isNotEmpty) {
      return payerName!;
    }
    if (payerEmail != null && payerEmail!.isNotEmpty) {
      return payerEmail!.split('@').first;
    }
    return 'Unknown';
  }

  /// Display name for the user
  String get displayName {
    if (userName != null && userName!.isNotEmpty) {
      return userName!;
    }
    if (userEmail != null && userEmail!.isNotEmpty) {
      return userEmail!.split('@').first;
    }
    return 'Unknown';
  }

  /// Get initials for avatar fallback
  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    // Handle nested profile data if present
    final profile = json['profiles'] as Map<String, dynamic>?;
    // Handle nested expense data if present
    final expense = json['expenses'] as Map<String, dynamic>?;
    // Handle nested payer profile data if present
    final payer = expense?['payer'] as Map<String, dynamic>?;

    return ExpenseSplitModel(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String,
      userId: json['user_id'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      isSettled: json['is_settled'] as bool? ?? false,
      settledAt: json['settled_at'] != null
          ? DateTime.parse(json['settled_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      userName: profile?['full_name'] as String? ?? json['user_name'] as String?,
      userAvatarUrl:
          profile?['avatar_url'] as String? ?? json['user_avatar_url'] as String?,
      userEmail: profile?['email'] as String? ?? json['user_email'] as String?,
      expensePaidBy: expense?['paid_by'] as String?,
      expenseCurrency: expense?['currency'] as String?,
      expenseAmount: expense?['amount'] != null
          ? double.tryParse(expense!['amount'].toString())
          : null,
      expenseDescription: expense?['description'] as String?,
      payerName: payer?['full_name'] as String?,
      payerAvatarUrl: payer?['avatar_url'] as String?,
      payerEmail: payer?['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expense_id': expenseId,
      'user_id': userId,
      'amount': amount,
      'is_settled': isSettled,
      'settled_at': settledAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// For creating a new split (without id, timestamps)
  Map<String, dynamic> toCreateJson() {
    return {
      'expense_id': expenseId,
      'user_id': userId,
      'amount': amount,
      'is_settled': isSettled,
    };
  }

  ExpenseSplitModel copyWith({
    String? id,
    String? expenseId,
    String? userId,
    double? amount,
    bool? isSettled,
    DateTime? settledAt,
    DateTime? createdAt,
    String? userName,
    String? userAvatarUrl,
    String? userEmail,
    String? expensePaidBy,
    String? expenseCurrency,
    double? expenseAmount,
    String? expenseDescription,
    String? payerName,
    String? payerAvatarUrl,
    String? payerEmail,
  }) {
    return ExpenseSplitModel(
      id: id ?? this.id,
      expenseId: expenseId ?? this.expenseId,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      isSettled: isSettled ?? this.isSettled,
      settledAt: settledAt ?? this.settledAt,
      createdAt: createdAt ?? this.createdAt,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      userEmail: userEmail ?? this.userEmail,
      expensePaidBy: expensePaidBy ?? this.expensePaidBy,
      expenseCurrency: expenseCurrency ?? this.expenseCurrency,
      expenseAmount: expenseAmount ?? this.expenseAmount,
      expenseDescription: expenseDescription ?? this.expenseDescription,
      payerName: payerName ?? this.payerName,
      payerAvatarUrl: payerAvatarUrl ?? this.payerAvatarUrl,
      payerEmail: payerEmail ?? this.payerEmail,
    );
  }

  @override
  List<Object?> get props => [id, expenseId, userId, amount, isSettled, expenseCurrency];
}

/// Represents a member's balance in a trip
class MemberBalanceModel extends Equatable {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final double totalPaid;
  final double totalOwed;
  final double transfersSent;
  final double transfersReceived;
  final double balance; // positive = others owe you, negative = you owe others

  const MemberBalanceModel({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.totalPaid,
    required this.totalOwed,
    this.transfersSent = 0.0,
    this.transfersReceived = 0.0,
    required this.balance,
  });

  /// Display name with fallback
  String get displayName => userName.isNotEmpty ? userName : 'Unknown';

  /// Get initials for avatar fallback
  String get initials {
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  /// Whether this member is owed money
  bool get isOwedMoney => balance > 0;

  /// Whether this member owes money
  bool get owesMoney => balance < 0;

  /// Whether this member is settled up
  bool get isSettled => balance == 0;

  factory MemberBalanceModel.fromJson(Map<String, dynamic> json) {
    return MemberBalanceModel(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      totalPaid: double.tryParse(json['total_paid'].toString()) ?? 0.0,
      totalOwed: double.tryParse(json['total_owed'].toString()) ?? 0.0,
      transfersSent: double.tryParse(json['transfers_sent'].toString()) ?? 0.0,
      transfersReceived: double.tryParse(json['transfers_received'].toString()) ?? 0.0,
      balance: double.tryParse(json['balance'].toString()) ?? 0.0,
    );
  }

  @override
  List<Object?> get props => [userId, userName, totalPaid, totalOwed, transfersSent, transfersReceived, balance];
}

/// Represents a settlement between two members
class SettlementModel extends Equatable {
  final String fromUserId;
  final String fromUserName;
  final String? fromAvatarUrl;
  final String toUserId;
  final String toUserName;
  final String? toAvatarUrl;
  final double amount;

  const SettlementModel({
    required this.fromUserId,
    required this.fromUserName,
    this.fromAvatarUrl,
    required this.toUserId,
    required this.toUserName,
    this.toAvatarUrl,
    required this.amount,
  });

  @override
  List<Object?> get props => [fromUserId, toUserId, amount];
}
