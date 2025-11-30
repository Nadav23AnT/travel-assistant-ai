import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_models.dart';
import '../../data/repositories/admin_repository.dart';
import 'auth_provider.dart';

// ============================================
// Repository Provider
// ============================================

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

// ============================================
// Admin Status Providers
// ============================================

/// Check if current user is an admin
/// Auto-refreshes when auth state changes
final isAdminProvider = FutureProvider<bool>((ref) async {
  try {
    // Watch auth state to auto-refresh when it changes
    ref.watch(authStateProvider);
    final authService = ref.read(authServiceProvider);
    return await authService.isAdmin();
  } catch (e) {
    // Return false if there's any error checking admin status
    return false;
  }
});

// ============================================
// System Stats Provider
// ============================================

/// System-wide statistics for admin dashboard
final systemStatsProvider = FutureProvider<SystemStatsModel>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getSystemStats();
});

/// Refreshable system stats
final systemStatsNotifierProvider =
    AsyncNotifierProvider<SystemStatsNotifier, SystemStatsModel>(
      SystemStatsNotifier.new);

class SystemStatsNotifier extends AsyncNotifier<SystemStatsModel> {
  @override
  Future<SystemStatsModel> build() async {
    final repository = ref.read(adminRepositoryProvider);
    return await repository.getSystemStats();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(adminRepositoryProvider);
      return await repository.getSystemStats();
    });
  }
}

// ============================================
// User Management Providers
// ============================================

/// User list filters
class UserFilters {
  final String? searchQuery;
  final String? planFilter;
  final String? sortBy;
  final bool ascending;
  final int page;

  const UserFilters({
    this.searchQuery,
    this.planFilter,
    this.sortBy,
    this.ascending = false,
    this.page = 0,
  });

  UserFilters copyWith({
    String? searchQuery,
    String? planFilter,
    String? sortBy,
    bool? ascending,
    int? page,
  }) {
    return UserFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      planFilter: planFilter ?? this.planFilter,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
      page: page ?? this.page,
    );
  }
}

/// Current user list filters state
final userFiltersProvider = StateProvider<UserFilters>((ref) {
  return const UserFilters();
});

/// Paginated user list with filters
final adminUsersProvider = FutureProvider<List<AdminUserModel>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final filters = ref.watch(userFiltersProvider);

  return await repository.getAllUsers(
    page: filters.page,
    searchQuery: filters.searchQuery,
    planFilter: filters.planFilter,
    sortBy: filters.sortBy,
    ascending: filters.ascending,
  );
});

/// Single user detail provider (family for different user IDs)
final adminUserDetailProvider =
    FutureProvider.family<AdminUserModel?, String>((ref, userId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getUserById(userId);
});

/// User counts by plan type
final userCountByPlanProvider = FutureProvider<Map<String, int>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getUserCountByPlan();
});

// ============================================
// Admin Operations Notifier
// ============================================

/// State for admin operations
class AdminOperationsState {
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const AdminOperationsState({
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  AdminOperationsState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return AdminOperationsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class AdminOperationsNotifier extends StateNotifier<AdminOperationsState> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminOperationsNotifier(this._repository, this._ref)
      : super(const AdminOperationsState());

  /// Update user plan type
  Future<bool> updateUserPlan(String userId, String planType) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.updateUserPlan(userId, planType);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User plan updated to $planType',
      );
      // Invalidate user detail to refresh
      _ref.invalidate(adminUserDetailProvider(userId));
      _ref.invalidate(adminUsersProvider);
      _ref.invalidate(userCountByPlanProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Reset user's daily token usage
  Future<bool> resetUserTokens(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.resetUserTokens(userId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User tokens reset successfully',
      );
      _ref.invalidate(adminUserDetailProvider(userId));
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Delete specific user data
  Future<bool> deleteUserData(String userId, UserDataType dataType) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.deleteUserData(userId, dataType);
      state = state.copyWith(
        isLoading: false,
        successMessage: '${dataType.displayName} deleted successfully',
      );
      _ref.invalidate(adminUserDetailProvider(userId));
      _ref.invalidate(systemStatsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Set/remove admin status
  Future<bool> setAdminStatus(String userId, bool isAdmin) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.setUserAdminStatus(userId, isAdmin);
      state = state.copyWith(
        isLoading: false,
        successMessage: isAdmin ? 'Admin access granted' : 'Admin access revoked',
      );
      _ref.invalidate(adminUserDetailProvider(userId));
      _ref.invalidate(adminUsersProvider);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Clear any messages
  void clearMessages() {
    state = const AdminOperationsState();
  }
}

final adminOperationsProvider =
    StateNotifierProvider<AdminOperationsNotifier, AdminOperationsState>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminOperationsNotifier(repository, ref);
});
