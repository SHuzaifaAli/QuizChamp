import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/core/usecases/usecase.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';
import 'package:quiz_champ/src/domain/usecases/auth/get_user_status.dart';
import 'package:quiz_champ/src/domain/usecases/auth/sign_in_with_google.dart';
import 'package:quiz_champ/src/domain/usecases/auth/sign_out.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInWithGoogle signInWithGoogle;
  final SignOut signOut;
  final GetUserStatus getUserStatus;

  AuthBloc({
    required this.signInWithGoogle,
    required this.signOut,
    required this.getUserStatus,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final result = await getUserStatus(NoParams());
      result.fold(
        (failure) {
          log("❌ [AuthBloc] Auth check failed: ${failure.toString()}");
          emit(AuthUnauthenticated());
        },
        (user) {
          if (user != null) {
            log("✅ [AuthBloc] User authenticated: ${user.displayName}");
            emit(AuthAuthenticated(user));
          } else {
            log("ℹ️ [AuthBloc] No authenticated user");
            emit(AuthUnauthenticated());
          }
        },
      );
    } catch (e, stackTrace) {
      log("💥 [AuthBloc] Unexpected error in auth check: $e");
      log("📚 [AuthBloc] Stack trace: $stackTrace");
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      print("🔥 [AuthBloc] Sign-in requested, emitting AuthLoading...");
      log("🔥 [AuthBloc] Sign-in requested, emitting AuthLoading...");
      emit(AuthLoading());

      print("🚀 [AuthBloc] Calling signInWithGoogle use case...");
      log("🚀 [AuthBloc] Calling signInWithGoogle use case...");
      final result = await signInWithGoogle(NoParams());

      result.fold(
        (failure) {
          print("❌ [AuthBloc] Sign-in failed: ${failure.toString()}");
          log("❌ [AuthBloc] Sign-in failed: ${failure.toString()}");
          emit(AuthError(_mapFailureToMessage(failure)));
        },
        (user) {
          print("✅ [AuthBloc] Sign-in successful! User: ${user.displayName}");
          log("✅ [AuthBloc] Sign-in successful! User: ${user.displayName}");
          log("👤 [AuthBloc] User ID: ${user.id}, Email: ${user.email}");
          emit(AuthAuthenticated(user));
        },
      );
    } catch (e, stackTrace) {
      print("💥💥💥 [AuthBloc] Unexpected error during sign-in: $e");
      log("💥 [AuthBloc] Unexpected error during sign-in: $e");
      log("📚 [AuthBloc] Stack trace: $stackTrace");
      emit(AuthError("An unexpected error occurred: ${e.toString()}"));
    }
  }

  void _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());
      final result = await signOut(NoParams());
      result.fold(
        (failure) {
          log("❌ [AuthBloc] Sign out failed: ${failure.toString()}");
          emit(AuthError(_mapFailureToMessage(failure)));
        },
        (_) {
          log("✅ [AuthBloc] Sign out successful");
          emit(AuthUnauthenticated());
        },
      );
    } catch (e, stackTrace) {
      log("💥 [AuthBloc] Unexpected error during sign out: $e");
      log("📚 [AuthBloc] Stack trace: $stackTrace");
      emit(AuthError("An unexpected error occurred during sign out"));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is UserCancelledAuthFailure) {
      return 'Sign in cancelled by user.';
    } else if (failure is AuthFailure) {
      // Check for specific Google Sign-In errors
      final message = failure.message.toLowerCase();

      // Check for Pigeon type casting errors
      if (message.contains('pigeonuserdetails') ||
          message.contains('type cast')) {
        return 'Authentication configuration error. Please restart the app and try again.';
      } else if (message.contains('apiexception: 10') ||
          message.contains('developer_error')) {
        return 'Google Sign-In configuration error. Please check Firebase console settings.';
      } else if (message.contains('sign_in_failed')) {
        return 'Google Sign-In failed. Please try again.';
      } else if (message.contains('network')) {
        return 'Network error. Please check your internet connection.';
      } else {
        return 'Authentication failed: ${failure.message}';
      }
    }
    return 'An unexpected error occurred during authentication.';
  }
}
