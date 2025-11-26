import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/challenges_repository.dart';
import '../../../domain/entities/challenge_entity.dart';

class GetChallengeUseCase {
  final ChallengesRepository _repository;

  GetChallengeUseCase(this._repository);

  Future<Either<Failure, Challenge?>> call(String challengeId) async {
    try {
      final challenge = await _repository.getChallengeById(challengeId);
      return challenge;
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
