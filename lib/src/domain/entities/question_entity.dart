import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String category;
  final String difficulty;
  final String questionText;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final List<String> shuffledAnswers;
  final int correctAnswerIndex;

  const Question({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.questionText,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.shuffledAnswers,
    required this.correctAnswerIndex,
  });

  @override
  List<Object?> get props => [
        id,
        category,
        difficulty,
        questionText,
        correctAnswer,
        incorrectAnswers,
        shuffledAnswers,
        correctAnswerIndex,
      ];
}