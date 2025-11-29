import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatapp/config/supabase_client.dart';
import 'package:chatapp/models/user_model.dart';

class AuthService {
  SupabaseClient get _client => SupabaseConfig.client;
  static const String _guestKey = 'guest_user';

  Future<UserModel> loginAsGuest({String? username}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final user = UserModel(
        id: 'guest-${now.millisecondsSinceEpoch}',
        email: 'guest@local',
        username: (username == null || username.trim().isEmpty)
            ? 'Guest ${now.millisecondsSinceEpoch % 1000}'
            : username.trim(),
        lastSeen: now,
        createdAt: now,
        isOnline: true,
      );

      await prefs.setString(
        _guestKey,
        jsonEncode(user.toJson()),
      );
      debugPrint('✅ Guest session created for ${user.username}');
      return user;
    } catch (e) {
      debugPrint('❌ Guest login error: $e');
      rethrow;
    }
  }

  Future<UserModel?> _getStoredGuest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_guestKey);
      if (raw == null) return null;
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return null;
      if (!data.containsKey('id') || !data.containsKey('username')) {
        await prefs.remove(_guestKey);
        return null;
      }
      return UserModel.fromJson(Map<String, dynamic>.from(data));
    } catch (e) {
      debugPrint('❌ Failed to read guest session: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_guestKey);
      } catch (_) {}
      return null;
    }
  }

  Future<void> _clearGuest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestKey);
      debugPrint('✅ Guest session cleared');
    } catch (e) {
      debugPrint('❌ Failed to clear guest session: $e');
    }
  }

  Future<UserModel?> signUp(String email, String password, String username) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not configured. Please connect from Dreamflow panel.');
      }

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

      final user = UserModel(
        id: response.user!.id,
        email: email,
        username: username,
        lastSeen: DateTime.now(),
        createdAt: DateTime.now(),
        isOnline: true,
      );

      await _client.from('profiles').insert(user.toJson());
      debugPrint('✅ User signed up: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('❌ Sign up error: $e');
      rethrow;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not configured. Please connect from Dreamflow panel.');
      }

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed');
      }

      await updateUserStatus(response.user!.id, true);
      final userData = await _client
          .from('profiles')
          .select()
          .eq('id', response.user!.id)
          .single();

      final user = UserModel.fromJson(userData);
      debugPrint('✅ User logged in: ${user.email}');
      return user;
    } catch (e) {
      debugPrint('❌ Login error: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _clearGuest();

      if (SupabaseConfig.isInitialized) {
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          await updateUserStatus(userId, false);
        }
        await _client.auth.signOut();
        debugPrint('✅ User logged out');
      }
    } catch (e) {
      debugPrint('❌ Logout error: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      if (!SupabaseConfig.isInitialized) {
        throw Exception('Supabase not configured. Please connect from Dreamflow panel.');
      }

      await _client.auth.resetPasswordForEmail(email);
      debugPrint('✅ Password reset email sent to: $email');
    } catch (e) {
      debugPrint('❌ Reset password error: $e');
      rethrow;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      if (SupabaseConfig.isInitialized) {
        final user = _client.auth.currentUser;
        if (user == null) {
          return await _getStoredGuest();
        }

        final userData = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        return UserModel.fromJson(userData);
      } else {
        return await _getStoredGuest();
      }
    } catch (e) {
      debugPrint('❌ Get current user error: $e');
      return null;
    }
  }

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    try {
      if (!SupabaseConfig.isInitialized) return;

      await _client.from('profiles').update({
        'is_online': isOnline,
        'last_seen': DateTime.now().toIso8601String(),
      }).eq('id', userId);
      debugPrint('✅ User status updated: $isOnline');
    } catch (e) {
      debugPrint('❌ Update user status error: $e');
    }
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}







