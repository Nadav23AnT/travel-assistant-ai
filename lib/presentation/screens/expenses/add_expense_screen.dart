import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/trips_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final String? tripId;

  const AddExpenseScreen({
    super.key,
    this.tripId,
  });

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedTripId;
  String _currency = AppConstants.defaultCurrency;
  String _category = 'food';
  DateTime _date = DateTime.now();
  bool _isSplit = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedTripId = widget.tripId;

    // Set currency based on selected trip after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCurrencyForTrip(_selectedTripId);
    });
  }

  /// Update currency based on the selected trip's destination country
  void _updateCurrencyForTrip(String? tripId) {
    if (tripId == null) {
      // Default to user's home currency if no trip
      final homeCurrency = ref.read(userHomeCurrencyProvider);
      if (homeCurrency.isNotEmpty && mounted) {
        setState(() => _currency = homeCurrency);
      }
      return;
    }

    // Get the trip and set currency based on destination
    final tripsAsync = ref.read(userTripsProvider);
    tripsAsync.whenData((trips) {
      final trip = trips.where((t) => t.id == tripId).firstOrNull;
      if (trip != null && mounted) {
        // Compute currency from destination (more reliable than stored budget_currency)
        // This handles trips created before the currency auto-detection was added
        final computedCurrency = CountryCurrencyHelper.getCurrencyForDestination(trip.destination);
        setState(() => _currency = computedCurrency);
      }
    });
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

    // Ensure trip is selected
    final l10n = AppLocalizations.of(context);
    if (_selectedTripId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectTrip),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      final notes = _notesController.text.trim();

      // Use the expense operation provider to create expense
      final expense = await ref.read(expenseOperationProvider.notifier).createExpense(
        tripId: _selectedTripId!,
        amount: amount,
        currency: _currency,
        category: _category,
        description: description,
        expenseDate: _date,
        isSplit: _isSplit,
        notes: notes.isNotEmpty ? notes : null,
      );

      if (!mounted) return;

      if (expense != null) {
        // Refresh the expenses dashboard
        await ref.read(expensesDashboardRefreshProvider)();

        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.expenseAddedSuccess),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        // Check for error in state
        final error = ref.read(expenseOperationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? l10n.failedToAddExpense),
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
    // Watch for user trips to allow selection
    final tripsAsync = ref.watch(userTripsProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.addExpense),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
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
              // Trip selector (if no tripId provided)
              if (widget.tripId == null) ...[
                tripsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading trips: $e'),
                  data: (trips) {
                    if (trips.isEmpty) {
                      return Card(
                        color: AppTheme.errorColor.withAlpha(26),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            l10n.noTripsFound,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    // Auto-select first trip if none selected and update currency
                    if (_selectedTripId == null && trips.isNotEmpty) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _selectedTripId = trips.first.id);
                          _updateCurrencyForTrip(trips.first.id);
                        }
                      });
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedTripId,
                      decoration: InputDecoration(
                        labelText: '${l10n.trip} *',
                        prefixIcon: const Icon(Icons.flight_takeoff),
                      ),
                      items: trips.map((trip) => DropdownMenuItem(
                        value: trip.id,
                        child: Text('${trip.displayTitle} (${trip.displayDestination})'),
                      )).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedTripId = value);
                          // Update currency when trip changes
                          _updateCurrencyForTrip(value);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return l10n.pleaseSelectTrip;
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Amount with dynamic currency symbol
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: Theme.of(context).textTheme.headlineMedium,
                      decoration: InputDecoration(
                        labelText: '${l10n.amount} *',
                        hintText: '0.00',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            CountryCurrencyHelper.getSymbolForCurrency(_currency),
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      isExpanded: true,
                      items: AppConstants.supportedCurrencies
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, overflow: TextOverflow.ellipsis),
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
              const SizedBox(height: 24),

              // Category
              Text(
                '${l10n.category} *',
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

              // Receipt photo
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement image picker for receipt
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.receiptPhotoComingSoon)),
                  );
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(l10n.addReceiptPhoto),
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
                            l10n.splitThisExpense,
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
                          l10n.selectTripMembersToSplit,
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
                            l10n.noTripMembersToSplit,
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
