import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../datasources/challenges_remote_datasource.dart';

class ChallengesRepositoryImpl implements ChallengesRepository {
  final ChallengesRemoteDataSource _remoteDataSource;

  ChallengesRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createChallenge({
    required String challengerId,
    required String challengedId,
    required String challengerName,
    required String challengedName,
    String? challengerPhotoUrl,
    String? challengedPhotoUrl,
    required String category,
    required String difficulty,
    required List<QuestionEntity> questions,
    DateTime? expiresAt,
  }) async {
    final challenge = Challenge(
      id: _generateChallengeId(),
      challengerId: challengerId,
      challengedId: challengedId,
      challengerName: challengerName,
      challengedName: challengedName,
      challengerPhotoUrl: challengerPhotoUrl,
      challengedPhotoUrl: challengedPhotoUrl,
      category: category,
      difficulty: difficulty,
      questions: questions,
      status: ChallengeStatus.pending,
      createdAt: DateTime.now(),
      expiresAt: expiresAt ?? DateTime.now().add(const Duration(days: 7)),
    );

    await _remoteDataSource.createChallenge(challenge);
  }

  @override
  Future<Challenge?> getChallenge(String challengeId) async {
    return await _remoteDataSource.getChallenge(challengeId);
  }

  @override
  Stream<List<Challenge>> getUserChallenges(String userId) {
    return _remoteDataSource.getUserChallenges(userId);
  }

  @override
  Future<void> acceptChallenge(String challengeId) async {
    await _remoteDataSource.updateChallengeStatus(
      challengeId,
      ChallengeStatus.accepted,
    );
  }

  @override
  Future<void> declineChallenge(String challengeId) async {
    await _remoteDataSource.updateChallengeStatus(
      challengeId,
      ChallengeStatus.declined,
    );
  }

  @override
  Future<void> startChallenge(String challengeId) async {
    await _remoteDataSource.updateChallengeStatus(
      challengeId,
      ChallengeStatus.inProgress,
    );
  }

  @override
  Future<void> completeChallenge({
    required String challengeId,
    required int challengerScore,
    required int challengedScore,
  }) async {
    await _remoteDataSource.updateChallengeScores(
      challengeId,
      challengerScore,
      challengedScore,
    );
  }

  @override
  Future<void> cancelChallenge(String challengeId) async {
    await _remoteDataSource.updateChallengeStatus(
      challengeId,
      ChallengeStatus.cancelled,
    );
  }

  @override
  Future<List<Challenge>> getPendingChallenges(String userId) async {
    return await _remoteDataSource.getPendingChallenges(userId);
  }

  @override
  Future<List<Challenge>> getActiveChallenges(String userId) async {
    return await _remoteDataSource.getActiveChallenges(userId);
  }

  @override
  Future<List<Challenge>> getCompletedChallenges(String userId) async {
    return await _remoteDataSource.getCompletedChallenges(userId);
  }

  @override
  Stream<List<Challenge>> getChallengeUpdates(String challengeId) {
    return FirebaseFirestore.instance
        .collection('challenges')
        .doc(challengeId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) return <Challenge>[];
          final challenge = ChallengeModel.fromFirestore(snapshot);
          return [challenge];
        });
  }

  @override
  Future<bool> isChallengeExpired(String challengeId) async {
    final challenge = await getChallenge(challengeId);
    if (challenge == null) return true;
    
    return challenge.expiresAt?.isBefore(DateTime.now()) ?? false;
  }

  @override
  Future<void> deleteExpiredChallenges() async {
    final cutoffDate = DateTime.now();
    
    final snapshot = await FirebaseFirestore.instance
        .collection('challenges')
        .where('expiresAt', isLessThan: cutoffDate)
        .where('status', whereIn: [
          ChallengeStatus.pending.name,
          ChallengeStatus.accepted.name,
        ])
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'status': ChallengeStatus.expired.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  String _generateChallengeId() {
    return FirebaseFirestore.instance.collection('challenges').doc().id;
  }
}
