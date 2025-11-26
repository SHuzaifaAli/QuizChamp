import '../../repositories/challenges_repository.dart';
import '../../../domain/entities/challenge_entity.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

class GetUserChallengesUseCase {
  final ChallengesRepository _repository;

  GetUserChallengesUseCase(this._repository);

  Stream<List<Challenge>> call(String userId) {
    return _repository.getChallengesStream(userId);
  }
}
