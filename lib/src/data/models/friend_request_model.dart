import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/friend_request_entity.dart';

class FriendRequestModel extends FriendRequest {
  const FriendRequestModel({
    required super.id,
    required super.fromUserId,
    required super.toUserId,
    required super.fromUserName,
    required super.toUserName,
    super.fromUserPhotoUrl,
    super.toUserPhotoUrl,
    required super.message,
    required super.sentAt,
    super.respondedAt,
    required super.status,
  });

  factory FriendRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequestModel(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      fromUserName: data['fromUserName'] ?? '',
      toUserName: data['toUserName'] ?? '',
      fromUserPhotoUrl: data['fromUserPhotoUrl'],
      toUserPhotoUrl: data['toUserPhotoUrl'],
      message: data['message'] ?? '',
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate() 
          : null,
      status: FriendRequestStatus.values.firstWhere(
        (e) => e.toString() == 'FriendRequestStatus.${data['status']}',
        orElse: () => FriendRequestStatus.pending,
      ),
    );
  }

  factory FriendRequestModel.fromEntity(FriendRequest request) {
    return FriendRequestModel(
      id: request.id,
      fromUserId: request.fromUserId,
      toUserId: request.toUserId,
      fromUserName: request.fromUserName,
      toUserName: request.toUserName,
      fromUserPhotoUrl: request.fromUserPhotoUrl,
      toUserPhotoUrl: request.toUserPhotoUrl,
      message: request.message,
      sentAt: request.sentAt,
      respondedAt: request.respondedAt,
      status: request.status,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'fromUserName': fromUserName,
      'toUserName': toUserName,
      'fromUserPhotoUrl': fromUserPhotoUrl,
      'toUserPhotoUrl': toUserPhotoUrl,
      'message': message,
      'sentAt': Timestamp.fromDate(sentAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'status': status.toString().split('.').last,
    };
  }
}

class ContactModel extends Contact {
  const ContactModel({
    required super.id,
    required super.displayName,
    super.email,
    super.phoneNumber,
    super.photoUrl,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? '',
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      photoUrl: map['photoUrl'],
    );
  }

  factory ContactModel.fromEntity(Contact contact) {
    return ContactModel(
      id: contact.id,
      displayName: contact.displayName,
      email: contact.email,
      phoneNumber: contact.phoneNumber,
      photoUrl: contact.photoUrl,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
    };
  }
}