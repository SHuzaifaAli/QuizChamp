import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/challenges_repository.dart';
import '../entities/challenge_entity.dart';

class GetChallengeUseCase {
  final ChallengesRepository _repository;

  GetChallengeUseCase(this._repository);

  Future<Either<Failure, Challenge?>> call(String challengeId) async {
    try {
      final challenge = await _repository.getChallenge(challengeId);
      return Right(challenge);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
