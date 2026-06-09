import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitial()) {

    on<AuthCheckRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final loggedIn = await _authRepository.isLoggedIn();
        if (loggedIn) {
          final user = await _authRepository.getMe();
          emit(AuthAuthenticated(user));
        } else {
          emit(AuthUnauthenticated());
        }
      } catch (_) {
        emit(AuthUnauthenticated());
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.login(event.email, event.password);
        final user = await _authRepository.getMe();
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthRegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.register(
          name: event.name,
          email: event.email,
          password: event.password,
          interests: event.interests,
        );
        final user = await _authRepository.getMe();
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      await _authRepository.logout();
      emit(AuthUnauthenticated());
    });

    on<AuthInterestsUpdated>((event, emit) async {
      if (state is AuthAuthenticated) {
        try {
          final user = await _authRepository.updateInterests(event.interests);
          emit(AuthAuthenticated(user));
        } catch (e) {
          emit(AuthError(e.toString()));
        }
      }
    });

    on<AuthPasswordChangeRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.changePassword(
          currentPassword: event.currentPassword,
          newPassword: event.newPassword,
        );
        emit(AuthPasswordChanged());
        final user = await _authRepository.getMe();
        emit(AuthAuthenticated(user));
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthAccountDeleteRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        await _authRepository.deleteAccount(event.password);
        emit(AuthAccountDeleted());
        emit(AuthUnauthenticated());
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });
  }
}