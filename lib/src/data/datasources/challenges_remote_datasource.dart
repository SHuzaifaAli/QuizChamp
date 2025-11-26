import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/repositories/challenges_repository.dart';
import '../models/challenge_model.dart';

class ChallengesRemoteDataSource {
  final FirebaseFirestore _firestore;

  ChallengesRemoteDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _challengesCollection =>
      _firestore.collection('challenges');

  Future<void> createChallenge(Challenge challenge) async {
    final challengeModel = ChallengeModel.fromEntity(challenge);

    await _challengesCollection.doc(challenge.id).set(challengeModel.toFirestore());
  }

  Future<Challenge?> getChallenge(String challengeId) async {
    final doc = await _challengesCollection.doc(challengeId).get();
    if (!doc.exists) return null;
    
    return ChallengeModel.fromFirestore(doc);
  }

  Stream<List<Challenge>> getUserChallenges(String userId) {
    return _challengesCollection
        .where(Filter.or(
          Filter('challengerId', isEqualTo: userId),
          Filter('challengedId', isEqualTo: userId),
        ))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChallengeModel.fromFirestore(doc))
            .toList());
  }

  Future<void> updateChallengeStatus(String challengeId, ChallengeStatus status) async {
    await _challengesCollection.doc(challengeId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateChallengeScores(
    String challengeId,
    int challengerScore,
    int challengedScore,
  ) async {
    await _challengesCollection.doc(challengeId).update({
      'challengerScore': challengerScore,
      'challengedScore': challengedScore,
      'completedAt': FieldValue.serverTimestamp(),
      'status': ChallengeStatus.completed.name,
    });
  }

  Future<void> deleteChallenge(String challengeId) async {
    await _challengesCollection.doc(challengeId).delete();
  }

  Future<void> updateChallengeResult(String challengeId, ChallengeResult result) async {
    await _challengesCollection.doc(challengeId).update({
      if (result.userId == 'challenger') 'challengerResult': result.toMap(),
      if (result.userId == 'challenged') 'challengedResult': result.toMap(),
      'status': ChallengeStatus.completed.name,
      'completedAt': Timestamp.fromDate(result.completedAt),
    });
  }

  Future<List<Challenge>> getPendingChallenges(String userId) async {
    final snapshot = await _challengesCollection
        .where('challengedId', isEqualTo: userId)
        .where('status', isEqualTo: ChallengeStatus.pending.name)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }

  Future<List<Challenge>> getActiveChallenges(String userId) async {
    final snapshot = await _challengesCollection
        .where(Filter.or(
          Filter('challengerId', isEqualTo: userId),
          Filter('challengedId', isEqualTo: userId),
        ))
        .where('status', whereIn: [
          ChallengeStatus.accepted.name,
          ChallengeStatus.active.name,
        ])
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }

  Future<List<Challenge>> getCompletedChallenges(String userId) async {
    final snapshot = await _challengesCollection
        .where(Filter.or(
          Filter('challengerId', isEqualTo: userId),
          Filter('challengedId', isEqualTo: userId),
        ))
        .where('status', isEqualTo: ChallengeStatus.completed.name)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => ChallengeModel.fromFirestore(doc))
        .toList();
  }
}
