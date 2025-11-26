import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/question_entity.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../../core/error/failures.dart';
import '../datasources/challenges_remote_datasource.dart';

class ChallengesRepositoryImpl implements ChallengesRepository {
  final ChallengesRemoteDataSource _remoteDataSource;

  ChallengesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Challenge>> createChallenge(CreateChallengeParams params) async {
    try {
      final challenge = Challenge(
        id: _generateChallengeId(),
        challengerId: params.challengerId,
        challengedId: params.challengedId,
        challengerName: '',  // These need to be fetched from user service
        challengedName: '',  // These need to be fetched from user service
        challengerPhotoUrl: null,
        challengedPhotoUrl: null,
        category: params.category,
        difficulty: params.difficulty,
        questions: params.questions,
        status: ChallengeStatus.pending,
        createdAt: DateTime.now(),
        expiresAt: null,
        message: params.message,
      );
      
      await _remoteDataSource.createChallenge(challenge);
      return Right(challenge);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptChallenge(String challengeId, String userId) async {
    try {
      await _remoteDataSource.updateChallengeStatus(challengeId, ChallengeStatus.accepted);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> declineChallenge(String challengeId, String userId) async {
    try {
      await _remoteDataSource.updateChallengeStatus(challengeId, ChallengeStatus.declined);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitChallengeResult(String challengeId, ChallengeResult result) async {
    try {
      await _remoteDataSource.updateChallengeResult(challengeId, result);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<List<Challenge>> getChallengesStream(String userId) {
    return _remoteDataSource.getUserChallenges(userId);
  }

  @override
  Future<Either<Failure, Challenge?>> getChallengeById(String challengeId) async {
    try {
      final challenge = await _remoteDataSource.getChallenge(challengeId);
      return Right(challenge);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Challenge>>> getChallengeHistory(String userId, {int limit = 20, String? lastChallengeId}) async {
    try {
      final challenges = await _remoteDataSource.getCompletedChallenges(userId);
      return Right(challenges.take(limit).toList());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChallengeResult(String challengeId, String userId) async {
    try {
      await _remoteDataSource.deleteChallenge(challengeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  String _generateChallengeId() {
    return FirebaseFirestore.instance.collection('challenges').doc().id;
  }
}
