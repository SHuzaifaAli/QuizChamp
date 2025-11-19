import 'package:equatable/equatable.dart';
import 'question_entity.dart';

enum ChallengeStatus {
  pending,
  accepted,
  declined,
  active,
  completed,
  expired,
}

class Challenge extends Equatable {
  final String id;
  final String challengerId;
  final String challengedId;
  final String challengerName;
  final String challengedName;
  final String? challengerPhotoUrl;
  final String? challengedPhotoUrl;
  final String category;
  final String difficulty;
  final List<Question> questions;
  final ChallengeStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final ChallengeResult? challengerResult;
  final ChallengeResult? challengedResult;
  final String? message;

  const Challenge({
    required this.id,
    required this.challengerId,
    required this.challengedId,
    required this.challengerName,
    required this.challengedName,
    this.challengerPhotoUrl,
    this.challengedPhotoUrl,
    required this.category,
    required this.difficulty,
    required this.questions,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.challengerResult,
    this.challengedResult,
    this.message,
  });

  Challenge copyWith({
    String? id,
    String? challengerId,
    String? challengedId,
    String? challengerName,
    String? challengedName,
    String? challengerPhotoUrl,
    String? challengedPhotoUrl,
    String? category,
    String? difficulty,
    List<Question>? questions,
    ChallengeStatus? status,
    DateTime? createdAt,
    DateTime? expiresAt,
    ChallengeResult? challengerResult,
    ChallengeResult? challengedResult,
    String? message,
  }) {
    return Challenge(
      id: id ?? this.id,
      challengerId: challengerId ?? this.challengerId,
      challengedId: challengedId ?? this.challengedId,
      challengerName: challengerName ?? this.challengerName,
      challengedName: challengedName ?? this.challengedName,
      challengerPhotoUrl: challengerPhotoUrl ?? this.challengerPhotoUrl,
      challengedPhotoUrl: challengedPhotoUrl ?? this.challengedPhotoUrl,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      challengerResult: challengerResult ?? this.challengerResult,
      challengedResult: challengedResult ?? this.challengedResult,
      message: message ?? this.message,
    );
  }

  bool get isCompleted => 
      challengerResult != null && challengedResult != null;

  bool get hasWinner => isCompleted && 
      challengerResult!.score != challengedResult!.score;

  String? get winnerId {
    if (!hasWinner) return null;
    return challengerResult!.score > challengedResult!.score 
        ? challengerId 
        : challengedId;
  }

  String? get winnerName {
    if (!hasWinner) return null;
    return challengerResult!.score > challengedResult!.score 
        ? challengerName 
        : challengedName;
  }

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  List<Object?> get props => [
        id,
        challengerId,
        challengedId,
        challengerName,
        challengedName,
        challengerPhotoUrl,
        challengedPhotoUrl,
        category,
        difficulty,
        questions,
        status,
        createdAt,
        expiresAt,
        challengerResult,
        challengedResult,
        message,
      ];
}

class ChallengeResult extends Equatable {
  final String userId;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracyPercentage;
  final Duration timeToComplete;
  final DateTime completedAt;
  final List<ChallengeAnswer> answers;

  const ChallengeResult({
    required this.userId,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracyPercentage,
    required this.timeToComplete,
    required this.completedAt,
    required this.answers,
  });

  @override
  List<Object?> get props => [
        userId,
        score,
        correctAnswers,
        totalQuestions,
        accuracyPercentage,
        timeToComplete,
        completedAt,
        answers,
      ];
}

class ChallengeAnswer extends Equatable {
  final String questionId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final Duration timeToAnswer;

  const ChallengeAnswer({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.timeToAnswer,
  });

  @override
  List<Object?> get props => [
        questionId,
        selectedAnswerIndex,
        isCorrect,
        timeToAnswer,
      ];
}