import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/trip_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/budget_estimation_service.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/trips_provider.dart';
import '../../widgets/trip/smart_budget_suggestions_card.dart';

class EditTripScreen extends ConsumerStatefulWidget {
  final TripModel trip;

  const EditTripScreen({super.key, required this.trip});

  @override
  ConsumerState<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends ConsumerState<EditTripScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _destinationController;
  late final TextEditingController _budgetController;
  late final TextEditingController _descriptionController;

  late DateTime? _startDate;
  late DateTime? _endDate;
  late String _currency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing trip data
    _titleController = TextEditingController(text: widget.trip.title);
    _destinationController = TextEditingController(text: widget.trip.destination);
    _budgetController = TextEditingController(
      text: widget.trip.budget?.toStringAsFixed(0) ?? '',
    );
    _descriptionController = TextEditingController(text: widget.trip.description ?? '');

    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    _currency = widget.trip.budgetCurrency;

    // Listen to changes to update preview
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

  void _onInputChanged() {
    setState(() {});
  }

  int get _tripDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  void _applySmartBudget() {
    final estimate = BudgetEstimationService.getEstimate(
      destination: _destinationController.text.trim(),
      tripDays: _tripDays,
      currency: _currency,
    );
    if (estimate != null) {
      setState(() {
        _budgetController.text = estimate.totalBudget.toStringAsFixed(0);
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
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

  Future<void> _handleUpdateTrip() async {
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

      // Build the updates map
      final updates = <String, dynamic>{
        'title': title,
        'destination': destination,
        'start_date': _startDate!.toIso8601String().split('T').first,
        'end_date': _endDate!.toIso8601String().split('T').first,
        'budget_currency': _currency,
        'description': description.isNotEmpty ? description : null,
      };

      // Only include budget if provided
      if (budget != null) {
        updates['budget'] = budget;
      }

      // Update the trip using the provider
      final updatedTrip = await ref.read(tripOperationProvider.notifier).updateTrip(
        widget.trip.id,
        updates,
      );

      if (!mounted) return;

      if (updatedTrip != null) {
        context.pop(true); // Return true to indicate successful update
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip "${updatedTrip.displayTitle}" updated!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        final error = ref.read(tripOperationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update trip'),
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
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.editTrip),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleUpdateTrip,
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
                    // Flag emoji background
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
                                : l10n.tripPreview,
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
                decoration: InputDecoration(
                  labelText: '${l10n.tripTitle} *',
                  hintText: l10n.tripTitleHint,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.tripTitleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Destination with autocomplete
              Autocomplete<String>(
                initialValue: TextEditingValue(text: widget.trip.destination),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  final query = textEditingValue.text.toLowerCase();
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
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: '${l10n.destination} *',
                      hintText: l10n.destinationHint,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.destinationRequired;
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
                      labelText: '${l10n.tripDates} *',
                      hintText: l10n.selectDates,
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
                        labelText: l10n.budget,
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
                      decoration: InputDecoration(
                        labelText: l10n.currency,
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
                decoration: InputDecoration(
                  labelText: l10n.description,
                  hintText: l10n.descriptionHint,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),

              // Smart Budget Suggestions Card
              SmartBudgetSuggestionsCard(
                destination: _destinationController.text.trim(),
                tripDays: _tripDays,
                currency: _currency,
                onApplyBudget: _applySmartBudget,
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
