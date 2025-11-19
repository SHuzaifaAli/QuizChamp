import 'package:equatable/equatable.dart';
import '../../../domain/entities/social_activity_entity.dart';

abstract class SocialActivityEvent extends Equatable {
  const SocialActivityEvent();

  @override
  List<Object?> get props => [];
}

class LoadFriendsActivityFeed extends SocialActivityEvent {
  final List<String> friendIds;

  const LoadFriendsActivityFeed(this.friendIds);

  @override
  List<Object?> get props => [friendIds];
}

class CreateQuizCompletedActivity extends SocialActivityEvent {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int score;
  final int totalQuestions;
  final String category;
  final Duration timeTaken;

  const CreateQuizCompletedActivity({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.timeTaken,
  });

  @override
  List<Object?> get props => [
        userId,
        userName,
        userPhotoUrl,
        score,
        totalQuestions,
        category,
        timeTaken,
      ];
}

class AddReactionToActivity extends SocialActivityEvent {
  final String activityId;
  final String userId;
  final ReactionType reactionType;

  const AddReactionToActivity({
    required this.activityId,
    required this.userId,
    required this.reactionType,
  });

  @override
  List<Object?> get props => [activityId, userId, reactionType];
}

class RemoveReactionFromActivity extends SocialActivityEvent {
  final String activityId;
  final String userId;

  const RemoveReactionFromActivity({
    required this.activityId,
    required this.userId,
  });

  @override
  List<Object?> get props => [activityId, userId];
}

class RefreshActivityFeed extends SocialActivityEvent {
  final List<String> friendIds;

  const RefreshActivityFeed(this.friendIds);

  @override
  List<Object?> get props => [friendIds];
}

class LoadRecentActivities extends SocialActivityEvent {
  final List<String> friendIds;
  final int limit;

  const LoadRecentActivities(this.friendIds, {this.limit = 20});

  @override
  List<Object?> get props => [friendIds, limit];
}

class CreateAchievementActivity extends SocialActivityEvent {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String achievementTitle;
  final String achievementDescription;

  const CreateAchievementActivity({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.achievementTitle,
    required this.achievementDescription,
  });

  @override
  List<Object?> get props => [
        userId,
        userName,
        userPhotoUrl,
        achievementTitle,
        achievementDescription,
      ];
}

class CreateStreakActivity extends SocialActivityEvent {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int streakDays;

  const CreateStreakActivity({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.streakDays,
  });

  @override
  List<Object?> get props => [
        userId,
        userName,
        userPhotoUrl,
        streakDays,
      ];
}
