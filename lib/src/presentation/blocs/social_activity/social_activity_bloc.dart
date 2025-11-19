import 'package:bloc/bloc.dart';
import '../../../domain/entities/social_activity_entity.dart';
import '../../../domain/usecases/social/get_friends_activity_feed_usecase.dart';
import '../../../domain/usecases/social/create_quiz_completed_activity_usecase.dart';
import '../../../domain/usecases/social/add_reaction_to_activity_usecase.dart';
import '../../../domain/repositories/social_activity_repository.dart';
// import '../../../errors/failures.dart';
import 'social_activity_event.dart';
import 'social_activity_state.dart';

class SocialActivityBloc
    extends Bloc<SocialActivityEvent, SocialActivityState> {
  final GetFriendsActivityFeedUseCase _getFriendsActivityFeedUseCase;
  final CreateQuizCompletedActivityUseCase _createQuizCompletedActivityUseCase;
  final AddReactionToActivityUseCase _addReactionToActivityUseCase;
  final SocialActivityRepository _socialActivityRepository;

  SocialActivityBloc({
    required GetFriendsActivityFeedUseCase getFriendsActivityFeedUseCase,
    required CreateQuizCompletedActivityUseCase
        createQuizCompletedActivityUseCase,
    required AddReactionToActivityUseCase addReactionToActivityUseCase,
    required SocialActivityRepository socialActivityRepository,
  })  : _getFriendsActivityFeedUseCase = getFriendsActivityFeedUseCase,
        _createQuizCompletedActivityUseCase =
            createQuizCompletedActivityUseCase,
        _addReactionToActivityUseCase = addReactionToActivityUseCase,
        _socialActivityRepository = socialActivityRepository,
        super(const SocialActivityInitial()) {
    on<LoadFriendsActivityFeed>(_onLoadFriendsActivityFeed);
    on<CreateQuizCompletedActivity>(_onCreateQuizCompletedActivity);
    on<AddReactionToActivity>(_onAddReactionToActivity);
    on<RemoveReactionFromActivity>(_onRemoveReactionFromActivity);
    on<RefreshActivityFeed>(_onRefreshActivityFeed);
    on<LoadRecentActivities>(_onLoadRecentActivities);
    on<CreateAchievementActivity>(_onCreateAchievementActivity);
    on<CreateStreakActivity>(_onCreateStreakActivity);
  }

  Future<void> _onLoadFriendsActivityFeed(
    LoadFriendsActivityFeed event,
    Emitter<SocialActivityState> emit,
  ) async {
    emit(const SocialActivityLoading());

    try {
      final activityStream = _getFriendsActivityFeedUseCase(event.friendIds);

      await for (final activities in activityStream) {
        emit(SocialActivityFeedLoaded(
          activities: activities,
          friendIds: event.friendIds,
        ));
      }
    } catch (e) {
      emit(
          SocialActivityError('Failed to load activity feed: ${e.toString()}'));
    }
  }

  Future<void> _onCreateQuizCompletedActivity(
    CreateQuizCompletedActivity event,
    Emitter<SocialActivityState> emit,
  ) async {
    emit(const SocialActivityOperationInProgress('Creating activity...'));

    try {
      final params = QuizCompletedActivityParams(
        userId: event.userId,
        userName: event.userName,
        userPhotoUrl: event.userPhotoUrl,
        score: event.score,
        totalQuestions: event.totalQuestions,
        category: event.category,
        timeTaken: event.timeTaken,
      );

      final result = await _createQuizCompletedActivityUseCase(params);

      result.fold(
        (failure) =>
            emit(SocialActivityError('Failed to create activity: ${failure}')),
        (success) =>
            emit(const SocialActivityOperationSuccess('Activity created!')),
      );
    } catch (e) {
      emit(SocialActivityError('Failed to create activity: ${e.toString()}'));
    }
  }

  Future<void> _onAddReactionToActivity(
    AddReactionToActivity event,
    Emitter<SocialActivityState> emit,
  ) async {
    try {
      final params = AddReactionParams(
        activityId: event.activityId,
        userId: event.userId,
        reactionType: event.reactionType,
      );

      final result = await _addReactionToActivityUseCase(params);

      result.fold(
        (failure) => emit(
            SocialActivityError('Failed to add reaction: ${failure.message}')),
        (success) => emit(ReactionAdded(
          event.activityId,
          event.userId,
          event.reactionType,
        )),
      );
    } catch (e) {
      emit(SocialActivityError('Failed to add reaction: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveReactionFromActivity(
    RemoveReactionFromActivity event,
    Emitter<SocialActivityState> emit,
  ) async {
    try {
      await _socialActivityRepository.removeReactionFromActivity(
        event.activityId,
        event.userId,
      );

      emit(ReactionRemoved(event.activityId, event.userId));
    } catch (e) {
      emit(SocialActivityError('Failed to remove reaction: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshActivityFeed(
    RefreshActivityFeed event,
    Emitter<SocialActivityState> emit,
  ) async {
    add(LoadFriendsActivityFeed(event.friendIds));
  }

  Future<void> _onLoadRecentActivities(
    LoadRecentActivities event,
    Emitter<SocialActivityState> emit,
  ) async {
    try {
      final activities = await _socialActivityRepository.getRecentActivities(
        event.friendIds,
        limit: event.limit,
      );

      emit(RecentActivitiesLoaded(activities));
    } catch (e) {
      emit(SocialActivityError(
          'Failed to load recent activities: ${e.toString()}'));
    }
  }

  Future<void> _onCreateAchievementActivity(
    CreateAchievementActivity event,
    Emitter<SocialActivityState> emit,
  ) async {
    emit(const SocialActivityOperationInProgress(
        'Creating achievement activity...'));

    try {
      await _socialActivityRepository.createAchievementUnlockedActivity(
        userId: event.userId,
        userName: event.userName,
        userPhotoUrl: event.userPhotoUrl,
        achievementTitle: event.achievementTitle,
        achievementDescription: event.achievementDescription,
      );

      emit(const SocialActivityOperationSuccess(
          'Achievement activity created!'));
    } catch (e) {
      emit(SocialActivityError(
          'Failed to create achievement activity: ${e.toString()}'));
    }
  }

  Future<void> _onCreateStreakActivity(
    CreateStreakActivity event,
    Emitter<SocialActivityState> emit,
  ) async {
    emit(
        const SocialActivityOperationInProgress('Creating streak activity...'));

    try {
      await _socialActivityRepository.createStreakActivity(
        userId: event.userId,
        userName: event.userName,
        userPhotoUrl: event.userPhotoUrl,
        streakDays: event.streakDays,
      );

      emit(const SocialActivityOperationSuccess('Streak activity created!'));
    } catch (e) {
      emit(SocialActivityError(
          'Failed to create streak activity: ${e.toString()}'));
    }
  }
}
