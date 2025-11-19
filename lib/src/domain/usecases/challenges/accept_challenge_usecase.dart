import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/challenges_repository.dart';

class AcceptChallengeUseCase {
  final ChallengesRepository _repository;

  AcceptChallengeUseCase(this._repository);

  Future<Either<Failure, void>> call(String challengeId) async {
    try {
      await _repository.acceptChallenge(challengeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
