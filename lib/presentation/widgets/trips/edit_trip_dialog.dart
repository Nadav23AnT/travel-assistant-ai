import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../data/models/trip_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/trips_provider.dart';

class EditTripDialog extends ConsumerStatefulWidget {
  final TripModel trip;

  const EditTripDialog({
    super.key,
    required this.trip,
  });

  @override
  ConsumerState<EditTripDialog> createState() => _EditTripDialogState();
}

class _EditTripDialogState extends ConsumerState<EditTripDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _destinationController;
  late TextEditingController _budgetController;
  late TextEditingController _descriptionController;

  late DateTime? _startDate;
  late DateTime? _endDate;
  late String _currency;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with existing trip data
    _titleController = TextEditingController(text: widget.trip.title);
    _destinationController = TextEditingController(text: widget.trip.destination);
    _budgetController = TextEditingController(
      text: widget.trip.budget?.toStringAsFixed(0) ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.trip.description ?? '',
    );
    _startDate = widget.trip.startDate;
    _endDate = widget.trip.endDate;
    _currency = widget.trip.budgetCurrency;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _destinationController.dispose();
    _budgetController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).pleaseSelectDates),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final title = _titleController.text.trim();
      final destination = _destinationController.text.trim();
      final budget = double.tryParse(_budgetController.text.trim());
      final description = _descriptionController.text.trim();

      // Build updates map
      final updates = <String, dynamic>{
        'title': title,
        'destination': destination,
        'start_date': _startDate!.toIso8601String().split('T')[0],
        'end_date': _endDate!.toIso8601String().split('T')[0],
        'budget': budget,
        'budget_currency': _currency,
        'description': description.isNotEmpty ? description : null,
      };

      // Update trip via provider
      final updatedTrip = await ref.read(tripOperationProvider.notifier).updateTrip(
        widget.trip.id,
        updates,
      );
      final success = updatedTrip != null;

      if (!mounted) return;

      if (success) {
        // Refresh the trip detail
        ref.invalidate(tripByIdProvider(widget.trip.id));

        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).tripUpdatedSuccess),
            backgroundColor: AppTheme.successColor,
          ),
        );
      } else {
        if (!mounted) return;
        final error = ref.read(tripOperationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? AppLocalizations.of(context).failedToUpdateTrip),
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
                      l10n.editTrip,
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
                      // Flag preview based on destination
                      Container(
                        height: 80,
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
                            Positioned(
                              right: -10,
                              top: -5,
                              child: Text(
                                _destinationController.text.isNotEmpty
                                    ? CountryCurrencyHelper.getFlagForDestination(
                                        _destinationController.text)
                                    : widget.trip.flagEmoji,
                                style: const TextStyle(fontSize: 60),
                              ),
                            ),
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
                            Positioned(
                              left: 12,
                              bottom: 8,
                              child: Text(
                                _titleController.text.isNotEmpty
                                    ? _titleController.text
                                    : widget.trip.displayTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: '${l10n.tripTitle} *',
                          hintText: l10n.tripTitleHint,
                          prefixIcon: const Icon(Icons.title),
                        ),
                        onChanged: (_) => setState(() {}),
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
                          controller.addListener(() {
                            if (_destinationController.text != controller.text) {
                              _destinationController.text = controller.text;
                              _updateCurrencyForDestination();
                              setState(() {});
                            }
                          });
                          if (controller.text.isEmpty && _destinationController.text.isNotEmpty) {
                            controller.text = _destinationController.text;
                          }
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
                                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
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
                          _updateCurrencyForDestination();
                          setState(() {});
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

                      // Budget with currency
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
                          SizedBox(
                            width: 100,
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
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.notes,
                          hintText: l10n.descriptionHint,
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

  void _updateCurrencyForDestination() {
    final destination = _destinationController.text.trim();
    if (destination.isEmpty) return;

    final suggestedCurrency = CountryCurrencyHelper.getCurrencyForDestination(destination);
    final finalCurrency = AppConstants.supportedCurrencies.contains(suggestedCurrency)
        ? suggestedCurrency
        : AppConstants.defaultCurrency;
    if (finalCurrency != _currency) {
      setState(() => _currency = finalCurrency);
    }
  }
}

/// Shows the edit trip dialog and returns true if the trip was updated
Future<bool?> showEditTripDialog(
  BuildContext context,
  TripModel trip,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => EditTripDialog(trip: trip),
  );
}
