import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import '../../../../../../lib/src/domain/usecases/challenges/create_challenge_usecase.dart';
import '../../../../../../lib/src/domain/repositories/challenges_repository.dart';
import '../../../../../../lib/src/domain/entities/challenge_entity.dart';
import '../../../../../../lib/src/errors/failures.dart';

@GenerateMocks([ChallengesRepository])
void main() {
  late CreateChallengeUseCase useCase;
  late MockChallengesRepository mockRepository;

  setUp(() {
    mockRepository = MockChallengesRepository();
    useCase = CreateChallengeUseCase(mockRepository);
  });

  group('CreateChallengeUseCase', () {
    const testChallengerId = 'user1';
    const testChallengedId = 'user2';
    const testChallengerName = 'Alice';
    const testChallengedName = 'Bob';
    const testCategory = 'Science';
    const testDifficulty = 'Medium';
    const testChallengerPhotoUrl = 'https://example.com/alice.jpg';
    const testChallengedPhotoUrl = 'https://example.com/bob.jpg';
    final testQuestions = <QuestionEntity>[];
    final testExpiresAt = DateTime.now().add(const Duration(days: 7));

    test('should create challenge successfully', () async {
      // Arrange
      when(mockRepository.createChallenge(
        challengerId: anyNamed('challengerId'),
        challengedId: anyNamed('challengedId'),
        challengerName: anyNamed('challengerName'),
        challengedName: anyNamed('challengedName'),
        challengerPhotoUrl: anyNamed('challengerPhotoUrl'),
        challengedPhotoUrl: anyNamed('challengedPhotoUrl'),
        category: anyNamed('category'),
        difficulty: anyNamed('difficulty'),
        questions: anyNamed('questions'),
        expiresAt: anyNamed('expiresAt'),
      )).thenAnswer((_) async => const Right(null));

      final params = CreateChallengeParams(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        challengerPhotoUrl: testChallengerPhotoUrl,
        challengedPhotoUrl: testChallengedPhotoUrl,
        category: testCategory,
        difficulty: testDifficulty,
        questions: testQuestions,
        expiresAt: testExpiresAt,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.createChallenge(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        challengerPhotoUrl: testChallengerPhotoUrl,
        challengedPhotoUrl: testChallengedPhotoUrl,
        category: testCategory,
        difficulty: testDifficulty,
        questions: testQuestions,
        expiresAt: testExpiresAt,
      )).called(1);
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const testFailure = ServerFailure('Failed to create challenge');
      when(mockRepository.createChallenge(
        challengerId: anyNamed('challengerId'),
        challengedId: anyNamed('challengedId'),
        challengerName: anyNamed('challengerName'),
        challengedName: anyNamed('challengedName'),
        category: anyNamed('category'),
        difficulty: anyNamed('difficulty'),
        questions: anyNamed('questions'),
      )).thenAnswer((_) async => const Left(testFailure));

      final params = CreateChallengeParams(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        category: testCategory,
        difficulty: testDifficulty,
        questions: testQuestions,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Left(testFailure));
      verify(mockRepository.createChallenge(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        category: testCategory,
        difficulty: testDifficulty,
        questions: testQuestions,
      )).called(1);
    });

    test('should handle null optional parameters', () async {
      // Arrange
      when(mockRepository.createChallenge(
        challengerId: anyNamed('challengerId'),
        challengedId: anyNamed('challengedId'),
        challengerName: anyNamed('challengerName'),
        challengedName: anyNamed('challengedName'),
        category: anyNamed('category'),
        difficulty: anyNamed('difficulty'),
        questions: anyNamed('questions'),
      )).thenAnswer((_) async => const Right(null));

      final params = CreateChallengeParams(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        category: testCategory,
        difficulty: testDifficulty,
        questions: testQuestions,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.createChallenge(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        category: testCategory,
        difficulty: testDifficulty,
        questions: testQuestions,
      )).called(1);
    });
  });
}
