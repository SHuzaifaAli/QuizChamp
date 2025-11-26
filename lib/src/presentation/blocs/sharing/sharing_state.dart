import 'package:equatable/equatable.dart';

abstract class SharingState extends Equatable {
  const SharingState();

  @override
  List<Object?> get props => [];
}

class SharingInitial extends SharingState {
  const SharingInitial();
}

class SharingLoading extends SharingState {
  const SharingLoading();
}

class SharingLoaded extends SharingState {
  final String shareableLink;
  final String inviteCode;
  final int invitesSent;
  final int friendsJoined;
  final bool isSharing;

  const SharingLoaded({
    required this.shareableLink,
    required this.inviteCode,
    required this.invitesSent,
    required this.friendsJoined,
    this.isSharing = false,
  });

  SharingLoaded copyWith({
    String? shareableLink,
    String? inviteCode,
    int? invitesSent,
    int? friendsJoined,
    bool? isSharing,
  }) {
    return SharingLoaded(
      shareableLink: shareableLink ?? this.shareableLink,
      inviteCode: inviteCode ?? this.inviteCode,
      invitesSent: invitesSent ?? this.invitesSent,
      friendsJoined: friendsJoined ?? this.friendsJoined,
      isSharing: isSharing ?? this.isSharing,
    );
  }

  @override
  List<Object?> get props => [
        shareableLink,
        inviteCode,
        invitesSent,
        friendsJoined,
        isSharing,
      ];
}

class SharingError extends SharingState {
  final String message;

  const SharingError({required this.message});

  @override
  List<Object?> get props => [message];
}
