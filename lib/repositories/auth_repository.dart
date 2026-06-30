import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<AppUser?> getProfile(String userId) async {
    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (data == null) return null;
      return AppUser.fromJson(data);
    } catch (e) {
      return null;
    }
  }
}
