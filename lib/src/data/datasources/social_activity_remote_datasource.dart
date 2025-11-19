import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/social_activity_entity.dart';
import '../../domain/repositories/social_activity_repository.dart';
import '../models/social_activity_model.dart';

class SocialActivityRemoteDataSource {
  final FirebaseFirestore _firestore;

  SocialActivityRemoteDataSource(this._firestore);

  CollectionReference<Map<String, dynamic>> get _activitiesCollection =>
      _firestore.collection('social_activities');

  Future<void> createActivity(SocialActivity activity) async {
    final activityModel = SocialActivityModel(
      id: activity.id,
      userId: activity.userId,
      userName: activity.userName,
      userPhotoUrl: activity.userPhotoUrl,
      type: activity.type,
      data: activity.data,
      timestamp: activity.timestamp,
      reactions: activity.reactions,
      isVisible: activity.isVisible,
      description: activity.description,
    );

    await _activitiesCollection.doc(activity.id).set(activityModel.toMap());
  }

  Future<SocialActivity?> getActivity(String activityId) async {
    final doc = await _activitiesCollection.doc(activityId).get();
    if (!doc.exists) return null;
    
    return SocialActivityModel.fromFirestore(doc);
  }

  Stream<List<SocialActivity>> getFriendsActivityFeed(List<String> friendIds) {
    if (friendIds.isEmpty) {
      return Stream.value([]);
    }

    return _activitiesCollection
        .where('userId', whereIn: friendIds)
        .where('isVisible', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialActivityModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<SocialActivity>> getUserActivityFeed(String userId) {
    return _activitiesCollection
        .where('userId', isEqualTo: userId)
        .where('isVisible', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SocialActivityModel.fromFirestore(doc))
            .toList());
  }

  Future<void> addReactionToActivity(
    String activityId,
    String userId,
    String reactionType,
  ) async {
    await _activitiesCollection.doc(activityId).update({
      'reactions.$userId': reactionType,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeReactionFromActivity(
    String activityId,
    String userId,
  ) async {
    await _activitiesCollection.doc(activityId).update({
      'reactions.$userId': FieldValue.delete(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateActivityVisibility(
    String activityId,
    bool isVisible,
  ) async {
    await _activitiesCollection.doc(activityId).update({
      'isVisible': isVisible,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<SocialActivity>> getRecentActivities(
    List<String> friendIds, {
    int limit = 20,
  }) async {
    if (friendIds.isEmpty) {
      return [];
    }

    final snapshot = await _activitiesCollection
        .where('userId', whereIn: friendIds)
        .where('isVisible', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SocialActivityModel.fromFirestore(doc))
        .toList();
  }

  Future<List<SocialActivity>> getActivitiesByType(
    List<String> friendIds,
    SocialActivityType type, {
    int limit = 10,
  }) async {
    if (friendIds.isEmpty) {
      return [];
    }

    final snapshot = await _activitiesCollection
        .where('userId', whereIn: friendIds)
        .where('type', isEqualTo: type.name)
        .where('isVisible', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SocialActivityModel.fromFirestore(doc))
        .toList();
  }

  Future<void> deleteActivity(String activityId) async {
    await _activitiesCollection.doc(activityId).delete();
  }

  Future<void> cleanupOldActivities({int daysOld = 90}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    final snapshot = await _activitiesCollection
        .where('timestamp', isLessThan: cutoffDate)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
