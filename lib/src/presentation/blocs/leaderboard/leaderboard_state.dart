import 'package:equatable/equatable.dart';
import 'package:quiz_champ/src/domain/entities/leaderboard_entity.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object?> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class GlobalLeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntity> leaderboard;

  const GlobalLeaderboardLoaded(this.leaderboard);

  @override
  List<Object?> get props => [leaderboard];
}

class FriendsLeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntity> leaderboard;

  const FriendsLeaderboardLoaded(this.leaderboard);

  @override
  List<Object?> get props => [leaderboard];
}

class UserRankLoaded extends LeaderboardState {
  final LeaderboardEntity? userRank;

  const UserRankLoaded(this.userRank);

  @override
  List<Object?> get props => [userRank];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object?> get props => [message];
}
