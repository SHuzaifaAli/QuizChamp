import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/challenge_entity.dart';
import '../../domain/entities/question_entity.dart';
import 'question_model.dart';

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.challengerId,
    required super.challengedId,
    required super.challengerName,
    required super.challengedName,
    super.challengerPhotoUrl,
    super.challengedPhotoUrl,
    required super.category,
    required super.difficulty,
    required super.questions,
    required super.status,
    required super.createdAt,
    super.expiresAt,
    super.challengerResult,
    super.challengedResult,
    super.message,
  });

  factory ChallengeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChallengeModel(
      id: doc.id,
      challengerId: data['challengerId'] ?? '',
      challengedId: data['challengedId'] ?? '',
      challengerName: data['challengerName'] ?? '',
      challengedName: data['challengedName'] ?? '',
      challengerPhotoUrl: data['challengerPhotoUrl'],
      challengedPhotoUrl: data['challengedPhotoUrl'],
      category: data['category'] ?? '',
      difficulty: data['difficulty'] ?? '',
      questions: (data['questions'] as List<dynamic>?)
          ?.map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .cast<Question>()
          .toList() ?? [],
      status: ChallengeStatus.values.firstWhere(
        (e) => e.toString() == 'ChallengeStatus.${data['status']}',
        orElse: () => ChallengeStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null 
          ? (data['expiresAt'] as Timestamp).toDate() 
          : null,
      challengerResult: data['challengerResult'] != null
          ? ChallengeResultModel.fromMap(data['challengerResult'] as Map<String, dynamic>)
          : null,
      challengedResult: data['challengedResult'] != null
          ? ChallengeResultModel.fromMap(data['challengedResult'] as Map<String, dynamic>)
          : null,
      message: data['message'],
    );
  }

  factory ChallengeModel.fromEntity(Challenge challenge) {
    return ChallengeModel(
      id: challenge.id,
      challengerId: challenge.challengerId,
      challengedId: challenge.challengedId,
      challengerName: challenge.challengerName,
      challengedName: challenge.challengedName,
      challengerPhotoUrl: challenge.challengerPhotoUrl,
      challengedPhotoUrl: challenge.challengedPhotoUrl,
      category: challenge.category,
      difficulty: challenge.difficulty,
      questions: challenge.questions,
      status: challenge.status,
      createdAt: challenge.createdAt,
      expiresAt: challenge.expiresAt,
      challengerResult: challenge.challengerResult,
      challengedResult: challenge.challengedResult,
      message: challenge.message,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'challengerId': challengerId,
      'challengedId': challengedId,
      'challengerName': challengerName,
      'challengedName': challengedName,
      'challengerPhotoUrl': challengerPhotoUrl,
      'challengedPhotoUrl': challengedPhotoUrl,
      'category': category,
      'difficulty': difficulty,
      'questions': questions.map((q) => QuestionModel.fromEntity(q).toJson()).toList(),
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'challengerResult': challengerResult != null
          ? ChallengeResultModel.fromEntity(challengerResult!).toMap()
          : null,
      'challengedResult': challengedResult != null
          ? ChallengeResultModel.fromEntity(challengedResult!).toMap()
          : null,
      'message': message,
    };
  }
}

class ChallengeResultModel extends ChallengeResult {
  const ChallengeResultModel({
    required super.userId,
    required super.score,
    required super.correctAnswers,
    required super.totalQuestions,
    required super.accuracyPercentage,
    required super.timeToComplete,
    required super.completedAt,
    required super.answers,
  });

  factory ChallengeResultModel.fromMap(Map<String, dynamic> map) {
    return ChallengeResultModel(
      userId: map['userId'] ?? '',
      score: map['score'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      accuracyPercentage: (map['accuracyPercentage'] ?? 0.0).toDouble(),
      timeToComplete: Duration(milliseconds: map['timeToComplete'] ?? 0),
      completedAt: (map['completedAt'] as Timestamp).toDate(),
      answers: (map['answers'] as List<dynamic>?)
          ?.map((a) => ChallengeAnswerModel.fromMap(a as Map<String, dynamic>))
          .cast<ChallengeAnswer>()
          .toList() ?? [],
    );
  }

  factory ChallengeResultModel.fromEntity(ChallengeResult result) {
    return ChallengeResultModel(
      userId: result.userId,
      score: result.score,
      correctAnswers: result.correctAnswers,
      totalQuestions: result.totalQuestions,
      accuracyPercentage: result.accuracyPercentage,
      timeToComplete: result.timeToComplete,
      completedAt: result.completedAt,
      answers: result.answers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'score': score,
      'correctAnswers': correctAnswers,
      'totalQuestions': totalQuestions,
      'accuracyPercentage': accuracyPercentage,
      'timeToComplete': timeToComplete.inMilliseconds,
      'completedAt': Timestamp.fromDate(completedAt),
      'answers': answers.map((a) => ChallengeAnswerModel.fromEntity(a).toMap()).toList(),
    };
  }
}

class ChallengeAnswerModel extends ChallengeAnswer {
  const ChallengeAnswerModel({
    required super.questionId,
    required super.selectedAnswerIndex,
    required super.isCorrect,
    required super.timeToAnswer,
  });

  factory ChallengeAnswerModel.fromMap(Map<String, dynamic> map) {
    return ChallengeAnswerModel(
      questionId: map['questionId'] ?? '',
      selectedAnswerIndex: map['selectedAnswerIndex'] ?? -1,
      isCorrect: map['isCorrect'] ?? false,
      timeToAnswer: Duration(milliseconds: map['timeToAnswer'] ?? 0),
    );
  }

  factory ChallengeAnswerModel.fromEntity(ChallengeAnswer answer) {
    return ChallengeAnswerModel(
      questionId: answer.questionId,
      selectedAnswerIndex: answer.selectedAnswerIndex,
      isCorrect: answer.isCorrect,
      timeToAnswer: answer.timeToAnswer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedAnswerIndex': selectedAnswerIndex,
      'isCorrect': isCorrect,
      'timeToAnswer': timeToAnswer.inMilliseconds,
    };
  }
}