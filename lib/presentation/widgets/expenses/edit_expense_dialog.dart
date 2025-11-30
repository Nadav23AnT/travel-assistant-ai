import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/expenses_provider.dart';

class EditExpenseDialog extends ConsumerStatefulWidget {
  final ExpenseModel expense;

  const EditExpenseDialog({
    super.key,
    required this.expense,
  });

  @override
  ConsumerState<EditExpenseDialog> createState() => _EditExpenseDialogState();
}

class _EditExpenseDialogState extends ConsumerState<EditExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;

  late String _currency;
  late String _category;
  late DateTime _date;
  late bool _isSplit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing expense data
    _amountController = TextEditingController(
      text: widget.expense.amount.toStringAsFixed(2),
    );
    _descriptionController = TextEditingController(
      text: widget.expense.description,
    );
    _notesController = TextEditingController(
      text: widget.expense.notes ?? '',
    );
    _currency = widget.expense.currency;
    _category = widget.expense.category;
    _date = widget.expense.expenseDate ?? DateTime.now();
    _isSplit = widget.expense.isSplit;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      final notes = _notesController.text.trim();

      // Build updates map
      final updates = <String, dynamic>{
        'amount': amount,
        'currency': _currency,
        'category': _category,
        'description': description,
        'expense_date': _date.toIso8601String().split('T')[0],
        'is_split': _isSplit,
        'notes': notes.isNotEmpty ? notes : null,
      };

      // Update expense via provider
      final updatedExpense = await ref.read(expenseOperationProvider.notifier).updateExpense(
        widget.expense.id,
        widget.expense.tripId,
        updates,
      );
      final success = updatedExpense != null;

      if (!mounted) return;

      if (success) {
        // Refresh the expenses dashboard
        await ref.read(expensesDashboardRefreshProvider)();

        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).expenseUpdatedSuccess),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        if (!mounted) return;
        final error = ref.read(expenseOperationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? AppLocalizations.of(context).failedToUpdateExpense),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 400,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.editExpense,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Amount with currency
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _amountController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              style: Theme.of(context).textTheme.headlineSmall,
                              decoration: InputDecoration(
                                labelText: '${l10n.amount} *',
                                hintText: '0.00',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Text(
                                    CountryCurrencyHelper.getSymbolForCurrency(_currency),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                prefixIconConstraints: const BoxConstraints(
                                  minWidth: 48,
                                  minHeight: 48,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return l10n.pleaseEnterAmount;
                                }
                                if (double.tryParse(value) == null) {
                                  return l10n.pleaseEnterValidNumber;
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            width: 90,
                            child: DropdownButtonFormField<String>(
                              value: _currency,
                              decoration: InputDecoration(
                                labelText: l10n.currency,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                              ),
                              isExpanded: true,
                              items: AppConstants.supportedCurrencies
                                  .map((c) => DropdownMenuItem(
                                        value: c,
                                        child: Text(
                                          c,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _currency = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: '${l10n.description} *',
                          hintText: l10n.descriptionHintExpense,
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.pleaseEnterDescription;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      Text(
                        '${l10n.category} *',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.expenseCategories.map((category) {
                          final isSelected = _category == category;
                          final color = AppTheme.categoryColors[category] ??
                              AppTheme.textSecondary;
                          return ChoiceChip(
                            label: Text(_capitalizeFirst(category)),
                            selected: isSelected,
                            selectedColor: color.withAlpha(51),
                            avatar: Icon(
                              _getCategoryIcon(category),
                              size: 18,
                              color: isSelected ? color : AppTheme.textSecondary,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _category = category);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Date
                      GestureDetector(
                        onTap: _selectDate,
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: l10n.date,
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              suffixIcon: const Icon(Icons.arrow_drop_down),
                            ),
                            controller: TextEditingController(
                              text: _formatDate(_date),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Split expense toggle
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.splitThisExpense,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              Switch(
                                value: _isSplit,
                                onChanged: (value) {
                                  setState(() => _isSplit = value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: l10n.notesOptional,
                          hintText: l10n.additionalDetails,
                          alignLabelWithHint: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppTheme.textHint.withAlpha(51),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.save),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _capitalizeFirst(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'transport':
        return Icons.directions_car;
      case 'accommodation':
        return Icons.hotel;
      case 'food':
        return Icons.restaurant;
      case 'activities':
        return Icons.local_activity;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.receipt;
    }
  }
}

/// Shows the edit expense dialog and returns true if the expense was updated
Future<bool?> showEditExpenseDialog(
  BuildContext context,
  ExpenseModel expense,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => EditExpenseDialog(expense: expense),
  );
}
