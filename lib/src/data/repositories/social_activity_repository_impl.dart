import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/social_activity_entity.dart';
import '../../domain/repositories/social_activity_repository.dart';
import '../datasources/social_activity_remote_datasource.dart';

class SocialActivityRepositoryImpl implements SocialActivityRepository {
  final SocialActivityRemoteDataSource _remoteDataSource;

  SocialActivityRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createQuizCompletedActivity({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int score,
    required int totalQuestions,
    required String category,
    required Duration timeTaken,
  }) async {
    final activity = SocialActivity(
      id: _generateActivityId(),
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: SocialActivityType.quizCompleted,
      data: {
        'score': score,
        'totalQuestions': totalQuestions,
        'accuracy': score / totalQuestions,
        'category': category,
        'timeTaken': timeTaken.inSeconds,
      },
      timestamp: DateTime.now(),
      reactions: {},
      isVisible: true,
      description: 'Completed a $category quiz with ${((score / totalQuestions) * 100).toInt()}% accuracy',
    );

    await _remoteDataSource.createActivity(activity);
  }

  @override
  Future<void> createAchievementUnlockedActivity({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String achievementTitle,
    required String achievementDescription,
  }) async {
    final activity = SocialActivity(
      id: _generateActivityId(),
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: SocialActivityType.achievementUnlocked,
      data: {
        'achievementTitle': achievementTitle,
        'achievementDescription': achievementDescription,
      },
      timestamp: DateTime.now(),
      reactions: {},
      isVisible: true,
      description: 'Unlocked achievement: $achievementTitle',
    );

    await _remoteDataSource.createActivity(activity);
  }

  @override
  Future<void> createNewHighScoreActivity({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int score,
    required String category,
    required String difficulty,
  }) async {
    final activity = SocialActivity(
      id: _generateActivityId(),
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: SocialActivityType.newHighScore,
      data: {
        'score': score,
        'category': category,
        'difficulty': difficulty,
      },
      timestamp: DateTime.now(),
      reactions: {},
      isVisible: true,
      description: 'New high score: $score in $category ($difficulty)',
    );

    await _remoteDataSource.createActivity(activity);
  }

  @override
  Future<void> createStreakActivity({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required int streakDays,
  }) async {
    final activity = SocialActivity(
      id: _generateActivityId(),
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: SocialActivityType.streakMilestone,
      data: {
        'streakDays': streakDays,
      },
      timestamp: DateTime.now(),
      reactions: {},
      isVisible: true,
      description: streakDays == 1 
          ? 'Started a new quiz streak!'
          : 'Maintained a ${streakDays}-day quiz streak!',
    );

    await _remoteDataSource.createActivity(activity);
  }

  @override
  Future<void> createChallengeActivity({
    required String userId,
    required String userName,
    String? userPhotoUrl,
    required String opponentName,
    required ChallengeResult result,
    required int score,
  }) async {
    final activity = SocialActivity(
      id: _generateActivityId(),
      userId: userId,
      userName: userName,
      userPhotoUrl: userPhotoUrl,
      type: SocialActivityType.challengeCompleted,
      data: {
        'opponentName': opponentName,
        'result': result.name,
        'score': score,
      },
      timestamp: DateTime.now(),
      reactions: {},
      isVisible: true,
      description: 'Challenged $opponentName - ${result.name}',
    );

    await _remoteDataSource.createActivity(activity);
  }

  @override
  Stream<List<SocialActivity>> getFriendsActivityFeed(List<String> friendIds) {
    return _remoteDataSource.getFriendsActivityFeed(friendIds);
  }

  @override
  Future<List<SocialActivity>> getRecentActivities(
    List<String> friendIds, {
    int limit = 20,
  }) async {
    return await _remoteDataSource.getRecentActivities(friendIds, limit: limit);
  }

  @override
  Future<List<SocialActivity>> getActivitiesByType(
    List<String> friendIds,
    SocialActivityType type, {
    int limit = 10,
  }) async {
    return await _remoteDataSource.getActivitiesByType(friendIds, type, limit: limit);
  }

  @override
  Future<void> addReactionToActivity(
    String activityId,
    String userId,
    ReactionType reactionType,
  ) async {
    await _remoteDataSource.addReactionToActivity(
      activityId,
      userId,
      reactionType.name,
    );
  }

  @override
  Future<void> removeReactionFromActivity(
    String activityId,
    String userId,
  ) async {
    await _remoteDataSource.removeReactionFromActivity(activityId, userId);
  }

  @override
  Future<void> updateActivityVisibility(
    String activityId,
    bool isVisible,
  ) async {
    await _remoteDataSource.updateActivityVisibility(activityId, isVisible);
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    await _remoteDataSource.deleteActivity(activityId);
  }

  @override
  Future<void> cleanupOldActivities({int daysOld = 90}) async {
    await _remoteDataSource.cleanupOldActivities(daysOld: daysOld);
  }

  @override
  Stream<List<SocialActivity>> getUserActivityFeed(String userId) {
    return _remoteDataSource.getUserActivityFeed(userId);
  }

  String _generateActivityId() {
    return FirebaseFirestore.instance.collection('social_activities').doc().id;
  }
}
