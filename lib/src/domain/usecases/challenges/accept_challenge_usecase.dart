import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/challenges_repository.dart';

class AcceptChallengeUseCase {
  final ChallengesRepository _repository;

  AcceptChallengeUseCase(this._repository);

  Future<Either<Failure, void>> call(String challengeId, String userId) async {
    try {
      await _repository.acceptChallenge(challengeId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
