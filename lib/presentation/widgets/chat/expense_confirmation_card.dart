import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../config/theme.dart';
import '../../../services/ai_service.dart';

/// A card shown in chat when AI detects an expense, allowing user to confirm or edit
class ExpenseConfirmationCard extends StatefulWidget {
  final ParsedExpense expense;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;
  final Function(ParsedExpense) onEdit;

  const ExpenseConfirmationCard({
    super.key,
    required this.expense,
    required this.onConfirm,
    required this.onDismiss,
    required this.onEdit,
  });

  @override
  State<ExpenseConfirmationCard> createState() => _ExpenseConfirmationCardState();
}

class _ExpenseConfirmationCardState extends State<ExpenseConfirmationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isEditing = false;
  late ParsedExpense _editedExpense;

  // Controllers for editing
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String _selectedCategory = 'other';
  String _selectedCurrency = 'USD';

  static const _categories = [
    ('transport', 'Transport', Icons.directions_car),
    ('accommodation', 'Accommodation', Icons.hotel),
    ('food', 'Food & Drinks', Icons.restaurant),
    ('activities', 'Activities', Icons.attractions),
    ('shopping', 'Shopping', Icons.shopping_bag),
    ('other', 'Other', Icons.receipt_long),
  ];

  static const _currencies = ['USD', 'EUR', 'GBP', 'ILS', 'JPY'];

  @override
  void initState() {
    super.initState();
    _editedExpense = widget.expense;
    _selectedCategory = widget.expense.category;
    _selectedCurrency = widget.expense.currency;
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveEdit() {
    final amount = double.tryParse(_amountController.text) ?? widget.expense.amount;
    _editedExpense = _editedExpense.copyWith(
      amount: amount,
      description: _descriptionController.text,
      category: _selectedCategory,
      currency: _selectedCurrency,
    );
    widget.onEdit(_editedExpense);
    setState(() {
      _isEditing = false;
    });
  }

  IconData _getCategoryIcon(String category) {
    return _categories
        .firstWhere(
          (c) => c.$1 == category,
          orElse: () => _categories.last,
        )
        .$3;
  }

  Color _getCategoryColor(String category) {
    return AppTheme.categoryColors[category] ?? AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withAlpha(77),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withAlpha(26),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withAlpha(51),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_outlined,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Expense Detected',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Spacer(),
                  if (!_isEditing)
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: _toggleEdit,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      color: AppTheme.textSecondary,
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: _isEditing ? _buildEditMode() : _buildViewMode(),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isEditing ? _toggleEdit : widget.onDismiss,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                      ),
                      child: Text(_isEditing ? 'Cancel' : 'Dismiss'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isEditing ? _saveEdit : widget.onConfirm,
                      icon: Icon(
                        _isEditing ? Icons.check : Icons.add_circle_outline,
                        size: 18,
                      ),
                      label: Text(_isEditing ? 'Save' : 'Add Expense'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewMode() {
    final expense = _editedExpense;
    return Row(
      children: [
        // Category Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getCategoryColor(expense.category).withAlpha(26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: _getCategoryColor(expense.category),
            size: 28,
          ),
        ),
        const SizedBox(width: 16),

        // Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.description,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                expense.categoryDisplayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
        ),

        // Amount
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              expense.formattedAmount,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
            ),
            Text(
              _formatDate(expense.date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textHint,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount and Currency Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCurrency,
                decoration: InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                items: _currencies.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCurrency = value ?? 'USD';
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        TextField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            prefixIcon: const Icon(Icons.description_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          maxLines: 1,
        ),
        const SizedBox(height: 16),

        // Category Selection
        Text(
          'Category',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((cat) {
            final isSelected = _selectedCategory == cat.$1;
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat.$3,
                    size: 16,
                    color: isSelected ? Colors.white : _getCategoryColor(cat.$1),
                  ),
                  const SizedBox(width: 4),
                  Text(cat.$2),
                ],
              ),
              selected: isSelected,
              selectedColor: _getCategoryColor(cat.$1),
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = cat.$1;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
