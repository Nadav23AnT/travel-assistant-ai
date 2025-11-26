import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/trips_provider.dart';

class CreateTripScreen extends ConsumerStatefulWidget {
  const CreateTripScreen({super.key});

  @override
  ConsumerState<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends ConsumerState<CreateTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _destinationController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _currency = AppConstants.defaultCurrency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Listen to changes to update preview and currency
    _destinationController.addListener(_onInputChanged);
    _titleController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _destinationController.removeListener(_onInputChanged);
    _titleController.removeListener(_onInputChanged);
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Rebuild UI when inputs change (for preview)
  void _onInputChanged() {
    setState(() {});
    // Also update currency based on destination
    _updateCurrencyForDestination();
  }

  /// Update currency based on destination country
  void _updateCurrencyForDestination() {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) return;

    final suggestedCurrency = CountryCurrencyHelper.getCurrencyForDestination(destination);
    // Only use the suggested currency if it's in our supported list
    final finalCurrency = AppConstants.supportedCurrencies.contains(suggestedCurrency)
        ? suggestedCurrency
        : AppConstants.defaultCurrency;
    if (finalCurrency != _currency) {
      setState(() => _currency = finalCurrency);
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _handleCreateTrip() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select trip dates')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final destination = _destinationController.text.trim();
      final title = _titleController.text.trim();
      final budget = double.tryParse(_budgetController.text.trim());
      final description = _descriptionController.text.trim();

      // Create the trip using the provider
      final trip = await ref.read(tripOperationProvider.notifier).createTrip(
        title: title,
        destination: destination,
        startDate: _startDate!,
        endDate: _endDate!,
        budgetAmount: budget,
        budgetCurrency: _currency,
        description: description.isNotEmpty ? description : null,
      );

      if (!mounted) return;

      if (trip != null) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip to ${trip.displayDestination} created!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        final error = ref.read(tripOperationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to create trip'),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: const Text('Create Trip'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleCreateTrip,
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
              // Flag preview based on destination
              Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withAlpha(230),
                      AppTheme.primaryColor.withAlpha(180),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Flag emoji background (updates based on destination)
                    Positioned(
                      right: -20,
                      top: -10,
                      child: Text(
                        _destinationController.text.isNotEmpty
                            ? CountryCurrencyHelper.getFlagForDestination(_destinationController.text)
                            : '🌍',
                        style: const TextStyle(fontSize: 100),
                      ),
                    ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withAlpha(200),
                            AppTheme.primaryColor.withAlpha(50),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                    // Preview text
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _titleController.text.isNotEmpty
                                ? _titleController.text
                                : 'Trip Preview',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                            ),
                          ),
                          if (_destinationController.text.isNotEmpty)
                            Text(
                              CountryCurrencyHelper.extractCountryFromDestination(_destinationController.text),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Trip Title *',
                  hintText: 'e.g., Paris Adventure 2025',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a trip title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Destination with autocomplete
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final query = textEditingValue.text.toLowerCase();
                  // Get all countries from the helper
                  final allCountries = CountryCurrencyHelper.countryToCode.keys.toList();
                  return allCountries.where((country) =>
                      country.toLowerCase().contains(query));
                },
                displayStringForOption: (String option) => option,
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  // Sync with our destination controller
                  controller.addListener(() {
                    if (_destinationController.text != controller.text) {
                      _destinationController.text = controller.text;
                    }
                  });
                  // Initialize with existing value
                  if (controller.text.isEmpty && _destinationController.text.isNotEmpty) {
                    controller.text = _destinationController.text;
                  }
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Destination *',
                      hintText: 'Start typing a country...',
                      prefixIcon: Icon(Icons.location_on_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a destination';
                      }
                      return null;
                    },
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 250, maxWidth: 350),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final option = options.elementAt(index);
                            final flag = CountryCurrencyHelper.getFlagForCountry(option);
                            return ListTile(
                              leading: Text(flag, style: const TextStyle(fontSize: 24)),
                              title: Text(option),
                              dense: true,
                              onTap: () => onSelected(option),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
                onSelected: (String selection) {
                  _destinationController.text = selection;
                  _onInputChanged();
                },
              ),
              const SizedBox(height: 16),

              // Date range
              GestureDetector(
                onTap: _selectDateRange,
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Trip Dates *',
                      hintText: 'Select dates',
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    controller: TextEditingController(
                      text: _startDate != null && _endDate != null
                          ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                          : '',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Budget with dynamic currency symbol
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Budget',
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
                                child: Text('$c ${CountryCurrencyHelper.getSymbolForCurrency(c)}'),
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
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What are you excited about for this trip?',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),

              // AI Planning suggestion
              Card(
                color: AppTheme.primaryLight.withAlpha(77),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan with AI',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'After creating your trip, use our AI assistant to generate personalized itineraries!',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
}
