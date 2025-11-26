import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/social_activity_repository.dart';

class CreateQuizCompletedActivityUseCase {
  final SocialActivityRepository _repository;

  CreateQuizCompletedActivityUseCase(this._repository);

  Future<Either<Failure, void>> call(Map<String, dynamic> activityData) async {
    try {
      await _repository.createQuizCompletedActivity(activityData);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class QuizCompletedActivityParams {
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int score;
  final int totalQuestions;
  final String category;
  final Duration timeTaken;

  QuizCompletedActivityParams({
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.score,
    required this.totalQuestions,
    required this.category,
    required this.timeTaken,
  });
}
