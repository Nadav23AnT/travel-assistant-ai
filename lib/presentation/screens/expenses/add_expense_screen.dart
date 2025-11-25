import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';

class AddExpenseScreen extends StatefulWidget {
  final String? tripId;

  const AddExpenseScreen({
    super.key,
    this.tripId,
  });

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String _currency = AppConstants.defaultCurrency;
  String _category = 'food';
  DateTime _date = DateTime.now();
  bool _isSplit = false;
  bool _isLoading = false;

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

    // TODO: Implement actual expense creation with Supabase
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Expense added successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Add Expense'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: const InputDecoration(
                        labelText: 'Amount *',
                        hintText: '0.00',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                      ),
                      items: AppConstants.supportedCurrencies
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c),
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
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'e.g., Lunch at Cafe',
                  prefixIcon: Icon(Icons.description_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Category
              Text(
                'Category *',
                style: Theme.of(context).textTheme.titleMedium,
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
              const SizedBox(height: 24),

              // Date
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    controller: TextEditingController(
                      text: _formatDate(_date),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Receipt photo
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement image picker for receipt
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Add Receipt Photo'),
              ),
              const SizedBox(height: 24),

              // Split expense
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Split this expense?',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Switch(
                            value: _isSplit,
                            onChanged: (value) {
                              setState(() => _isSplit = value);
                            },
                          ),
                        ],
                      ),
                      if (_isSplit) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Select trip members to split with',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        // Placeholder for trip members
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'No trip members to split with. Create a trip first!',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'Any additional details...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
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
