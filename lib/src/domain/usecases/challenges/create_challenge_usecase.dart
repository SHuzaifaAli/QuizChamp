import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/repositories/challenges_repository.dart';
import '../../../domain/entities/challenge_entity.dart';
import '../../../domain/entities/question_entity.dart';

class CreateChallengeUseCase {
  final ChallengesRepository _repository;

  CreateChallengeUseCase(this._repository);

  Future<Either<Failure, void>> call(CreateChallengeParams params) async {
    try {
      await _repository.createChallenge(params);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
