import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_exceptions.dart';
import '../data/auth_repository.dart';
import '../data/google_sign_in_service.dart';
import '../domain/app_user.dart';
import 'auth_state.dart';

final NotifierProvider<AuthController, AuthState> authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final GoogleSignInService _googleSignInService;
  AppUser? _user;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    _googleSignInService = ref.read(googleSignInServiceProvider);
    _bootstrap();
    return const AuthState.initial();
  }

  void _bootstrap() async {
    try {
      final AppUser? user = await _repository.currentUser();
      if (user == null) {
        state = const AuthState.unauthenticated();
      } else {
        _user = user;
        state = AuthState.authenticated(user);
      }
    } on NetworkException catch (error) {
      state = AuthState.failure(error.message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AuthState.loading(message: 'Signing in...');
    try {
      final AppUser user = await _repository.signIn(
        email: email,
        password: password,
      );
      _user = user;
      state = AuthState.authenticated(user);
    } on NetworkException catch (error) {
      state = AuthState.failure(error.message);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String accountType,
    required String firstName,
    required String lastName,
  }) async {
    state = const AuthState.loading(message: 'Creating account...');
    try {
      final AppUser user = await _repository.signUp(
        email: email,
        password: password,
        accountType: accountType,
        firstName: firstName,
        lastName: lastName,
      );
      _user = user;
      state = AuthState.authenticated(user);
    } on NetworkException catch (error) {
      state = AuthState.failure(error.message);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState.loading(message: 'Signing in...');

    try {
      final String code =
          await _googleSignInService.signInAndGetServerAuthCode();

      final AppUser user = await _repository.authenticateWithGoogle(
        code: code,
        intent: 'signin',
      );

      _user = user;
      state = AuthState.authenticated(user);
    } on GoogleSignInCancelledFailure {
      state = const AuthState.unauthenticated();
    } on GoogleSignInFailure catch (error) {
      state = AuthState.failure(error.message);
    } on NetworkException catch (error) {
      state = AuthState.failure(error.message);
    }
  }

  Future<void> signUpWithGoogle({required String accountType}) async {
    state = const AuthState.loading(message: 'Creating account...');

    try {
      final String code =
          await _googleSignInService.signInAndGetServerAuthCode();

      final AppUser user = await _repository.authenticateWithGoogle(
        code: code,
        intent: 'signup',
        accountType: accountType,
      );

      _user = user;
      state = AuthState.authenticated(user);
    } on GoogleSignInCancelledFailure {
      state = const AuthState.unauthenticated();
    } on GoogleSignInFailure catch (error) {
      state = AuthState.failure(error.message);
    } on NetworkException catch (error) {
      state = AuthState.failure(error.message);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    state = const AuthState.unauthenticated();
  }

  AppUser? get currentUser => _user;
}
