import 'package:dartz/dartz.dart';
import '../entities/social_activity_entity.dart';
import '../../core/error/failures.dart';

abstract class SocialActivityRepository {
  Stream<List<SocialActivity>> getActivityFeedStream(String userId);
  Future<Either<Failure, void>> recordActivity(SocialActivity activity);
  Future<Either<Failure, void>> reactToActivity(String activityId, String userId, ReactionType reaction);
  Future<Either<Failure, void>> removeReaction(String activityId, String userId, ReactionType reaction);
  Future<Either<Failure, List<SocialActivity>>> getFriendActivities(String userId, List<String> friendIds, {int limit = 20});
  Future<Either<Failure, void>> deleteActivity(String activityId, String userId);
  Future<Either<Failure, void>> updateActivityVisibility(String activityId, bool isVisible);
  Future<Either<Failure, void>> addReactionToActivity(String activityId, String reaction, ReactionType reactionType);
  Future<Either<Failure, void>> createQuizCompletedActivity(Map<String, dynamic> activityData);
  Future<Either<Failure, Stream<List<SocialActivity>>>> getFriendsActivityFeed(String userId);
  Future<Either<Failure, void>> removeReactionFromActivity(String activityId, String reaction);
  Future<Either<Failure, void>> createAchievementUnlockedActivity(Map<String, dynamic> achievementData);
  Future<Either<Failure, void>> createStreakActivity(Map<String, dynamic> streakData);
  Future<Either<Failure, List<SocialActivity>>> getRecentActivities(List<String> friendIds, {int limit = 20});
}