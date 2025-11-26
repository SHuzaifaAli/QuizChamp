import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/challenges_repository.dart';
import '../../../domain/entities/challenge_entity.dart';

class CompleteChallengeUseCase {
  final ChallengesRepository _repository;

  CompleteChallengeUseCase(this._repository);

  Future<Either<Failure, void>> call(String challengeId, ChallengeResult result) async {
    try {
      await _repository.submitChallengeResult(challengeId, result);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}

class CompleteChallengeParams {
  final String challengeId;
  final int challengerScore;
  final int challengedScore;

  CompleteChallengeParams({
    required this.challengeId,
    required this.challengerScore,
    required this.challengedScore,
  });
}
