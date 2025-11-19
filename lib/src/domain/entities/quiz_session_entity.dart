import 'package:equatable/equatable.dart';
import 'question_entity.dart';
import 'user_answer_entity.dart';

enum QuizSessionStatus {
  active,
  completed,
  abandoned,
}

class QuizSession extends Equatable {
  final String id;
  final List<Question> questions;
  final int currentQuestionIndex;
  final List<UserAnswer> answers;
  final DateTime startTime;
  final int heartsConsumed;
  final QuizSessionStatus status;

  const QuizSession({
    required this.id,
    required this.questions,
    required this.currentQuestionIndex,
    required this.answers,
    required this.startTime,
    required this.heartsConsumed,
    required this.status,
  });

  QuizSession copyWith({
    String? id,
    List<Question>? questions,
    int? currentQuestionIndex,
    List<UserAnswer>? answers,
    DateTime? startTime,
    int? heartsConsumed,
    QuizSessionStatus? status,
  }) {
    return QuizSession(
      id: id ?? this.id,
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
      startTime: startTime ?? this.startTime,
      heartsConsumed: heartsConsumed ?? this.heartsConsumed,
      status: status ?? this.status,
    );
  }

  bool get isCompleted => currentQuestionIndex >= questions.length;
  
  Question? get currentQuestion => 
      currentQuestionIndex < questions.length ? questions[currentQuestionIndex] : null;

  int get correctAnswersCount => 
      answers.where((answer) => answer.isCorrect).length;

  double get accuracyPercentage => 
      answers.isEmpty ? 0.0 : (correctAnswersCount / answers.length) * 100;

  @override
  List<Object?> get props => [
        id,
        questions,
        currentQuestionIndex,
        answers,
        startTime,
        heartsConsumed,
        status,
      ];
}