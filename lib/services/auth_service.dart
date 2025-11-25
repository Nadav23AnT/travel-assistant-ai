import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService {
  final SupabaseClient _supabase;

  AuthService({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  // ============================================
  // GETTERS
  // ============================================

  User? get currentUser => _supabase.auth.currentUser;

  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Session? get currentSession => _supabase.auth.currentSession;

  // ============================================
  // EMAIL/PASSWORD AUTHENTICATION
  // ============================================

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user == null) {
        throw AuthException('Failed to create account');
      }

      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Invalid credentials');
      }

      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ============================================
  // GOOGLE SIGN IN
  // ============================================

  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Web client ID for Google Sign In
      // You'll need to configure this in Google Cloud Console
      const webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';
      const iosClientId = 'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com';

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw AuthException('No access token found');
      }
      if (idToken == null) {
        throw AuthException('No ID token found');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        throw AuthException('Failed to sign in with Google');
      }

      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ============================================
  // APPLE SIGN IN
  // ============================================

  Future<AuthResponse> signInWithApple() async {
    try {
      // Generate nonce for security
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw AuthException('No ID token found from Apple');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      if (response.user == null) {
        throw AuthException('Failed to sign in with Apple');
      }

      // Update user name if provided by Apple (only on first sign in)
      if (credential.givenName != null || credential.familyName != null) {
        final fullName = [credential.givenName, credential.familyName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ');

        if (fullName.isNotEmpty) {
          await _supabase.auth.updateUser(
            UserAttributes(data: {'full_name': fullName}),
          );
        }
      }

      return response;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ============================================
  // ONBOARDING STATUS
  // ============================================

  Future<bool> needsOnboarding() async {
    if (!isAuthenticated) return false;

    try {
      final response = await _supabase
          .from('user_settings')
          .select('onboarding_completed')
          .eq('user_id', currentUser!.id)
          .maybeSingle();

      if (response == null) {
        // No settings yet, needs onboarding
        return true;
      }

      return response['onboarding_completed'] != true;
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
      return true;
    }
  }

  Future<void> completeOnboarding({
    required List<String> languages,
    String? homeCurrency,
    String? destination,
    String? destinationPlaceId,
    double? destinationLat,
    double? destinationLng,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (!isAuthenticated) {
      throw AuthException('Not authenticated');
    }

    try {
      // Update user settings (upsert on user_id since record may already exist from signup trigger)
      await _supabase.from('user_settings').upsert(
        {
          'user_id': currentUser!.id,
          'preferred_languages': languages,
          'onboarding_completed': true,
          'onboarding_completed_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id',
      );

      // Update profile with home currency
      if (homeCurrency != null) {
        await _supabase.from('profiles').update({
          'default_currency': homeCurrency,
        }).eq('id', currentUser!.id);
      }

      // Save onboarding trip if destination provided
      if (destination != null) {
        // Save to onboarding_trips (preference data)
        await _supabase.from('onboarding_trips').upsert(
          {
            'user_id': currentUser!.id,
            'destination': destination,
            'destination_place_id': destinationPlaceId,
            'destination_lat': destinationLat,
            'destination_lng': destinationLng,
            'start_date': startDate?.toIso8601String().split('T').first,
            'end_date': endDate?.toIso8601String().split('T').first,
          },
          onConflict: 'user_id',
        );

        // Also create an actual trip record for display on home screen
        await _supabase.from('trips').insert({
          'owner_id': currentUser!.id,
          'title': 'Trip to $destination',
          'destination': destination,
          'destination_place_id': destinationPlaceId,
          'destination_lat': destinationLat,
          'destination_lng': destinationLng,
          'start_date': startDate?.toIso8601String().split('T').first,
          'end_date': endDate?.toIso8601String().split('T').first,
          'status': 'planning',
        });
      }
    } catch (e) {
      throw AuthException(_parseError(e));
    }
  }

  // ============================================
  // USER PROFILE DATA
  // ============================================

  /// Get the user's default currency from their profile
  Future<String?> getUserDefaultCurrency() async {
    if (!isAuthenticated) return null;

    try {
      final response = await _supabase
          .from('profiles')
          .select('default_currency')
          .eq('id', currentUser!.id)
          .maybeSingle();

      return response?['default_currency'] as String?;
    } catch (e) {
      debugPrint('Error getting user default currency: $e');
      return null;
    }
  }

  // ============================================
  // RESET USER DATA (FOR TESTING)
  // ============================================

  /// Resets all user data to allow re-testing the onboarding flow
  Future<void> resetUserData() async {
    if (!isAuthenticated) {
      throw AuthException('Not authenticated');
    }

    try {
      final userId = currentUser!.id;

      // Try to use the database function (bypasses RLS)
      try {
        await _supabase.rpc('reset_user_data', params: {'p_user_id': userId});
        debugPrint('User data reset successfully via RPC function');
        return;
      } catch (e) {
        debugPrint('RPC function not available, falling back to direct queries: $e');
      }

      // Fallback: Try direct queries (may fail due to RLS)
      try {
        await _supabase.from('trips').delete().eq('owner_id', userId);
        debugPrint('Deleted trips');
      } catch (e) {
        debugPrint('Could not delete trips (RLS issue): $e');
      }

      try {
        await _supabase.from('onboarding_trips').delete().eq('user_id', userId);
        debugPrint('Deleted onboarding trips');
      } catch (e) {
        debugPrint('Could not delete onboarding trips (RLS issue): $e');
      }

      // Reset onboarding status - this is the most important part
      await _supabase.from('user_settings').update({
        'onboarding_completed': false,
        'onboarding_completed_at': null,
      }).eq('user_id', userId);

      debugPrint('User data reset successfully (onboarding reset)');
    } catch (e) {
      debugPrint('Error resetting user data: $e');
      throw AuthException(_parseError(e));
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String _parseError(dynamic error) {
    if (error is AuthApiException) {
      return error.message;
    }
    if (error is PostgrestException) {
      return error.message;
    }
    return error.toString();
  }
}
