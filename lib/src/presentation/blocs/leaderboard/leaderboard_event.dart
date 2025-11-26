import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

class LoadGlobalLeaderboard extends LeaderboardEvent {
  final int limit;

  const LoadGlobalLeaderboard({this.limit = 50});

  @override
  List<Object> get props => [limit];
}

class LoadFriendsLeaderboard extends LeaderboardEvent {
  final String userId;
  final int limit;

  const LoadFriendsLeaderboard({required this.userId, this.limit = 50});

  @override
  List<Object> get props => [userId, limit];
}

class LoadUserRank extends LeaderboardEvent {
  final String userId;

  const LoadUserRank({required this.userId});

  @override
  List<Object> get props => [userId];
}

class RefreshLeaderboard extends LeaderboardEvent {
  final String userId;

  const RefreshLeaderboard({required this.userId});

  @override
  List<Object> get props => [userId];
}
