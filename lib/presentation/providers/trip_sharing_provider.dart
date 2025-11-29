import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/trip_member_model.dart';
import '../../services/trip_sharing_service.dart';

/// Provider for trip sharing service
final tripSharingServiceProvider = Provider<TripSharingService>((ref) {
  return TripSharingService(client: Supabase.instance.client);
});

/// Provider for trip invite code (generates if doesn't exist)
final tripInviteCodeProvider = FutureProvider.family<String?, String>((ref, tripId) async {
  final service = ref.watch(tripSharingServiceProvider);
  return service.getInviteCode(tripId);
});

/// Provider for trip members (including owner)
final tripMembersProvider = FutureProvider.family<List<TripMemberModel>, String>((ref, tripId) async {
  final service = ref.watch(tripSharingServiceProvider);
  return service.getTripMembers(tripId);
});

/// Provider to check if current user is trip owner
final isTripOwnerProvider = FutureProvider.family<bool, String>((ref, tripId) async {
  final service = ref.watch(tripSharingServiceProvider);
  return service.isOwner(tripId);
});

/// Notifier for joining a trip
class JoinTripNotifier extends StateNotifier<AsyncValue<JoinTripResult?>> {
  final TripSharingService _service;

  JoinTripNotifier(this._service) : super(const AsyncValue.data(null));

  Future<JoinTripResult> joinTrip(String inviteCode) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.joinTripByCode(inviteCode);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return JoinTripResult(success: false, error: e.toString());
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final joinTripNotifierProvider = StateNotifierProvider<JoinTripNotifier, AsyncValue<JoinTripResult?>>((ref) {
  final service = ref.watch(tripSharingServiceProvider);
  return JoinTripNotifier(service);
});

/// Notifier for leaving a trip
class LeaveTripNotifier extends StateNotifier<AsyncValue<TripMemberActionResult?>> {
  final TripSharingService _service;

  LeaveTripNotifier(this._service) : super(const AsyncValue.data(null));

  Future<TripMemberActionResult> leaveTrip(String tripId) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.leaveTrip(tripId);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return TripMemberActionResult(success: false, error: e.toString());
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final leaveTripNotifierProvider = StateNotifierProvider<LeaveTripNotifier, AsyncValue<TripMemberActionResult?>>((ref) {
  final service = ref.watch(tripSharingServiceProvider);
  return LeaveTripNotifier(service);
});

/// Notifier for removing a member
class RemoveMemberNotifier extends StateNotifier<AsyncValue<TripMemberActionResult?>> {
  final TripSharingService _service;

  RemoveMemberNotifier(this._service) : super(const AsyncValue.data(null));

  Future<TripMemberActionResult> removeMember(String tripId, String memberUserId) async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.removeMember(tripId, memberUserId);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return TripMemberActionResult(success: false, error: e.toString());
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final removeMemberNotifierProvider = StateNotifierProvider<RemoveMemberNotifier, AsyncValue<TripMemberActionResult?>>((ref) {
  final service = ref.watch(tripSharingServiceProvider);
  return RemoveMemberNotifier(service);
});
