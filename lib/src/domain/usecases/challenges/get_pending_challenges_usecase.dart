import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/challenges_repository.dart';
import '../../../domain/entities/challenge_entity.dart';

class GetPendingChallengesUseCase {
  final ChallengesRepository _repository;

  GetPendingChallengesUseCase(this._repository);

  Future<Either<Failure, List<Challenge>>> call(String userId) async {
    try {
      final challenges = await _repository.getChallengeHistory(userId);
      return challenges;
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
