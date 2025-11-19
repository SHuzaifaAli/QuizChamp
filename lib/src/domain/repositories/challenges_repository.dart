import 'package:dartz/dartz.dart';
import '../entities/challenge_entity.dart';
import '../entities/question_entity.dart';
import '../../core/error/failures.dart';

abstract class ChallengesRepository {
  Future<Either<Failure, Challenge>> createChallenge(CreateChallengeParams params);
  Future<Either<Failure, void>> acceptChallenge(String challengeId, String userId);
  Future<Either<Failure, void>> declineChallenge(String challengeId, String userId);
  Future<Either<Failure, void>> submitChallengeResult(String challengeId, ChallengeResult result);
  Stream<List<Challenge>> getChallengesStream(String userId);
  Future<Either<Failure, Challenge?>> getChallengeById(String challengeId);
  Future<Either<Failure, List<Challenge>>> getChallengeHistory(String userId, {int limit = 20, String? lastChallengeId});
  Future<Either<Failure, void>> deleteChallengeResult(String challengeId, String userId);
}

class CreateChallengeParams {
  final String challengerId;
  final String challengedId;
  final String category;
  final String difficulty;
  final List<Question> questions;
  final String? message;

  CreateChallengeParams({
    required this.challengerId,
    required this.challengedId,
    required this.category,
    required this.difficulty,
    required this.questions,
    this.message,
  });
}