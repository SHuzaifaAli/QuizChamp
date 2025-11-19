import 'package:equatable/equatable.dart';
import '../../../domain/entities/social_activity_entity.dart';

abstract class SocialActivityState extends Equatable {
  const SocialActivityState();

  @override
  List<Object?> get props => [];
}

class SocialActivityInitial extends SocialActivityState {
  const SocialActivityInitial();
}

class SocialActivityLoading extends SocialActivityState {
  const SocialActivityLoading();
}

class SocialActivityFeedLoaded extends SocialActivityState {
  final List<SocialActivity> activities;
  final List<String> friendIds;

  const SocialActivityFeedLoaded({
    required this.activities,
    required this.friendIds,
  });

  @override
  List<Object?> get props => [activities, friendIds];

  SocialActivityFeedLoaded copyWith({
    List<SocialActivity>? activities,
    List<String>? friendIds,
  }) {
    return SocialActivityFeedLoaded(
      activities: activities ?? this.activities,
      friendIds: friendIds ?? this.friendIds,
    );
  }
}

class SocialActivityOperationInProgress extends SocialActivityState {
  final String operation;
  const SocialActivityOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

class SocialActivityOperationSuccess extends SocialActivityState {
  final String message;
  const SocialActivityOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class SocialActivityError extends SocialActivityState {
  final String message;
  const SocialActivityError(this.message);

  @override
  List<Object?> get props => [message];
}

class ActivityCreated extends SocialActivityState {
  final SocialActivity activity;
  const ActivityCreated(this.activity);

  @override
  List<Object?> get props => [activity];
}

class ReactionAdded extends SocialActivityState {
  final String activityId;
  final String userId;
  final ReactionType reactionType;
  const ReactionAdded(this.activityId, this.userId, this.reactionType);

  @override
  List<Object?> get props => [activityId, userId, reactionType];
}

class ReactionRemoved extends SocialActivityState {
  final String activityId;
  final String userId;
  const ReactionRemoved(this.activityId, this.userId);

  @override
  List<Object?> get props => [activityId, userId];
}

class RecentActivitiesLoaded extends SocialActivityState {
  final List<SocialActivity> activities;
  const RecentActivitiesLoaded(this.activities);

  @override
  List<Object?> get props => [activities];
}
