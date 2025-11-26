import 'package:equatable/equatable.dart';
import '../../../domain/entities/challenge_entity.dart';
import '../../../domain/entities/question_entity.dart';

abstract class ChallengesEvent extends Equatable {
  const ChallengesEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserChallenges extends ChallengesEvent {
  final String userId;

  const LoadUserChallenges(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateChallenge extends ChallengesEvent {
  final String challengerId;
  final String challengedId;
  final String challengerName;
  final String challengedName;
  final String? challengerPhotoUrl;
  final String? challengedPhotoUrl;
  final String category;
  final String difficulty;
  final List<Question> questions;
  final DateTime? expiresAt;
  final String? message;

  const CreateChallenge({
    required this.challengerId,
    required this.challengedId,
    required this.challengerName,
    required this.challengedName,
    this.challengerPhotoUrl,
    this.challengedPhotoUrl,
    required this.category,
    required this.difficulty,
    required this.questions,
    this.expiresAt,
    this.message,
  });

  @override
  List<Object?> get props => [
        challengerId,
        challengedId,
        challengerName,
        challengedName,
        challengerPhotoUrl,
        challengedPhotoUrl,
        category,
        difficulty,
        questions,
        expiresAt,
        message,
      ];
}

class AcceptChallenge extends ChallengesEvent {
  final String challengeId;
  final String userId;

  const AcceptChallenge(this.challengeId, this.userId);

  @override
  List<Object?> get props => [challengeId, userId];
}

class DeclineChallenge extends ChallengesEvent {
  final String challengeId;
  final String userId;

  const DeclineChallenge(this.challengeId, this.userId);

  @override
  List<Object?> get props => [challengeId, userId];
}

class StartChallenge extends ChallengesEvent {
  final String challengeId;

  const StartChallenge(this.challengeId);

  @override
  List<Object?> get props => [challengeId];
}

class CompleteChallenge extends ChallengesEvent {
  final String challengeId;
  final int challengerScore;
  final int challengedScore;

  const CompleteChallenge({
    required this.challengeId,
    required this.challengerScore,
    required this.challengedScore,
  });

  @override
  List<Object?> get props => [challengeId, challengerScore, challengedScore];
}

class CancelChallenge extends ChallengesEvent {
  final String challengeId;

  const CancelChallenge(this.challengeId);

  @override
  List<Object?> get props => [challengeId];
}

class LoadPendingChallenges extends ChallengesEvent {
  final String userId;

  const LoadPendingChallenges(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadActiveChallenges extends ChallengesEvent {
  final String userId;

  const LoadActiveChallenges(this.userId);

  @override
  List<Object?> get props => [userId];
}

class LoadCompletedChallenges extends ChallengesEvent {
  final String userId;

  const LoadCompletedChallenges(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RefreshChallenges extends ChallengesEvent {
  final String userId;

  const RefreshChallenges(this.userId);

  @override
  List<Object?> get props => [userId];
}
