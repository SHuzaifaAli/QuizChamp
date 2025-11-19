import 'package:equatable/equatable.dart';

class UserAnswer extends Equatable {
  final String questionId;
  final int selectedAnswerIndex;
  final bool isCorrect;
  final Duration timeToAnswer;
  final DateTime answeredAt;

  const UserAnswer({
    required this.questionId,
    required this.selectedAnswerIndex,
    required this.isCorrect,
    required this.timeToAnswer,
    required this.answeredAt,
  });

  @override
  List<Object?> get props => [
        questionId,
        selectedAnswerIndex,
        isCorrect,
        timeToAnswer,
        answeredAt,
      ];
}