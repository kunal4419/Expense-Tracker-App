import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';
import '../core/services/supabase_service.dart';
import '../models/app_user.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

class AuthState {
  final User? user;
  final AppUser? profile;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.profile,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    AppUser? profile,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState(isLoading: true)) {
    _init();
  }

  void _init() {
    _authRepository.authStateChanges.listen((data) async {
      final user = data.session?.user;
      if (user != null) {
        final profile = await _authRepository.getProfile(user.id);
        state = AuthState(user: user, profile: profile, isLoading: false);
      } else {
        state = AuthState(user: null, profile: null, isLoading: false);
      }
    });
    
    // Initial fetch
    final initialUser = _authRepository.currentUser;
    if (initialUser != null) {
      _authRepository.getProfile(initialUser.id).then((profile) {
        state = AuthState(user: initialUser, profile: profile, isLoading: false);
      }).catchError((err) {
        state = AuthState(user: initialUser, profile: null, isLoading: false);
      });
    } else {
      state = AuthState(user: null, profile: null, isLoading: false);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.signIn(email: email, password: password);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signUp(String email, String password, String username) async {
    state = state.copyWith(isLoading: true);
    try {
      await _authRepository.signUp(email: email, password: password, username: username);
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authRepository.signOut();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
