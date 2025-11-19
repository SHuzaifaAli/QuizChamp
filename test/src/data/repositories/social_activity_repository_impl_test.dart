import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import '../../../../../../lib/src/data/repositories/social_activity_repository_impl.dart';
import '../../../../../../lib/src/data/datasources/social_activity_remote_datasource.dart';
import '../../../../../../lib/src/domain/entities/social_activity_entity.dart';
import '../../../../../../lib/src/domain/repositories/social_activity_repository.dart';
import '../../../../../../lib/src/errors/failures.dart';

@GenerateMocks([SocialActivityRemoteDataSource])
void main() {
  late SocialActivityRepositoryImpl repository;
  late MockSocialActivityRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockSocialActivityRemoteDataSource();
    repository = SocialActivityRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('SocialActivityRepositoryImpl', () {
    const testUserId = 'user123';
    const testUserName = 'Alice';
    const testUserPhotoUrl = 'https://example.com/photo.jpg';
    const testCategory = 'Science';
    const testScore = 85;
    const testTotalQuestions = 10;
    final testTimeTaken = const Duration(minutes: 5);
    const testFriendIds = ['friend1', 'friend2'];

    final testActivity = SocialActivity(
      id: 'activity123',
      userId: testUserId,
      userName: testUserName,
      userPhotoUrl: testUserPhotoUrl,
      type: SocialActivityType.quizCompleted,
      data: {
        'score': testScore,
        'totalQuestions': testTotalQuestions,
        'accuracy': 0.85,
        'category': testCategory,
        'timeTaken': testTimeTaken.inSeconds,
      },
      timestamp: DateTime.now(),
      reactions: {'user1': 'like', 'user2': 'celebrate'},
      isVisible: true,
      description: 'Alice completed a Science quiz',
    );

    test('should get friends activity feed successfully', () async {
      // Arrange
      final activities = [testActivity];
      when(mockRemoteDataSource.getFriendsActivityFeed(testFriendIds))
          .thenAnswer((_) => Stream.value(activities));

      // Act
      final result = repository.getFriendsActivityFeed(testFriendIds);

      // Assert
      expect(result, isA<Stream<List<SocialActivity>>>());
      verify(mockRemoteDataSource.getFriendsActivityFeed(testFriendIds)).called(1);
    });

    test('should create quiz completed activity successfully', () async {
      // Arrange
      when(mockRemoteDataSource.createActivity(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.createQuizCompletedActivity(
        userId: testUserId,
        userName: testUserName,
        userPhotoUrl: testUserPhotoUrl,
        score: testScore,
        totalQuestions: testTotalQuestions,
        category: testCategory,
        timeTaken: testTimeTaken,
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.createActivity(any())).called(1);
    });

    test('should return ServerFailure when create activity fails', () async {
      // Arrange
      when(mockRemoteDataSource.createActivity(any()))
          .thenThrow(Exception('Failed to create activity'));

      // Act
      final result = await repository.createQuizCompletedActivity(
        userId: testUserId,
        userName: testUserName,
        score: testScore,
        totalQuestions: testTotalQuestions,
        category: testCategory,
        timeTaken: testTimeTaken,
      );

      // Assert
      expect(result, isA<Left<Failure, void>>());
      verify(mockRemoteDataSource.createActivity(any())).called(1);
    });

    test('should add reaction to activity successfully', () async {
      // Arrange
      const testActivityId = 'activity123';
      const testReactionUserId = 'user456';
      const testReactionType = ReactionType.like;

      when(mockRemoteDataSource.addReactionToActivity(
        testActivityId,
        testReactionUserId,
        testReactionType,
      )).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.addReactionToActivity(
        testActivityId,
        testReactionUserId,
        testReactionType,
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.addReactionToActivity(
        testActivityId,
        testReactionUserId,
        testReactionType,
      )).called(1);
    });

    test('should remove reaction from activity successfully', () async {
      // Arrange
      const testActivityId = 'activity123';
      const testReactionUserId = 'user456';

      when(mockRemoteDataSource.removeReactionFromActivity(
        testActivityId,
        testReactionUserId,
      )).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.removeReactionFromActivity(
        testActivityId,
        testReactionUserId,
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.removeReactionFromActivity(
        testActivityId,
        testReactionUserId,
      )).called(1);
    });

    test('should create achievement unlocked activity successfully', () async {
      // Arrange
      const testAchievementTitle = 'Quiz Master';
      const testAchievementDescription = 'Completed 100 quizzes';

      when(mockRemoteDataSource.createActivity(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.createAchievementUnlockedActivity(
        userId: testUserId,
        userName: testUserName,
        userPhotoUrl: testUserPhotoUrl,
        achievementTitle: testAchievementTitle,
        achievementDescription: testAchievementDescription,
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.createActivity(any())).called(1);
    });

    test('should create streak activity successfully', () async {
      // Arrange
      const testStreakDays = 7;

      when(mockRemoteDataSource.createActivity(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.createStreakActivity(
        userId: testUserId,
        userName: testUserName,
        userPhotoUrl: testUserPhotoUrl,
        streakDays: testStreakDays,
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.createActivity(any())).called(1);
    });

    test('should get recent activities successfully', () async {
      // Arrange
      final activities = [testActivity];
      const testLimit = 10;

      when(mockRemoteDataSource.getRecentActivities(testFriendIds, limit: testLimit))
          .thenAnswer((_) async => activities);

      // Act
      final result = await repository.getRecentActivities(testFriendIds, limit: testLimit);

      // Assert
      expect(result, Right(activities));
      verify(mockRemoteDataSource.getRecentActivities(testFriendIds, limit: testLimit)).called(1);
    });

    test('should get user activities successfully', () async {
      // Arrange
      final activities = [testActivity];
      const testLimit = 20;

      when(mockRemoteDataSource.getUserActivities(testUserId, limit: testLimit))
          .thenAnswer((_) async => activities);

      // Act
      final result = await repository.getUserActivities(testUserId, limit: testLimit);

      // Assert
      expect(result, Right(activities));
      verify(mockRemoteDataSource.getUserActivities(testUserId, limit: testLimit)).called(1);
    });

    test('should update activity visibility successfully', () async {
      // Arrange
      const testActivityId = 'activity123';
      const testIsVisible = false;

      when(mockRemoteDataSource.updateActivityVisibility(testActivityId, testIsVisible))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.updateActivityVisibility(testActivityId, testIsVisible);

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.updateActivityVisibility(testActivityId, testIsVisible)).called(1);
    });
  });
}
