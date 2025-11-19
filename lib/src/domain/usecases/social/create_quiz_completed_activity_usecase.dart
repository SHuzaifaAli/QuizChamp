import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/social_activity_repository.dart';

class CreateQuizCompletedActivityUseCase {
  final SocialActivityRepository _repository;

  CreateQuizCompletedActivityUseCase(this._repository);

  Future<Either<Failure, void>> call(QuizCompletedActivityParams params) async {
    try {
      await _repository.createQuizCompletedActivity(
        userId: params.userId,
        userName: params.userName,
        userPhotoUrl: params.userPhotoUrl,
        score: params.score,
        totalQuestions: params.totalQuestions,
        category: params.category,
        timeTaken: params.timeTaken,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
