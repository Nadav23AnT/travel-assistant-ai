import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../config/routes.dart';
import '../../../config/theme.dart';
import '../../providers/onboarding_provider.dart';
import '../../providers/trips_provider.dart';

class TravelDatesScreen extends ConsumerStatefulWidget {
  const TravelDatesScreen({super.key});

  @override
  ConsumerState<TravelDatesScreen> createState() => _TravelDatesScreenState();
}

class _TravelDatesScreenState extends ConsumerState<TravelDatesScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    // Initialize from provider state
    final onboardingData = ref.read(onboardingProvider);
    _rangeStart = onboardingData.startDate;
    _rangeEnd = onboardingData.endDate;
  }

  Future<void> _handleFinish() async {
    // Save dates to provider if selected
    if (_rangeStart != null && _rangeEnd != null) {
      ref.read(onboardingProvider.notifier).setTravelDates(
            startDate: _rangeStart!,
            endDate: _rangeEnd!,
          );
    }

    setState(() => _isCompleting = true);

    // Complete onboarding
    final success =
        await ref.read(onboardingProvider.notifier).completeOnboarding();

    if (!mounted) return;

    setState(() => _isCompleting = false);

    if (success) {
      // Refresh trips provider so home screen shows the new trip
      ref.read(tripsRefreshProvider)();
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save preferences. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final onboardingData = ref.watch(onboardingProvider);
    final destination = onboardingData.destination;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),

              // Progress indicator
              _buildProgressIndicator(3),
              const SizedBox(height: 32),

              // Header
              Text(
                'When Are You Traveling?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                destination != null
                    ? 'Select your travel dates to $destination'
                    : 'Select your travel dates or skip for now',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Selected dates display
              if (_rangeStart != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppTheme.primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _rangeEnd != null
                            ? '${DateFormat('MMM d').format(_rangeStart!)} - ${DateFormat('MMM d, y').format(_rangeEnd!)}'
                            : DateFormat('MMM d, y').format(_rangeStart!),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      if (_rangeEnd != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_rangeEnd!.difference(_rangeStart!).inDays + 1} days',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () {
                          setState(() {
                            _rangeStart = null;
                            _rangeEnd = null;
                          });
                          ref
                              .read(onboardingProvider.notifier)
                              .clearTravelDates();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Calendar
              Expanded(
                child: SingleChildScrollView(
                  child: TableCalendar(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 365 * 2)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    rangeSelectionMode: RangeSelectionMode.toggledOn,
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        if (_rangeStart == null ||
                            (_rangeStart != null && _rangeEnd != null)) {
                          _rangeStart = selectedDay;
                          _rangeEnd = null;
                        } else if (selectedDay.isBefore(_rangeStart!)) {
                          _rangeStart = selectedDay;
                        } else {
                          _rangeEnd = selectedDay;
                        }
                        _focusedDay = focusedDay;
                      });
                    },
                    onRangeSelected: (start, end, focusedDay) {
                      setState(() {
                        _rangeStart = start;
                        _rangeEnd = end;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() => _calendarFormat = format);
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    calendarStyle: CalendarStyle(
                      rangeHighlightColor: AppTheme.primaryColor.withOpacity(0.2),
                      rangeStartDecoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      rangeEndDecoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      withinRangeTextStyle: const TextStyle(
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (onboardingData.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          onboardingData.error!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Navigation buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isCompleting ? null : () => context.go(AppRoutes.onboardingDestination),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isCompleting ? null : _handleFinish,
                      child: _isCompleting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _rangeStart != null && _rangeEnd != null
                                  ? 'Start Planning!'
                                  : 'Skip & Finish',
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int currentStep) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isActive = index <= currentStep;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentStep ? 32 : 12,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
