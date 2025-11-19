import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import '../../../../../../lib/src/domain/usecases/social/create_quiz_completed_activity_usecase.dart';
import '../../../../../../lib/src/domain/repositories/social_activity_repository.dart';
import '../../../../../../lib/src/errors/failures.dart';

@GenerateMocks([SocialActivityRepository])
void main() {
  late CreateQuizCompletedActivityUseCase useCase;
  late MockSocialActivityRepository mockRepository;

  setUp(() {
    mockRepository = MockSocialActivityRepository();
    useCase = CreateQuizCompletedActivityUseCase(mockRepository);
  });

  group('CreateQuizCompletedActivityUseCase', () {
    const testUserId = 'user123';
    const testUserName = 'Alice';
    const testUserPhotoUrl = 'https://example.com/photo.jpg';
    const testScore = 85;
    const testTotalQuestions = 10;
    const testCategory = 'Science';
    final testTimeTaken = const Duration(minutes: 5);

    test('should create quiz completed activity successfully', () async {
      // Arrange
      when(mockRepository.createQuizCompletedActivity(
        userId: anyNamed('userId'),
        userName: anyNamed('userName'),
        userPhotoUrl: anyNamed('userPhotoUrl'),
        score: anyNamed('score'),
        totalQuestions: anyNamed('totalQuestions'),
        category: anyNamed('category'),
        timeTaken: anyNamed('timeTaken'),
      )).thenAnswer((_) async => const Right(null));

      final params = QuizCompletedActivityParams(
        userId: testUserId,
        userName: testUserName,
        userPhotoUrl: testUserPhotoUrl,
        score: testScore,
        totalQuestions: testTotalQuestions,
        category: testCategory,
        timeTaken: testTimeTaken,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.createQuizCompletedActivity(
        userId: testUserId,
        userName: testUserName,
        userPhotoUrl: testUserPhotoUrl,
        score: testScore,
        totalQuestions: testTotalQuestions,
        category: testCategory,
        timeTaken: testTimeTaken,
      )).called(1);
    });

    test('should return ServerFailure when repository fails', () async {
      // Arrange
      const testFailure = ServerFailure('Failed to create activity');
      when(mockRepository.createQuizCompletedActivity(
        userId: anyNamed('userId'),
        userName: anyNamed('userName'),
        score: anyNamed('score'),
        totalQuestions: anyNamed('totalQuestions'),
        category: anyNamed('category'),
        timeTaken: anyNamed('timeTaken'),
      )).thenAnswer((_) async => const Left(testFailure));

      final params = QuizCompletedActivityParams(
        userId: testUserId,
        userName: testUserName,
        score: testScore,
        totalQuestions: testTotalQuestions,
        category: testCategory,
        timeTaken: testTimeTaken,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Left(testFailure));
      verify(mockRepository.createQuizCompletedActivity(
        userId: testUserId,
        userName: testUserName,
        score: testScore,
        totalQuestions: testTotalQuestions,
        category: testCategory,
        timeTaken: testTimeTaken,
      )).called(1);
    });

    test('should handle null userPhotoUrl parameter', () async {
      // Arrange
      when(mockRepository.createQuizCompletedActivity(
        userId: anyNamed('userId'),
        userName: anyNamed('userName'),
        userPhotoUrl: anyNamed('userPhotoUrl'),
        score: anyNamed('score'),
        totalQuestions: anyNamed('totalQuestions'),
        category: anyNamed('category'),
        timeTaken: anyNamed('timeTaken'),
      )).thenAnswer((_) async => const Right(null));

      final params = QuizCompletedActivityParams(
        userId: testUserId,
        userName: testUserName,
        userPhotoUrl: null,
        score: testScore,
        totalQuestions: testTotalQuestions,
        category: testCategory,
        timeTaken: testTimeTaken,
      );

      // Act
      final result = await useCase(params);

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.createQuizCompletedActivity(
        userId: testUserId,
        userName: testUserName,
        userPhotoUrl: null,
        score: testScore,
        totalQuestions: testTotalQuestions,
        category: testCategory,
        timeTaken: testTimeTaken,
      )).called(1);
    });
  });
}
