import 'package:equatable/equatable.dart';

enum FriendRequestStatus {
  pending,
  accepted,
  declined,
  expired,
}

class FriendRequest extends Equatable {
  final String id;
  final String fromUserId;
  final String toUserId;
  final String fromUserName;
  final String toUserName;
  final String? fromUserPhotoUrl;
  final String? toUserPhotoUrl;
  final String message;
  final DateTime sentAt;
  final DateTime? respondedAt;
  final FriendRequestStatus status;

  const FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.fromUserName,
    required this.toUserName,
    this.fromUserPhotoUrl,
    this.toUserPhotoUrl,
    required this.message,
    required this.sentAt,
    this.respondedAt,
    required this.status,
  });

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    String? fromUserName,
    String? toUserName,
    String? fromUserPhotoUrl,
    String? toUserPhotoUrl,
    String? message,
    DateTime? sentAt,
    DateTime? respondedAt,
    FriendRequestStatus? status,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserName: toUserName ?? this.toUserName,
      fromUserPhotoUrl: fromUserPhotoUrl ?? this.fromUserPhotoUrl,
      toUserPhotoUrl: toUserPhotoUrl ?? this.toUserPhotoUrl,
      message: message ?? this.message,
      sentAt: sentAt ?? this.sentAt,
      respondedAt: respondedAt ?? this.respondedAt,
      status: status ?? this.status,
    );
  }

  bool get isPending => status == FriendRequestStatus.pending;
  bool get isAccepted => status == FriendRequestStatus.accepted;
  bool get isDeclined => status == FriendRequestStatus.declined;
  bool get isExpired => status == FriendRequestStatus.expired;

  Duration get age => DateTime.now().difference(sentAt);
  
  bool get isOld => age.inDays > 7; // Consider requests older than 7 days as old

  @override
  List<Object?> get props => [
        id,
        fromUserId,
        toUserId,
        fromUserName,
        toUserName,
        fromUserPhotoUrl,
        toUserPhotoUrl,
        message,
        sentAt,
        respondedAt,
        status,
      ];
}

class Contact extends Equatable {
  final String id;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String? photoUrl;

  const Contact({
    required this.id,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        phoneNumber,
        photoUrl,
      ];
}