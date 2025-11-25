import 'package:equatable/equatable.dart';

/// Represents an expense
class ExpenseModel extends Equatable {
  final String id;
  final String tripId;
  final String paidBy;
  final double amount;
  final String currency;
  final String category;
  final String description;
  final DateTime? expenseDate;
  final String? receiptUrl;
  final bool isSplit;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseModel({
    required this.id,
    required this.tripId,
    required this.paidBy,
    required this.amount,
    this.currency = 'USD',
    required this.category,
    required this.description,
    this.expenseDate,
    this.receiptUrl,
    this.isSplit = false,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      paidBy: json['paid_by'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      currency: json['currency'] as String? ?? 'USD',
      category: json['category'] as String,
      description: json['description'] as String,
      expenseDate: json['expense_date'] != null
          ? DateTime.parse(json['expense_date'] as String)
          : null,
      receiptUrl: json['receipt_url'] as String?,
      isSplit: json['is_split'] as bool? ?? false,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'paid_by': paidBy,
      'amount': amount,
      'currency': currency,
      'category': category,
      'description': description,
      'expense_date': expenseDate?.toIso8601String().split('T').first,
      'receipt_url': receiptUrl,
      'is_split': isSplit,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// For creating a new expense (without id, timestamps)
  Map<String, dynamic> toCreateJson() {
    return {
      'trip_id': tripId,
      'paid_by': paidBy,
      'amount': amount,
      'currency': currency,
      'category': category,
      'description': description,
      'expense_date': expenseDate?.toIso8601String().split('T').first,
      'receipt_url': receiptUrl,
      'is_split': isSplit,
      'notes': notes,
    };
  }

  ExpenseModel copyWith({
    String? id,
    String? tripId,
    String? paidBy,
    double? amount,
    String? currency,
    String? category,
    String? description,
    DateTime? expenseDate,
    String? receiptUrl,
    bool? isSplit,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      paidBy: paidBy ?? this.paidBy,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      description: description ?? this.description,
      expenseDate: expenseDate ?? this.expenseDate,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isSplit: isSplit ?? this.isSplit,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get formatted amount with currency symbol
  String get formattedAmount {
    final symbols = {
      'USD': '\$',
      'EUR': '\u20AC',
      'GBP': '\u00A3',
      'ILS': '\u20AA',
      'JPY': '\u00A5',
    };
    final symbol = symbols[currency] ?? currency;
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  /// Get category display name
  String get categoryDisplayName {
    switch (category) {
      case 'transport':
        return 'Transport';
      case 'accommodation':
        return 'Accommodation';
      case 'food':
        return 'Food & Drinks';
      case 'activities':
        return 'Activities';
      case 'shopping':
        return 'Shopping';
      case 'other':
        return 'Other';
      default:
        return category;
    }
  }

  /// Get category icon name
  String get categoryIcon {
    switch (category) {
      case 'transport':
        return 'directions_car';
      case 'accommodation':
        return 'hotel';
      case 'food':
        return 'restaurant';
      case 'activities':
        return 'attractions';
      case 'shopping':
        return 'shopping_bag';
      case 'other':
        return 'receipt_long';
      default:
        return 'receipt';
    }
  }

  @override
  List<Object?> get props => [id, tripId, amount, category, description];
}
