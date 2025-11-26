import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/social_activity_entity.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/repositories/social_activity_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/social_activity_remote_datasource.dart';

class SocialActivityRepositoryImpl implements SocialActivityRepository {
  final SocialActivityRemoteDataSource _remoteDataSource;

  SocialActivityRepositoryImpl(this._remoteDataSource);

  @override
  Stream<List<SocialActivity>> getActivityFeedStream(String userId) {
    return _remoteDataSource.getActivityFeed(userId);
  }

  @override
  Future<Either<Failure, void>> recordActivity(SocialActivity activity) async {
    try {
      await _remoteDataSource.createActivity(activity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> reactToActivity(String activityId, String userId, ReactionType reaction) async {
    try {
      await _remoteDataSource.addReaction(activityId, userId, reaction);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeReaction(String activityId, String userId, ReactionType reaction) async {
    try {
      await _remoteDataSource.removeReaction(activityId, userId, reaction);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SocialActivity>>> getFriendActivities(String userId, List<String> friendIds, {int limit = 20}) async {
    try {
      final activities = await _remoteDataSource.getFriendActivities(friendIds, limit: limit);
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteActivity(String activityId, String userId) async {
    try {
      await _remoteDataSource.deleteActivity(activityId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateActivityVisibility(String activityId, bool isVisible) async {
    try {
      await _remoteDataSource.updateActivityVisibility(activityId, isVisible);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addReactionToActivity(String activityId, String reaction, ReactionType reactionType) async {
    try {
      await _remoteDataSource.addReaction(activityId, reaction, reactionType);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createQuizCompletedActivity(Map<String, dynamic> activityData) async {
    try {
      final activity = SocialActivity(
        id: FirebaseFirestore.instance.collection('social_activities').doc().id,
        userId: activityData['userId'] as String,
        userName: activityData['userName'] as String,
        userPhotoUrl: activityData['userPhotoUrl'] as String?,
        type: ActivityType.quizCompleted,
        data: activityData,
        timestamp: DateTime.now(),
        reactions: [],
        isVisible: true,
        description: 'Completed a quiz in ${activityData['category']}',
      );
      
      await _remoteDataSource.createActivity(activity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Stream<List<SocialActivity>>>> getFriendsActivityFeed(String userId) async {
    try {
      final feedStream = _remoteDataSource.getActivityFeed(userId);
      return Right(feedStream);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeReactionFromActivity(String activityId, String reaction) async {
    try {
      // Parse the reaction string to get the ReactionType enum
      final reactionType = ReactionType.values.firstWhere(
        (e) => e.toString() == 'ReactionType.$reaction',
        orElse: () => ReactionType.like,
      );
      await _remoteDataSource.removeReaction(activityId, reaction, reactionType);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createAchievementUnlockedActivity(Map<String, dynamic> achievementData) async {
    try {
      final activity = SocialActivity(
        id: FirebaseFirestore.instance.collection('social_activities').doc().id,
        userId: achievementData['userId'] as String,
        userName: achievementData['userName'] as String,
        userPhotoUrl: achievementData['userPhotoUrl'] as String?,
        type: ActivityType.achievementUnlocked,
        data: achievementData,
        timestamp: DateTime.now(),
        reactions: [],
        isVisible: true,
        description: 'Unlocked achievement: ${achievementData['achievementTitle']}',
      );
      
      await _remoteDataSource.createActivity(activity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createStreakActivity(Map<String, dynamic> streakData) async {
    try {
      final activity = SocialActivity(
        id: FirebaseFirestore.instance.collection('social_activities').doc().id,
        userId: streakData['userId'] as String,
        userName: streakData['userName'] as String,
        userPhotoUrl: streakData['userPhotoUrl'] as String?,
        type: ActivityType.streakAchieved,
        data: streakData,
        timestamp: DateTime.now(),
        reactions: [],
        isVisible: true,
        description: 'Achieved a ${streakData['streakDays']} day streak!',
      );
      
      await _remoteDataSource.createActivity(activity);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SocialActivity>>> getRecentActivities(List<String> friendIds, {int limit = 20}) async {
    try {
      final activities = await _remoteDataSource.getRecentActivities(friendIds, limit: limit);
      return Right(activities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
