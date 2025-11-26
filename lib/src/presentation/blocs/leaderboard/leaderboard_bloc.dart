import 'package:bloc/bloc.dart';
import 'package:quiz_champ/src/domain/repositories/leaderboard_repository.dart';
import 'package:quiz_champ/src/presentation/blocs/leaderboard/leaderboard_event.dart';
import 'package:quiz_champ/src/presentation/blocs/leaderboard/leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository repository;

  LeaderboardBloc({required this.repository}) : super(LeaderboardInitial()) {
    on<LoadGlobalLeaderboard>(_onLoadGlobalLeaderboard);
    on<LoadFriendsLeaderboard>(_onLoadFriendsLeaderboard);
    on<LoadUserRank>(_onLoadUserRank);
    on<RefreshLeaderboard>(_onRefreshLeaderboard);
  }

  Future<void> _onLoadGlobalLeaderboard(
    LoadGlobalLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    final result = await repository.getGlobalLeaderboard(limit: event.limit);

    result.fold(
      (failure) => emit(LeaderboardError(failure.toString())),
      (leaderboard) => emit(GlobalLeaderboardLoaded(leaderboard)),
    );
  }

  Future<void> _onLoadFriendsLeaderboard(
    LoadFriendsLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    final result = await repository.getFriendsLeaderboard(event.userId,
        limit: event.limit);

    result.fold(
      (failure) => emit(LeaderboardError(failure.toString())),
      (leaderboard) => emit(FriendsLeaderboardLoaded(leaderboard)),
    );
  }

  Future<void> _onLoadUserRank(
    LoadUserRank event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    final result = await repository.getUserRank(event.userId);

    result.fold(
      (failure) => emit(LeaderboardError(failure.toString())),
      (userRank) => emit(UserRankLoaded(userRank)),
    );
  }

  Future<void> _onRefreshLeaderboard(
    RefreshLeaderboard event,
    Emitter<LeaderboardState> emit,
  ) async {
    // Load both global and friends leaderboard
    final globalResult = await repository.getGlobalLeaderboard(limit: 50);
    final friendsResult =
        await repository.getFriendsLeaderboard(event.userId, limit: 50);
    final userRankResult = await repository.getUserRank(event.userId);

    // Handle global leaderboard
    globalResult.fold(
      (failure) => emit(LeaderboardError(failure.toString())),
      (globalLeaderboard) => emit(GlobalLeaderboardLoaded(globalLeaderboard)),
    );

    // Handle friends leaderboard
    friendsResult.fold(
      (failure) => null, // Don't emit error for friends if it fails
      (friendsLeaderboard) =>
          emit(FriendsLeaderboardLoaded(friendsLeaderboard)),
    );

    // Handle user rank
    userRankResult.fold(
      (failure) => null, // Don't emit error for user rank if it fails
      (userRank) => emit(UserRankLoaded(userRank)),
    );
  }
}
