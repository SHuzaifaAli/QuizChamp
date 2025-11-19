import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/quiz_session_entity.dart';
import '../../domain/entities/user_answer_entity.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../../domain/repositories/question_repository.dart';
import '../../core/error/failures.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuestionRepository questionRepository;
  final Uuid _uuid = const Uuid();
  
  QuizSession? _currentSession;

  QuizRepositoryImpl({required this.questionRepository});

  @override
  Future<Either<Failure, QuizSession>> createQuizSession({
    required int questionCount,
    String? category,
    String? difficulty,
  }) async {
    try {
      // Fetch questions for the quiz
      final questionsResult = await questionRepository.fetchQuestions(
        amount: questionCount,
        category: category,
        difficulty: difficulty,
      );

      return questionsResult.fold(
        (failure) => Left(failure),
        (questions) {
          if (questions.isEmpty) {
            return Left(ServerFailure(message: 'No questions available'));
          }

          // Create new quiz session
          final session = QuizSession(
            id: _uuid.v4(),
            questions: questions,
            currentQuestionIndex: 0,
            answers: [],
            startTime: DateTime.now(),
            heartsConsumed: 1,
            status: QuizSessionStatus.active,
          );

          _currentSession = session;
          return Right(session);
        },
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to create quiz session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizSession>> updateQuizSession(QuizSession session) async {
    try {
      _currentSession = session;
      return Right(session);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update quiz session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizSession>> addAnswerToSession({
    required String sessionId,
    required UserAnswer answer,
  }) async {
    try {
      if (_currentSession == null || _currentSession!.id != sessionId) {
        return Left(ServerFailure(message: 'Quiz session not found'));
      }

      final updatedAnswers = List<UserAnswer>.from(_currentSession!.answers)
        ..add(answer);

      final updatedSession = _currentSession!.copyWith(
        answers: updatedAnswers,
        currentQuestionIndex: _currentSession!.currentQuestionIndex + 1,
      );

      _currentSession = updatedSession;
      return Right(updatedSession);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add answer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> completeQuizSession(String sessionId) async {
    try {
      if (_currentSession == null || _currentSession!.id != sessionId) {
        return Left(ServerFailure(message: 'Quiz session not found'));
      }

      final completedSession = _currentSession!.copyWith(
        status: QuizSessionStatus.completed,
      );

      _currentSession = completedSession;
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to complete quiz session: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, QuizSession?>> getCurrentSession() async {
    try {
      return Right(_currentSession);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current session: ${e.toString()}'));
    }
  }

  /// Abandon current quiz session
  Future<Either<Failure, void>> abandonQuizSession(String sessionId) async {
    try {
      if (_currentSession == null || _currentSession!.id != sessionId) {
        return Left(ServerFailure(message: 'Quiz session not found'));
      }

      final abandonedSession = _currentSession!.copyWith(
        status: QuizSessionStatus.abandoned,
      );

      _currentSession = abandonedSession;
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to abandon quiz session: ${e.toString()}'));
    }
  }

  /// Get quiz session statistics
  Map<String, dynamic> getSessionStats(QuizSession session) {
    final totalQuestions = session.questions.length;
    final answeredQuestions = session.answers.length;
    final correctAnswers = session.correctAnswersCount;
    final accuracy = session.accuracyPercentage;
    
    final totalTime = session.answers.fold<Duration>(
      Duration.zero,
      (total, answer) => total + answer.timeToAnswer,
    );
    
    final averageTimePerQuestion = answeredQuestions > 0
        ? Duration(milliseconds: totalTime.inMilliseconds ~/ answeredQuestions)
        : Duration.zero;

    return {
      'session_id': session.id,
      'total_questions': totalQuestions,
      'answered_questions': answeredQuestions,
      'correct_answers': correctAnswers,
      'accuracy_percentage': accuracy,
      'total_time_seconds': totalTime.inSeconds,
      'average_time_per_question_seconds': averageTimePerQuestion.inSeconds,
      'is_completed': session.isCompleted,
      'status': session.status.toString(),
      'hearts_consumed': session.heartsConsumed,
    };
  }

  /// Clear current session
  void clearCurrentSession() {
    _currentSession = null;
  }

  /// Check if there's an active session
  bool hasActiveSession() {
    return _currentSession != null && 
           _currentSession!.status == QuizSessionStatus.active;
  }
}