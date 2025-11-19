import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/challenges_repository.dart';
import '../entities/challenge_entity.dart';

class CreateChallengeUseCase {
  final ChallengesRepository _repository;

  CreateChallengeUseCase(this._repository);

  Future<Either<Failure, void>> call(CreateChallengeParams params) async {
    try {
      await _repository.createChallenge(
        challengerId: params.challengerId,
        challengedId: params.challengedId,
        challengerName: params.challengerName,
        challengedName: params.challengedName,
        challengerPhotoUrl: params.challengerPhotoUrl,
        challengedPhotoUrl: params.challengedPhotoUrl,
        category: params.category,
        difficulty: params.difficulty,
        questions: params.questions,
        expiresAt: params.expiresAt,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class CreateChallengeParams {
  final String challengerId;
  final String challengedId;
  final String challengerName;
  final String challengedName;
  final String? challengerPhotoUrl;
  final String? challengedPhotoUrl;
  final String category;
  final String difficulty;
  final List<QuestionEntity> questions;
  final DateTime? expiresAt;

  CreateChallengeParams({
    required this.challengerId,
    required this.challengedId,
    required this.challengerName,
    required this.challengedName,
    this.challengerPhotoUrl,
    this.challengedPhotoUrl,
    required this.category,
    required this.difficulty,
    required this.questions,
    this.expiresAt,
  });
}
