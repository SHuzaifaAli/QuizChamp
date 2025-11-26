import 'package:dartz/dartz.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/data/datasources/leaderboard_remote_datasource.dart';
import 'package:quiz_champ/src/domain/entities/leaderboard_entity.dart';
import 'package:quiz_champ/src/domain/repositories/leaderboard_repository.dart';

class LeaderboardRepositoryImpl implements LeaderboardRepository {
  final LeaderboardRemoteDataSource remoteDataSource;

  LeaderboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LeaderboardEntity>>> getGlobalLeaderboard({int limit = 50}) async {
    try {
      final leaderboard = await remoteDataSource.getGlobalLeaderboard(limit: limit);
      return Right(leaderboard);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get global leaderboard: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LeaderboardEntity>>> getFriendsLeaderboard(String userId, {int limit = 50}) async {
    try {
      final leaderboard = await remoteDataSource.getFriendsLeaderboard(userId, limit: limit);
      return Right(leaderboard);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get friends leaderboard: $e'));
    }
  }

  @override
  Future<Either<Failure, LeaderboardEntity?>> getUserRank(String userId) async {
    try {
      final userRank = await remoteDataSource.getUserRank(userId);
      return Right(userRank);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get user rank: $e'));
    }
  }
}
