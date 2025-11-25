import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/auth_service.dart';
import 'auth_provider.dart';

// Onboarding data model
class OnboardingData {
  final List<String> selectedLanguages;
  final String? homeCurrency;
  final String? destination;
  final String? destinationPlaceId;
  final double? destinationLat;
  final double? destinationLng;
  final DateTime? startDate;
  final DateTime? endDate;
  final int currentStep;
  final bool isCompleting;
  final String? error;

  const OnboardingData({
    this.selectedLanguages = const ['en'],
    this.homeCurrency,
    this.destination,
    this.destinationPlaceId,
    this.destinationLat,
    this.destinationLng,
    this.startDate,
    this.endDate,
    this.currentStep = 0,
    this.isCompleting = false,
    this.error,
  });

  OnboardingData copyWith({
    List<String>? selectedLanguages,
    String? homeCurrency,
    String? destination,
    String? destinationPlaceId,
    double? destinationLat,
    double? destinationLng,
    DateTime? startDate,
    DateTime? endDate,
    int? currentStep,
    bool? isCompleting,
    String? error,
    bool clearDestination = false,
    bool clearDates = false,
  }) {
    return OnboardingData(
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      homeCurrency: homeCurrency ?? this.homeCurrency,
      destination: clearDestination ? null : (destination ?? this.destination),
      destinationPlaceId:
          clearDestination ? null : (destinationPlaceId ?? this.destinationPlaceId),
      destinationLat:
          clearDestination ? null : (destinationLat ?? this.destinationLat),
      destinationLng:
          clearDestination ? null : (destinationLng ?? this.destinationLng),
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      currentStep: currentStep ?? this.currentStep,
      isCompleting: isCompleting ?? this.isCompleting,
      error: error,
    );
  }
}

// Onboarding notifier
class OnboardingNotifier extends StateNotifier<OnboardingData> {
  final AuthService _authService;

  OnboardingNotifier(this._authService) : super(const OnboardingData());

  void setLanguages(List<String> languages) {
    if (languages.isEmpty) return;
    state = state.copyWith(selectedLanguages: languages, error: null);
  }

  void toggleLanguage(String languageCode) {
    final currentLanguages = List<String>.from(state.selectedLanguages);
    if (currentLanguages.contains(languageCode)) {
      // Don't allow removing the last language
      if (currentLanguages.length > 1) {
        currentLanguages.remove(languageCode);
      }
    } else {
      currentLanguages.add(languageCode);
    }
    state = state.copyWith(selectedLanguages: currentLanguages, error: null);
  }

  void setHomeCurrency(String currency) {
    state = state.copyWith(homeCurrency: currency, error: null);
  }

  void setDestination({
    required String destination,
    String? placeId,
    double? lat,
    double? lng,
  }) {
    state = state.copyWith(
      destination: destination,
      destinationPlaceId: placeId,
      destinationLat: lat,
      destinationLng: lng,
      error: null,
    );
  }

  void clearDestination() {
    state = state.copyWith(clearDestination: true, error: null);
  }

  void setTravelDates({required DateTime startDate, required DateTime endDate}) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      error: null,
    );
  }

  void clearTravelDates() {
    state = state.copyWith(clearDates: true, error: null);
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1, error: null);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, error: null);
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step, error: null);
    }
  }

  Future<bool> completeOnboarding() async {
    state = state.copyWith(isCompleting: true, error: null);

    try {
      await _authService.completeOnboarding(
        languages: state.selectedLanguages,
        homeCurrency: state.homeCurrency,
        destination: state.destination,
        destinationPlaceId: state.destinationPlaceId,
        destinationLat: state.destinationLat,
        destinationLng: state.destinationLng,
        startDate: state.startDate,
        endDate: state.endDate,
      );

      state = state.copyWith(isCompleting: false);
      return true;
    } catch (e) {
      debugPrint('Error completing onboarding: $e');
      state = state.copyWith(
        isCompleting: false,
        error: 'Failed to save preferences. Please try again.',
      );
      return false;
    }
  }

  void reset() {
    state = const OnboardingData();
  }
}

// Provider
final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>((ref) {
  final authService = ref.watch(authServiceProvider);
  return OnboardingNotifier(authService);
});
