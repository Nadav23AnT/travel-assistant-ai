import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/constants.dart';
import '../../../core/design/design_system.dart';
import '../../../data/models/trip_member_model.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/country_currency_helper.dart';
import '../../providers/currency_provider.dart';
import '../../providers/expenses_provider.dart';
import '../../providers/trip_sharing_provider.dart';
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
  Set<String> _selectedMemberIds = {};

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
        final computedCurrency =
            CountryCurrencyHelper.getCurrencyForDestination(trip.destination);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: LiquidGlassColors.auroraIndigo,
              brightness: isDark ? Brightness.dark : Brightness.light,
            ),
          ),
          child: child!,
        );
      },
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
      _showGlassSnackBar(l10n.pleaseSelectTrip, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim();
      final notes = _notesController.text.trim();

      // Use splits provider if splitting with members, otherwise regular expense
      if (_isSplit && _selectedMemberIds.isNotEmpty) {
        // Create expense with splits
        final expense = await ref
            .read(splitOperationProvider.notifier)
            .createExpenseWithSplits(
              tripId: _selectedTripId!,
              amount: amount,
              currency: _currency,
              category: _category,
              description: description,
              splitWithUserIds: _selectedMemberIds.toList(),
              expenseDate: _date,
              notes: notes.isNotEmpty ? notes : null,
              equalSplit: true,
            );

        if (!mounted) return;

        if (expense != null) {
          await ref.read(expensesDashboardRefreshProvider)();
          context.pop();
          _showGlassSnackBar(l10n.expenseAddedSuccess, isError: false);
        } else {
          final error = ref.read(splitOperationProvider).error;
          _showGlassSnackBar(error ?? l10n.failedToAddExpense, isError: true);
        }
      } else {
        // Regular expense without splits
        final expense =
            await ref.read(expenseOperationProvider.notifier).createExpense(
                  tripId: _selectedTripId!,
                  amount: amount,
                  currency: _currency,
                  category: _category,
                  description: description,
                  expenseDate: _date,
                  isSplit: false,
                  notes: notes.isNotEmpty ? notes : null,
                );

        if (!mounted) return;

        if (expense != null) {
          await ref.read(expensesDashboardRefreshProvider)();
          context.pop();
          _showGlassSnackBar(l10n.expenseAddedSuccess, isError: false);
        } else {
          final error = ref.read(expenseOperationProvider).error;
          _showGlassSnackBar(error ?? l10n.failedToAddExpense, isError: true);
        }
      }
    } catch (e) {
      if (!mounted) return;
      _showGlassSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showGlassSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? LiquidGlassColors.sunsetRose.withAlpha(200)
            : LiquidGlassColors.mintEmerald.withAlpha(200),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(userTripsProvider);
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  LiquidGlassColors.canvasBaseDark,
                  const Color(0xFF0D1321),
                  LiquidGlassColors.canvasSubtleDark,
                ]
              : [
                  LiquidGlassColors.canvasBaseLight,
                  const Color(0xFFF0F4FF),
                  const Color(0xFFFAF5FF),
                ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: GlowingIconButton(
            icon: Icons.close,
            onPressed: () => context.pop(),
            size: 40,
          ),
          title: Text(
            l10n.addExpense,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _isLoading
                  ? Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            LiquidGlassColors.auroraIndigo,
                          ),
                        ),
                      ),
                    )
                  : GlowingIconButton(
                      icon: Icons.check,
                      onPressed: _handleSave,
                      size: 40,
                    ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Amount input card
                _GlassAmountCard(
                  amountController: _amountController,
                  currency: _currency,
                  onCurrencyChanged: (value) {
                    setState(() => _currency = value);
                  },
                  isDark: isDark,
                  l10n: l10n,
                ),
                const SizedBox(height: 16),

                // Trip selector (if no tripId provided)
                if (widget.tripId == null) ...[
                  tripsAsync.when(
                    loading: () => _GlassLoadingCard(isDark: isDark),
                    error: (e, _) => _GlassErrorCard(
                      error: e.toString(),
                      isDark: isDark,
                    ),
                    data: (trips) {
                      if (trips.isEmpty) {
                        return _GlassErrorCard(
                          error: l10n.noTripsFound,
                          isDark: isDark,
                        );
                      }

                      // Auto-select first trip if none selected
                      if (_selectedTripId == null && trips.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() => _selectedTripId = trips.first.id);
                            _updateCurrencyForTrip(trips.first.id);
                          }
                        });
                      }

                      return _GlassTripSelector(
                        trips: trips,
                        selectedTripId: _selectedTripId,
                        onChanged: (value) {
                          setState(() => _selectedTripId = value);
                          _updateCurrencyForTrip(value);
                        },
                        isDark: isDark,
                        l10n: l10n,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Description input
                _GlassInputCard(
                  controller: _descriptionController,
                  label: '${l10n.description} *',
                  hint: l10n.descriptionHintExpense,
                  icon: Icons.description_outlined,
                  isDark: isDark,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterDescription;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Category selector
                _buildSectionTitle(l10n.category, isDark),
                const SizedBox(height: 12),
                _GlassCategorySelector(
                  selectedCategory: _category,
                  onChanged: (category) {
                    setState(() => _category = category);
                  },
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Date picker
                _buildSectionTitle(l10n.date, isDark),
                const SizedBox(height: 12),
                _GlassDatePicker(
                  date: _date,
                  onTap: _selectDate,
                  isDark: isDark,
                ),
                const SizedBox(height: 24),

                // Receipt photo button
                _GlassReceiptButton(
                  onTap: () {
                    _showGlassSnackBar(l10n.receiptPhotoComingSoon,
                        isError: false);
                  },
                  isDark: isDark,
                  l10n: l10n,
                ),
                const SizedBox(height: 24),

                // Split expense toggle with member selection
                if (_selectedTripId != null)
                  Consumer(
                    builder: (context, ref, child) {
                      final membersAsync =
                          ref.watch(tripMembersProvider(_selectedTripId!));
                      final currentUserId =
                          Supabase.instance.client.auth.currentUser?.id;

                      return membersAsync.when(
                        data: (members) {
                          // Filter out current user from split options
                          final otherMembers = members
                              .where((m) => m.userId != currentUserId)
                              .toList();

                          return _GlassSplitCard(
                            isSplit: _isSplit,
                            onChanged: (value) {
                              setState(() {
                                _isSplit = value;
                                if (!value) {
                                  _selectedMemberIds.clear();
                                }
                              });
                            },
                            isDark: isDark,
                            l10n: l10n,
                            tripMembers: otherMembers,
                            selectedMemberIds: _selectedMemberIds,
                            onMemberToggled: (memberId) {
                              setState(() {
                                if (_selectedMemberIds.contains(memberId)) {
                                  _selectedMemberIds.remove(memberId);
                                } else {
                                  _selectedMemberIds.add(memberId);
                                }
                              });
                            },
                            onSelectAll: () {
                              setState(() {
                                _selectedMemberIds = otherMembers
                                    .map((m) => m.userId)
                                    .toSet();
                              });
                            },
                          );
                        },
                        loading: () => _GlassSplitCard(
                          isSplit: _isSplit,
                          onChanged: (value) {
                            setState(() => _isSplit = value);
                          },
                          isDark: isDark,
                          l10n: l10n,
                          tripMembers: const [],
                          selectedMemberIds: _selectedMemberIds,
                          onMemberToggled: (_) {},
                          onSelectAll: () {},
                        ),
                        error: (_, __) => _GlassSplitCard(
                          isSplit: _isSplit,
                          onChanged: (value) {
                            setState(() => _isSplit = value);
                          },
                          isDark: isDark,
                          l10n: l10n,
                          tripMembers: const [],
                          selectedMemberIds: _selectedMemberIds,
                          onMemberToggled: (_) {},
                          onSelectAll: () {},
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 16),

                // Notes input
                _GlassInputCard(
                  controller: _notesController,
                  label: l10n.notesOptional,
                  hint: l10n.additionalDetails,
                  icon: Icons.note_outlined,
                  isDark: isDark,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),

                // Save button
                PremiumButton.gradient(
                  label: l10n.save,
                  icon: Icons.check,
                  onPressed: _isLoading ? null : _handleSave,
                  width: double.infinity,
                  height: 56,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}

// ============================================
// GLASS COMPONENTS
// ============================================

class _GlassAmountCard extends StatelessWidget {
  final TextEditingController amountController;
  final String currency;
  final ValueChanged<String> onCurrencyChanged;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassAmountCard({
    required this.amountController,
    required this.currency,
    required this.onCurrencyChanged,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withAlpha(15),
                      Colors.white.withAlpha(8),
                    ]
                  : [
                      Colors.white.withAlpha(200),
                      Colors.white.withAlpha(150),
                    ],
            ),
            border: Border.all(
              width: 1.5,
              color:
                  isDark ? Colors.white.withAlpha(20) : Colors.white.withAlpha(100),
            ),
            boxShadow: LiquidGlassColors.glassShadow(isDark, elevated: true),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.amount,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Currency symbol
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LiquidGlassColors.auroraGradient,
                    ),
                    child: Text(
                      CountryCurrencyHelper.getSymbolForCurrency(currency),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Amount input
                  Expanded(
                    child: TextFormField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
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
                  // Currency selector
                  _GlassCurrencyDropdown(
                    currency: currency,
                    onChanged: onCurrencyChanged,
                    isDark: isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCurrencyDropdown extends StatelessWidget {
  final String currency;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _GlassCurrencyDropdown({
    required this.currency,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(8),
        border: Border.all(
          color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(15),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currency,
          isDense: true,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          icon: Icon(
            Icons.arrow_drop_down,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
          items: AppConstants.supportedCurrencies
              .map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _GlassTripSelector extends StatelessWidget {
  final List<dynamic> trips;
  final String? selectedTripId;
  final ValueChanged<String?> onChanged;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassTripSelector({
    required this.trips,
    required this.selectedTripId,
    required this.onChanged,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(180),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.white.withAlpha(100),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LiquidGlassColors.oceanGradient,
                ),
                child: const Icon(
                  Icons.flight_takeoff,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedTripId,
                    isExpanded: true,
                    hint: Text(
                      l10n.trip,
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    dropdownColor:
                        isDark ? const Color(0xFF1E293B) : Colors.white,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    items: trips.map((trip) {
                      return DropdownMenuItem(
                        value: trip.id as String,
                        child: Text(
                          '${trip.displayTitle} (${trip.displayDestination})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final int maxLines;
  final String? Function(String?)? validator;

  const _GlassInputCard({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(180),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.white.withAlpha(100),
            ),
          ),
          child: Row(
            crossAxisAlignment:
                maxLines > 1 ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isDark
                      ? Colors.white.withAlpha(15)
                      : LiquidGlassColors.auroraIndigo.withAlpha(20),
                ),
                child: Icon(
                  icon,
                  color: LiquidGlassColors.auroraIndigo,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  maxLines: maxLines,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hint,
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: validator,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassCategorySelector extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _GlassCategorySelector({
    required this.selectedCategory,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AppConstants.expenseCategories.map((category) {
        final isSelected = selectedCategory == category;
        final color = _getCategoryColor(category);

        return GestureDetector(
          onTap: () => onChanged(category),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: isSelected ? 15 : 10,
                sigmaY: isSelected ? 15 : 10,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [color, color.withAlpha(180)],
                        )
                      : null,
                  color: isSelected
                      ? null
                      : (isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.white.withAlpha(180)),
                  border: Border.all(
                    width: isSelected ? 2 : 1,
                    color: isSelected
                        ? color
                        : (isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.black.withAlpha(15)),
                  ),
                  boxShadow: isSelected
                      ? LiquidGlassColors.neonGlow(color, intensity: 0.3)
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(category),
                      size: 20,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : color),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _capitalizeFirst(category),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'transport':
        return LiquidGlassColors.oceanSky;
      case 'accommodation':
        return LiquidGlassColors.auroraViolet;
      case 'food':
        return LiquidGlassColors.sunsetOrange;
      case 'activities':
        return LiquidGlassColors.oceanTeal;
      case 'shopping':
        return LiquidGlassColors.sunsetPink;
      default:
        return LiquidGlassColors.categoryOther;
    }
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

  String _capitalizeFirst(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _GlassDatePicker extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  final bool isDark;

  const _GlassDatePicker({
    required this.date,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.white.withAlpha(180),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.white.withAlpha(100),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LiquidGlassColors.sunsetGradient,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _GlassReceiptButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  final AppLocalizations l10n;

  const _GlassReceiptButton({
    required this.onTap,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.white.withAlpha(180),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : Colors.white.withAlpha(100),
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.addReceiptPhoto,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassSplitCard extends StatelessWidget {
  final bool isSplit;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  final AppLocalizations l10n;
  final List<TripMemberModel> tripMembers;
  final Set<String> selectedMemberIds;
  final ValueChanged<String> onMemberToggled;
  final VoidCallback onSelectAll;

  const _GlassSplitCard({
    required this.isSplit,
    required this.onChanged,
    required this.isDark,
    required this.l10n,
    required this.tripMembers,
    required this.selectedMemberIds,
    required this.onMemberToggled,
    required this.onSelectAll,
  });

  @override
  Widget build(BuildContext context) {
    final hasMembers = tripMembers.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(180),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.white.withAlpha(100),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: isSplit && hasMembers
                              ? LiquidGlassColors.mintGradient
                              : null,
                          color: isSplit && hasMembers
                              ? null
                              : (isDark
                                  ? Colors.white.withAlpha(15)
                                  : Colors.black.withAlpha(10)),
                        ),
                        child: Icon(
                          Icons.people_outline,
                          color: isSplit && hasMembers
                              ? Colors.white
                              : (isDark ? Colors.white60 : Colors.black54),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.splitThisExpense,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: isSplit,
                    onChanged: hasMembers ? onChanged : null,
                    activeTrackColor: LiquidGlassColors.mintEmerald,
                    thumbColor: WidgetStateProperty.all(Colors.white),
                  ),
                ],
              ),
              if (!hasMembers) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark
                        ? Colors.white.withAlpha(8)
                        : Colors.black.withAlpha(5),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.noTripMembersToSplit,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (isSplit && hasMembers) ...[
                const SizedBox(height: 16),
                // Select all button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.selectTripMembersToSplit,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    TextButton(
                      onPressed: selectedMemberIds.length == tripMembers.length
                          ? null
                          : onSelectAll,
                      style: TextButton.styleFrom(
                        foregroundColor: LiquidGlassColors.mintEmerald,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(
                        'Select All',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Member selection chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tripMembers.map((member) {
                    final isSelected = selectedMemberIds.contains(member.userId);
                    return GestureDetector(
                      onTap: () => onMemberToggled(member.userId),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: isSelected
                              ? LiquidGlassColors.mintGradient
                              : null,
                          color: isSelected
                              ? null
                              : (isDark
                                  ? Colors.white.withAlpha(12)
                                  : Colors.black.withAlpha(8)),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                    ? Colors.white.withAlpha(20)
                                    : Colors.black.withAlpha(15)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (member.avatarUrl != null &&
                                member.avatarUrl!.isNotEmpty)
                              CircleAvatar(
                                radius: 12,
                                backgroundImage:
                                    NetworkImage(member.avatarUrl!),
                              )
                            else
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: isSelected
                                    ? Colors.white.withAlpha(50)
                                    : (isDark
                                        ? Colors.white.withAlpha(20)
                                        : Colors.black.withAlpha(15)),
                                child: Text(
                                  member.initials,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isDark
                                            ? Colors.white70
                                            : Colors.black54),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              member.displayName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (selectedMemberIds.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          LiquidGlassColors.mintEmerald.withAlpha(30),
                          LiquidGlassColors.auroraIndigo.withAlpha(20),
                        ],
                      ),
                      border: Border.all(
                        color: LiquidGlassColors.mintEmerald.withAlpha(50),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calculate_outlined,
                          size: 18,
                          color: LiquidGlassColors.mintEmerald,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Split equally between you and ${selectedMemberIds.length} ${selectedMemberIds.length == 1 ? 'person' : 'people'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassLoadingCard extends StatelessWidget {
  final bool isDark;

  const _GlassLoadingCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? Colors.white.withAlpha(10)
                : Colors.white.withAlpha(180),
          ),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                LiquidGlassColors.auroraIndigo,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassErrorCard extends StatelessWidget {
  final String error;
  final bool isDark;

  const _GlassErrorCard({
    required this.error,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: LiquidGlassColors.sunsetRose.withAlpha(isDark ? 30 : 20),
            border: Border.all(
              color: LiquidGlassColors.sunsetRose.withAlpha(50),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: LiquidGlassColors.sunsetRose,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
