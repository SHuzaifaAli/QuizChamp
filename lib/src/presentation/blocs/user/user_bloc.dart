import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/user_service.dart';
import '../../../data/models/user_model.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;

  UserBloc({required this.userService}) : super(const UserInitial()) {
    on<LoadUserData>(_onLoadUserData);
    on<UpdateUserHearts>(_onUpdateUserHearts);
    on<UpdateUserPoints>(_onUpdateUserPoints);
    on<RefreshUserData>(_onRefreshUserData);
  }

  Future<void> _onLoadUserData(LoadUserData event, Emitter<UserState> emit) async {
    emit(const UserLoading());
    try {
      final userData = await userService.getCurrentUserData();
      if (userData != null) {
        emit(UserLoaded(user: userData));
      } else {
        emit(const UserError(message: 'User data not found'));
      }
    } catch (e) {
      emit(UserError(message: 'Failed to load user data: $e'));
    }
  }

  Future<void> _onUpdateUserHearts(UpdateUserHearts event, Emitter<UserState> emit) async {
    final currentState = state;
    if (currentState is UserLoaded) {
      try {
        await userService.updateUserHearts(event.hearts);
        final updatedUser = currentState.user.copyWith(hearts: event.hearts);
        emit(UserLoaded(user: updatedUser));
      } catch (e) {
        emit(UserError(message: 'Failed to update hearts: $e'));
      }
    }
  }

  Future<void> _onUpdateUserPoints(UpdateUserPoints event, Emitter<UserState> emit) async {
    final currentState = state;
    if (currentState is UserLoaded) {
      try {
        await userService.updateUserPoints(event.points);
        final updatedUser = currentState.user.copyWith(points: event.points);
        emit(UserLoaded(user: updatedUser));
      } catch (e) {
        emit(UserError(message: 'Failed to update points: $e'));
      }
    }
  }

  Future<void> _onRefreshUserData(RefreshUserData event, Emitter<UserState> emit) async {
    add(const LoadUserData());
  }
}
