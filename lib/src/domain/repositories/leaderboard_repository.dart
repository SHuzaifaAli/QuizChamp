import 'package:dartz/dartz.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/domain/entities/leaderboard_entity.dart';

abstract class LeaderboardRepository {
  Future<Either<Failure, List<LeaderboardEntity>>> getGlobalLeaderboard({int limit = 50});
  Future<Either<Failure, List<LeaderboardEntity>>> getFriendsLeaderboard(String userId, {int limit = 50});
  Future<Either<Failure, LeaderboardEntity?>> getUserRank(String userId);
}
