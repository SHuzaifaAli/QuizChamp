import 'package:equatable/equatable.dart';
import '../../../domain/entities/quiz_session_entity.dart';
import '../../../domain/entities/question_entity.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {
  const QuizInitial();
}

class QuizLoading extends QuizState {
  const QuizLoading();
}

class QuestionDisplayed extends QuizState {
  final QuizSession session;
  final Question currentQuestion;
  final int questionNumber;
  final int totalQuestions;
  final int remainingTime;

  const QuestionDisplayed({
    required this.session,
    required this.currentQuestion,
    required this.questionNumber,
    required this.totalQuestions,
    required this.remainingTime,
  });

  QuestionDisplayed copyWith({
    QuizSession? session,
    Question? currentQuestion,
    int? questionNumber,
    int? totalQuestions,
    int? remainingTime,
  }) {
    return QuestionDisplayed(
      session: session ?? this.session,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      questionNumber: questionNumber ?? this.questionNumber,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }

  @override
  List<Object?> get props => [
        session,
        currentQuestion,
        questionNumber,
        totalQuestions,
        remainingTime,
      ];
}

class QuestionAnswered extends QuizState {
  final QuizSession session;
  final Question question;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final String correctAnswer;
  final Duration timeToAnswer;

  const QuestionAnswered({
    required this.session,
    required this.question,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.correctAnswer,
    required this.timeToAnswer,
  });

  @override
  List<Object?> get props => [
        session,
        question,
        selectedAnswerIndex,
        isCorrect,
        correctAnswer,
        timeToAnswer,
      ];
}

class QuestionTimeout extends QuizState {
  final QuizSession session;
  final Question question;
  final String correctAnswer;

  const QuestionTimeout({
    required this.session,
    required this.question,
    required this.correctAnswer,
  });

  @override
  List<Object?> get props => [session, question, correctAnswer];
}

class AnimationPlaying extends QuizState {
  final QuizSession session;
  final bool isCorrect;
  final bool isTimeout;
  final String message;

  const AnimationPlaying({
    required this.session,
    required this.isCorrect,
    this.isTimeout = false,
    required this.message,
  });

  @override
  List<Object?> get props => [session, isCorrect, isTimeout, message];
}

class QuizCompleted extends QuizState {
  final QuizSession session;
  final int correctAnswers;
  final int totalQuestions;
  final double accuracyPercentage;
  final Duration totalTime;
  final Map<String, dynamic> stats;

  const QuizCompleted({
    required this.session,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.accuracyPercentage,
    required this.totalTime,
    required this.stats,
  });

  @override
  List<Object?> get props => [
        session,
        correctAnswers,
        totalQuestions,
        accuracyPercentage,
        totalTime,
        stats,
      ];
}

class QuizError extends QuizState {
  final String message;
  final String? errorCode;
  final bool canRetry;

  const QuizError({
    required this.message,
    this.errorCode,
    this.canRetry = true,
  });

  @override
  List<Object?> get props => [message, errorCode, canRetry];
}

class QuizAbandoned extends QuizState {
  final QuizSession? session;
  final String reason;

  const QuizAbandoned({
    this.session,
    required this.reason,
  });

  @override
  List<Object?> get props => [session, reason];
}