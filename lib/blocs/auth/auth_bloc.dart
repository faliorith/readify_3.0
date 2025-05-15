import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readify/services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<SignInRequested>(_onSignInRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignOutRequested>(_onSignOutRequested);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<GuestLoginRequested>(_onGuestLoginRequested as EventHandler<GuestLoginRequested, AuthState>);
    
    add(CheckAuthStatus());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    try {
      final user = await authService.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError("Failed to check auth status: ${e.toString()}"));
    }
  }

  Future<void> _onSignInRequested(SignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authService.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError("Sign in failed: ${e.toString()}"));
    }
  }

  Future<void> _onSignUpRequested(SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authService.registerWithEmailAndPassword(
        event.email,
        event.password,
        name: event.name,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError("Sign up failed: ${e.toString()}"));
    }
  }

  Future<void> _onSignOutRequested(SignOutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authService.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError("Sign out failed: ${e.toString()}"));
    }
  }

  Future<void> _onUpdateProfileRequested(UpdateProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authService.updateProfile(
        name: event.name,
        photoUrl: event.photoUrl, userId: '',
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError("Profile update failed: ${e.toString()}"));
    }
  }

Future<void> _onGuestLoginRequested(
  GuestLoginRequested event, 
  Emitter<AuthState> emit, BuildContext context
) async {
  emit(AuthLoading());
  try {
    // Создаем гостевого пользователя через AuthService
    final guestUser = await authService.createGuestUser();
    emit(Authenticated(guestUser));
  } catch (e) {
    emit(AuthError("Guest login failed: ${e.toString()}"));
    debugPrint('Error in guest login: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to enter as guest. Please try again.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
}