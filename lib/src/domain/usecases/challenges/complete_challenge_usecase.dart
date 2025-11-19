import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/challenges_repository.dart';

class CompleteChallengeUseCase {
  final ChallengesRepository _repository;

  CompleteChallengeUseCase(this._repository);

  Future<Either<Failure, void>> call(CompleteChallengeParams params) async {
    try {
      await _repository.completeChallenge(
        challengeId: params.challengeId,
        challengerScore: params.challengerScore,
        challengedScore: params.challengedScore,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
