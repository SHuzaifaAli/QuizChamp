import 'package:equatable/equatable.dart';
import '../../../domain/entities/challenge_entity.dart';

abstract class ChallengesState extends Equatable {
  const ChallengesState();

  @override
  List<Object?> get props => [];
}

class ChallengesInitial extends ChallengesState {
  const ChallengesInitial();
}

class ChallengesLoading extends ChallengesState {
  const ChallengesLoading();
}

class ChallengesLoaded extends ChallengesState {
  final List<Challenge> userChallenges;
  final List<Challenge> pendingChallenges;
  final List<Challenge> activeChallenges;
  final List<Challenge> completedChallenges;

  const ChallengesLoaded({
    required this.userChallenges,
    required this.pendingChallenges,
    required this.activeChallenges,
    required this.completedChallenges,
  });

  @override
  List<Object?> get props => [
        userChallenges,
        pendingChallenges,
        activeChallenges,
        completedChallenges,
      ];

  ChallengesLoaded copyWith({
    List<Challenge>? userChallenges,
    List<Challenge>? pendingChallenges,
    List<Challenge>? activeChallenges,
    List<Challenge>? completedChallenges,
  }) {
    return ChallengesLoaded(
      userChallenges: userChallenges ?? this.userChallenges,
      pendingChallenges: pendingChallenges ?? this.pendingChallenges,
      activeChallenges: activeChallenges ?? this.activeChallenges,
      completedChallenges: completedChallenges ?? this.completedChallenges,
    );
  }
}

class ChallengeOperationInProgress extends ChallengesState {
  final String operation;
  const ChallengesOperationInProgress(this.operation);

  @override
  List<Object?> get props => [operation];
}

class ChallengeOperationSuccess extends ChallengesState {
  final String message;
  const ChallengeOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ChallengesError extends ChallengesState {
  final String message;
  const ChallengesError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChallengeCreated extends ChallengesState {
  final Challenge challenge;
  const ChallengeCreated(this.challenge);

  @override
  List<Object?> get props => [challenge];
}

class ChallengeUpdated extends ChallengesState {
  final Challenge challenge;
  const ChallengeUpdated(this.challenge);

  @override
  List<Object?> get props => [challenge];
}

class ChallengeCompleted extends ChallengesState {
  final Challenge challenge;
  const ChallengeCompleted(this.challenge);

  @override
  List<Object?> get props => [challenge];
}

class ChallengeCancelled extends ChallengesState {
  final String challengeId;
  const ChallengeCancelled(this.challengeId);

  @override
  List<Object?> get props => [challengeId];
}
