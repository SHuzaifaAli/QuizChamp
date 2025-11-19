import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';
import '../../repositories/challenges_repository.dart';
import '../entities/challenge_entity.dart';

class GetUserChallengesUseCase {
  final ChallengesRepository _repository;

  GetUserChallengesUseCase(this._repository);

  Stream<List<Challenge>> call(String userId) {
    return _repository.getUserChallenges(userId);
  }
}
