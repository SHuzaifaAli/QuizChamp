import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/challenges_repository.dart';
import '../entities/challenge_entity.dart';

class GetPendingChallengesUseCase {
  final ChallengesRepository _repository;

  GetPendingChallengesUseCase(this._repository);

  Future<Either<Failure, List<Challenge>>> call(String userId) async {
    try {
      final challenges = await _repository.getPendingChallenges(userId);
      return Right(challenges);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
