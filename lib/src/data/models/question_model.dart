import 'dart:math';
import 'package:html/parser.dart' as html_parser;
import '../../domain/entities/question_entity.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.category,
    required super.difficulty,
    required super.questionText,
    required super.correctAnswer,
    required super.incorrectAnswers,
    required super.shuffledAnswers,
    required super.correctAnswerIndex,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Decode HTML entities in the text
    final questionText = _decodeHtmlEntities(json['question'] as String);
    final correctAnswer = _decodeHtmlEntities(json['correct_answer'] as String);
    final incorrectAnswers = (json['incorrect_answers'] as List<dynamic>)
        .map((answer) => _decodeHtmlEntities(answer as String))
        .toList();

    // Create shuffled answers with correct answer included
    final allAnswers = [correctAnswer, ...incorrectAnswers];
    final shuffledAnswers = List<String>.from(allAnswers);
    shuffledAnswers.shuffle(Random());

    // Find the index of the correct answer in the shuffled list
    final correctAnswerIndex = shuffledAnswers.indexOf(correctAnswer);

    return QuestionModel(
      id: _generateQuestionId(json),
      category: _decodeHtmlEntities(json['category'] as String),
      difficulty: json['difficulty'] as String,
      questionText: questionText,
      correctAnswer: correctAnswer,
      incorrectAnswers: incorrectAnswers,
      shuffledAnswers: shuffledAnswers,
      correctAnswerIndex: correctAnswerIndex,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'difficulty': difficulty,
      'question': questionText,
      'correct_answer': correctAnswer,
      'incorrect_answers': incorrectAnswers,
      'shuffled_answers': shuffledAnswers,
      'correct_answer_index': correctAnswerIndex,
    };
  }

  factory QuestionModel.fromEntity(Question question) {
    return QuestionModel(
      id: question.id,
      category: question.category,
      difficulty: question.difficulty,
      questionText: question.questionText,
      correctAnswer: question.correctAnswer,
      incorrectAnswers: question.incorrectAnswers,
      shuffledAnswers: question.shuffledAnswers,
      correctAnswerIndex: question.correctAnswerIndex,
    );
  }

  static String _decodeHtmlEntities(String text) {
    final document = html_parser.parse(text);
    return document.documentElement?.text ?? text;
  }

  static String _generateQuestionId(Map<String, dynamic> json) {
    // Generate a unique ID based on question content
    final content = '${json['question']}_${json['correct_answer']}_${json['difficulty']}';
    return content.hashCode.abs().toString();
  }

  /// Creates a new QuestionModel with reshuffled answers
  QuestionModel reshuffle() {
    final allAnswers = [correctAnswer, ...incorrectAnswers];
    final newShuffledAnswers = List<String>.from(allAnswers);
    newShuffledAnswers.shuffle(Random());
    
    final newCorrectAnswerIndex = newShuffledAnswers.indexOf(correctAnswer);

    return QuestionModel(
      id: id,
      category: category,
      difficulty: difficulty,
      questionText: questionText,
      correctAnswer: correctAnswer,
      incorrectAnswers: incorrectAnswers,
      shuffledAnswers: newShuffledAnswers,
      correctAnswerIndex: newCorrectAnswerIndex,
    );
  }
}