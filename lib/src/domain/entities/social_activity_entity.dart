import 'package:equatable/equatable.dart';

enum ActivityType {
  quizCompleted,
  achievementUnlocked,
  streakAchieved,
  challengeWon,
  challengeLost,
  friendAdded,
  levelUp,
  personalBest,
}

enum ReactionType {
  like,
  congratulate,
  wow,
  fire,
}

class SocialActivity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final ActivityType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final List<ActivityReaction> reactions;
  final bool isVisible;
  final String description;

  const SocialActivity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.type,
    required this.data,
    required this.timestamp,
    required this.reactions,
    required this.isVisible,
    required this.description,
  });

  SocialActivity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    ActivityType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    List<ActivityReaction>? reactions,
    bool? isVisible,
    String? description,
  }) {
    return SocialActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      reactions: reactions ?? this.reactions,
      isVisible: isVisible ?? this.isVisible,
      description: description ?? this.description,
    );
  }

  int getReactionCount(ReactionType reactionType) {
    return reactions.where((r) => r.type == reactionType).length;
  }

  bool hasUserReacted(String userId, ReactionType reactionType) {
    return reactions.any((r) => r.userId == userId && r.type == reactionType);
  }

  List<ActivityReaction> getUserReactions(String userId) {
    return reactions.where((r) => r.userId == userId).toList();
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userPhotoUrl,
        type,
        data,
        timestamp,
        reactions,
        isVisible,
        description,
      ];
}

class ActivityReaction extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final ReactionType type;
  final DateTime timestamp;

  const ActivityReaction({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        type,
        timestamp,
      ];
}