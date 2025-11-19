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
}