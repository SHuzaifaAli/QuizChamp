import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/social_activity_entity.dart';

class SocialActivityModel extends SocialActivity {
  const SocialActivityModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userPhotoUrl,
    required super.type,
    required super.data,
    required super.timestamp,
    required super.reactions,
    required super.isVisible,
    required super.description,
  });

  factory SocialActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SocialActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userPhotoUrl: data['userPhotoUrl'],
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == 'ActivityType.${data['type']}',
        orElse: () => ActivityType.quizCompleted,
      ),
      data: Map<String, dynamic>.from(data['data'] ?? {}),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      reactions: (data['reactions'] as List<dynamic>?)
          ?.map((r) => ActivityReactionModel.fromMap(r as Map<String, dynamic>))
          .cast<ActivityReaction>()
          .toList() ?? [],
      isVisible: data['isVisible'] ?? true,
      description: data['description'] ?? '',
    );
  }

  factory SocialActivityModel.fromEntity(SocialActivity activity) {
    return SocialActivityModel(
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
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'type': type.toString().split('.').last,
      'data': data,
      'timestamp': Timestamp.fromDate(timestamp),
      'reactions': reactions.map((r) => ActivityReactionModel.fromEntity(r).toMap()).toList(),
      'isVisible': isVisible,
      'description': description,
    };
  }
}

class ActivityReactionModel extends ActivityReaction {
  const ActivityReactionModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.type,
    required super.timestamp,
  });

  factory ActivityReactionModel.fromMap(Map<String, dynamic> map) {
    return ActivityReactionModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      type: ReactionType.values.firstWhere(
        (e) => e.toString() == 'ReactionType.${map['type']}',
        orElse: () => ReactionType.like,
      ),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  factory ActivityReactionModel.fromEntity(ActivityReaction reaction) {
    return ActivityReactionModel(
      id: reaction.id,
      userId: reaction.userId,
      userName: reaction.userName,
      type: reaction.type,
      timestamp: reaction.timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
