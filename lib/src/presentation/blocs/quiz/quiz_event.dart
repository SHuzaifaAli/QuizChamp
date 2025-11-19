import 'package:equatable/equatable.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class StartQuizEvent extends QuizEvent {
  final int questionCount;
  final String? category;
  final String? difficulty;

  const StartQuizEvent({
    required this.questionCount,
    this.category,
    this.difficulty,
  });

  @override
  List<Object?> get props => [questionCount, category, difficulty];
}

class AnswerSelectedEvent extends QuizEvent {
  final int answerIndex;
  final Duration timeToAnswer;

  const AnswerSelectedEvent({
    required this.answerIndex,
    required this.timeToAnswer,
  });

  @override
  List<Object?> get props => [answerIndex, timeToAnswer];
}

class TimerExpiredEvent extends QuizEvent {
  const TimerExpiredEvent();
}

class AnimationCompletedEvent extends QuizEvent {
  const AnimationCompletedEvent();
}

class NextQuestionEvent extends QuizEvent {
  const NextQuestionEvent();
}

class RetryQuizEvent extends QuizEvent {
  const RetryQuizEvent();
}

class AbandonQuizEvent extends QuizEvent {
  const AbandonQuizEvent();
}

class ResetQuizEvent extends QuizEvent {
  const ResetQuizEvent();
}