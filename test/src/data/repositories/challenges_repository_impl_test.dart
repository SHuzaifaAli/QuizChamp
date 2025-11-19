import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../../lib/src/data/repositories/challenges_repository_impl.dart';
import '../../../../../lib/src/data/datasources/challenges_remote_datasource.dart';
import '../../../../../lib/src/domain/entities/challenge_entity.dart';
import '../../../../../lib/src/domain/repositories/challenges_repository.dart';
import '../../../../../lib/src/errors/failures.dart';

// Generate mocks
@GenerateMocks([ChallengesRemoteDataSource])
import 'challenges_repository_impl_test.mocks.dart';

void main() {
  late ChallengesRepositoryImpl repository;
  late MockChallengesRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockChallengesRemoteDataSource();
    repository = ChallengesRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('ChallengesRepositoryImpl', () {
    const testChallengeId = 'challenge123';
    const testUserId = 'user123';
    const testChallengerId = 'user1';
    const testChallengedId = 'user2';
    const testChallengerName = 'Alice';
    const testChallengedName = 'Bob';
    const testCategory = 'Science';
    const testDifficulty = 'Medium';

    final testChallenge = Challenge(
      id: testChallengeId,
      challengerId: testChallengerId,
      challengedId: testChallengedId,
      challengerName: testChallengerName,
      challengedName: testChallengedName,
      category: testCategory,
      difficulty: testDifficulty,
      questions: [],
      status: ChallengeStatus.pending,
      createdAt: DateTime.now(),
    );

    test('should create challenge successfully', () async {
      // Arrange
      when(mockRemoteDataSource.createChallenge(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.createChallenge(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        category: testCategory,
        difficulty: testDifficulty,
        questions: [],
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.createChallenge(any())).called(1);
    });

    test('should return ServerFailure when create challenge fails', () async {
      // Arrange
      when(mockRemoteDataSource.createChallenge(any()))
          .thenThrow(Exception('Failed to create challenge'));

      // Act
      final result = await repository.createChallenge(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        category: testCategory,
        difficulty: testDifficulty,
        questions: [],
      );

      // Assert
      expect(result, isA<Left<Failure, void>>());
      verify(mockRemoteDataSource.createChallenge(any())).called(1);
    });

    test('should get challenge successfully', () async {
      // Arrange
      when(mockRemoteDataSource.getChallenge(testChallengeId))
          .thenAnswer((_) async => testChallenge);

      // Act
      final result = await repository.getChallenge(testChallengeId);

      // Assert
      expect(result, Right(testChallenge));
      verify(mockRemoteDataSource.getChallenge(testChallengeId)).called(1);
    });

    test('should return ServerFailure when get challenge fails', () async {
      // Arrange
      when(mockRemoteDataSource.getChallenge(testChallengeId))
          .thenThrow(Exception('Challenge not found'));

      // Act
      final result = await repository.getChallenge(testChallengeId);

      // Assert
      expect(result, isA<Left<Failure, Challenge>>());
      verify(mockRemoteDataSource.getChallenge(testChallengeId)).called(1);
    });

    test('should get user challenges stream successfully', () async {
      // Arrange
      final challenges = [testChallenge];
      when(mockRemoteDataSource.getUserChallenges(testUserId))
          .thenAnswer((_) => Stream.value(challenges));

      // Act
      final result = repository.getUserChallenges(testUserId);

      // Assert
      expect(result, isA<Stream<List<Challenge>>>());
      verify(mockRemoteDataSource.getUserChallenges(testUserId)).called(1);
    });

    test('should accept challenge successfully', () async {
      // Arrange
      when(mockRemoteDataSource.updateChallengeStatus(testChallengeId, 'accepted'))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.acceptChallenge(testChallengeId);

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.updateChallengeStatus(testChallengeId, 'accepted')).called(1);
    });

    test('should decline challenge successfully', () async {
      // Arrange
      when(mockRemoteDataSource.updateChallengeStatus(testChallengeId, 'declined'))
          .thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.declineChallenge(testChallengeId);

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.updateChallengeStatus(testChallengeId, 'declined')).called(1);
    });

    test('should complete challenge successfully', () async {
      // Arrange
      when(mockRemoteDataSource.completeChallenge(
        testChallengeId,
        80,
        75,
      )).thenAnswer((_) async => Future.value());

      // Act
      final result = await repository.completeChallenge(
        testChallengeId,
        80,
        75,
      );

      // Assert
      expect(result, const Right(null));
      verify(mockRemoteDataSource.completeChallenge(
        testChallengeId,
        80,
        75,
      )).called(1);
    });

    test('should get pending challenges successfully', () async {
      // Arrange
      final pendingChallenges = [testChallenge];
      when(mockRemoteDataSource.getPendingChallenges(testUserId))
          .thenAnswer((_) async => pendingChallenges);

      // Act
      final result = await repository.getPendingChallenges(testUserId);

      // Assert
      expect(result, Right(pendingChallenges));
      verify(mockRemoteDataSource.getPendingChallenges(testUserId)).called(1);
    });
  });
}
