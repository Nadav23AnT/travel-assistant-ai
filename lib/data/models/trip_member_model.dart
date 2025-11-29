import 'package:equatable/equatable.dart';

/// Represents a member of a shared trip
class TripMemberModel extends Equatable {
  final String? id; // null for owner (owner isn't in trip_members table)
  final String tripId;
  final String userId;
  final String role; // 'owner', 'editor', 'viewer'
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime? joinedAt;
  final String? fullName;
  final String? avatarUrl;
  final String? email;
  final bool isOwner;

  const TripMemberModel({
    this.id,
    required this.tripId,
    required this.userId,
    required this.role,
    required this.status,
    this.joinedAt,
    this.fullName,
    this.avatarUrl,
    this.email,
    this.isOwner = false,
  });

  /// Display name - uses full_name or email or "Unknown"
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    if (email != null && email!.isNotEmpty) {
      return email!.split('@').first;
    }
    return 'Unknown';
  }

  /// Get initials for avatar fallback
  String get initials {
    final name = displayName;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  /// Check if this member has edit permissions
  bool get canEdit => role == 'owner' || role == 'editor';

  factory TripMemberModel.fromJson(Map<String, dynamic> json, {String? tripId}) {
    return TripMemberModel(
      id: json['id'] as String?,
      tripId: tripId ?? json['trip_id'] as String? ?? '',
      userId: json['user_id'] as String,
      role: json['role'] as String? ?? 'viewer',
      status: json['status'] as String? ?? 'accepted',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
      isOwner: json['is_owner'] as bool? ?? (json['role'] == 'owner'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'user_id': userId,
      'role': role,
      'status': status,
      'joined_at': joinedAt?.toIso8601String(),
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email': email,
      'is_owner': isOwner,
    };
  }

  @override
  List<Object?> get props => [id, tripId, userId, role, status, isOwner];
}
