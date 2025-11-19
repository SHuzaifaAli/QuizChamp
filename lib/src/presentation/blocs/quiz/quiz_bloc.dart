import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/quiz_session_entity.dart';
import '../../../domain/entities/user_answer_entity.dart';
import '../../../domain/repositories/quiz_repository.dart';
import '../../../domain/repositories/audio_service.dart';
import '../../../domain/usecases/quiz/start_quiz_usecase.dart';
import '../../../domain/usecases/quiz/answer_question_usecase.dart';
import '../../../domain/usecases/quiz/question_timer_usecase.dart';
import '../../../core/error/failures.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final StartQuizUseCase startQuizUseCase;
  final AnswerQuestionUseCase answerQuestionUseCase;
  final QuestionTimerUseCase questionTimerUseCase;
  final QuizRepository quizRepository;
  final AudioService audioService;

  StreamSubscription<int>? _timerSubscription;
  QuizSession? _currentSession;
  DateTime? _questionStartTime;
  static const int _questionTimeLimit = 30;

  QuizBloc({
    required this.startQuizUseCase,
    required this.answerQuestionUseCase,
    required this.questionTimerUseCase,
    required this.quizRepository,
    required this.audioService,
  }) : super(const QuizInitial()) {
    on<StartQuizEvent>(_onStartQuiz);
    on<AnswerSelectedEvent>(_onAnswerSelected);
    on<TimerExpiredEvent>(_onTimerExpired);
    on<AnimationCompletedEvent>(_onAnimationCompleted);
    on<NextQuestionEvent>(_onNextQuestion);
    on<RetryQuizEvent>(_onRetryQuiz);
    on<AbandonQuizEvent>(_onAbandonQuiz);
    on<ResetQuizEvent>(_onResetQuiz);
  }

  Future<void> _onStartQuiz(StartQuizEvent event, Emitter<QuizState> emit) async {
    emit(const QuizLoading());

    final result = await startQuizUseCase(StartQuizParams(
      questionCount: event.questionCount,
      category: event.category,
      difficulty: event.difficulty,
    ));

    result.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (session) {
        _currentSession = session;
        _startQuestion(emit);
      },
    );
  }

  Future<void> _onAnswerSelected(AnswerSelectedEvent event, Emitter<QuizState> emit) async {
    if (_currentSession == null || _questionStartTime == null) return;

    // Stop the timer
    _timerSubscription?.cancel();

    final currentQuestion = _currentSession!.currentQuestion;
    if (currentQuestion == null) return;

    final isCorrect = event.answerIndex == currentQuestion.correctAnswerIndex;
    final timeToAnswer = DateTime.now().difference(_questionStartTime!);

    // Play audio feedback
    if (isCorrect) {
      await audioService.playCorrectSound();
    } else {
      await audioService.playIncorrectSound();
    }

    // Update session with answer
    final answerResult = await answerQuestionUseCase(AnswerQuestionParams(
      sessionId: _currentSession!.id,
      questionId: currentQuestion.id,
      selectedAnswerIndex: event.answerIndex,
      isCorrect: isCorrect,
      timeToAnswer: timeToAnswer,
    ));

    answerResult.fold(
      (failure) => emit(_mapFailureToErrorState(failure)),
      (updatedSession) {
        _currentSession = updatedSession;
        
        emit(QuestionAnswered(
          session: updatedSession,
          question: currentQuestion,
          selectedAnswerIndex: event.answerIndex,
          isCorrect: isCorrect,
          correctAnswer: currentQuestion.correctAnswer,
          timeToAnswer: timeToAnswer,
        ));

        // Show animation
        _showFeedbackAnimation(emit, isCorrect, false);
      },
    );
  }

  Future<void> _onTimerExpired(TimerExpiredEvent event, Emitter<QuizState> emit) async {
    if (_currentSession == null) return;

    final currentQuestion = _currentSession!.currentQuestion;
    if (currentQuestion == null) return;

    // Play timeout sound
    await audioService.playTimeoutSound();

    // Create timeout answer
    final timeoutAnswer = UserAnswer(
      questionId: currentQuestion.id,
      selectedAnswerIndex: -1, // -1 indicates timeout
      isCorrect: false,
      timeToAnswer: Duration(seconds: _questionTimeLimit),
      answeredAt: DateTime.now(),
    );

    // Update session
    final updatedAnswers = List<UserAnswer>.from(_currentSession!.answers)..add(timeoutAnswer);
    final updatedSession = _currentSession!.copyWith(
      answers: updatedAnswers,
      currentQuestionIndex: _currentSession!.currentQuestionIndex + 1,
    );
    _currentSession = updatedSession;

    emit(QuestionTimeout(
      session: updatedSession,
      question: currentQuestion,
      correctAnswer: currentQuestion.correctAnswer,
    ));

    // Show timeout animation
    _showFeedbackAnimation(emit, false, true);
  }

  Future<void> _onAnimationCompleted(AnimationCompletedEvent event, Emitter<QuizState> emit) async {
    if (_currentSession == null) return;

    if (_currentSession!.isCompleted) {
      // Quiz is complete
      await quizRepository.completeQuizSession(_currentSession!.id);
      
      final stats = (quizRepository as dynamic).getSessionStats(_currentSession!);
      final totalTime = _currentSession!.answers.fold<Duration>(
        Duration.zero,
        (total, answer) => total + answer.timeToAnswer,
      );

      emit(QuizCompleted(
        session: _currentSession!,
        correctAnswers: _currentSession!.correctAnswersCount,
        totalQuestions: _currentSession!.questions.length,
        accuracyPercentage: _currentSession!.accuracyPercentage,
        totalTime: totalTime,
        stats: stats,
      ));
    } else {
      // Move to next question
      _startQuestion(emit);
    }
  }

  Future<void> _onNextQuestion(NextQuestionEvent event, Emitter<QuizState> emit) async {
    if (_currentSession == null) return;

    if (_currentSession!.isCompleted) {
      add(const AnimationCompletedEvent());
    } else {
      _startQuestion(emit);
    }
  }

  Future<void> _onRetryQuiz(RetryQuizEvent event, Emitter<QuizState> emit) async {
    _cleanup();
    emit(const QuizInitial());
  }

  Future<void> _onAbandonQuiz(AbandonQuizEvent event, Emitter<QuizState> emit) async {
    if (_currentSession != null) {
      await (quizRepository as dynamic).abandonQuizSession(_currentSession!.id);
    }
    
    _cleanup();
    emit(QuizAbandoned(
      session: _currentSession,
      reason: 'User abandoned quiz',
    ));
  }

  Future<void> _onResetQuiz(ResetQuizEvent event, Emitter<QuizState> emit) async {
    _cleanup();
    emit(const QuizInitial());
  }

  void _startQuestion(Emitter<QuizState> emit) {
    if (_currentSession == null) return;

    final currentQuestion = _currentSession!.currentQuestion;
    if (currentQuestion == null) return;

    _questionStartTime = DateTime.now();

    // Start timer
    _startTimer();

    emit(QuestionDisplayed(
      session: _currentSession!,
      currentQuestion: currentQuestion,
      questionNumber: _currentSession!.currentQuestionIndex + 1,
      totalQuestions: _currentSession!.questions.length,
      remainingTime: _questionTimeLimit,
    ));
  }

  void _startTimer() {
    _timerSubscription?.cancel();
    
    questionTimerUseCase(const QuestionTimerParams(durationInSeconds: _questionTimeLimit))
        .then((result) {
      result.fold(
        (failure) {
          // Handle timer failure
        },
        (timerStream) {
          _timerSubscription = timerStream.listen(
            (remainingTime) {
              if (state is QuestionDisplayed) {
                final currentState = state as QuestionDisplayed;
                emit(currentState.copyWith(remainingTime: remainingTime));
              }
              
              if (remainingTime <= 0) {
                add(const TimerExpiredEvent());
              }
            },
            onError: (error) {
              // Handle timer error
            },
          );
        },
      );
    });
  }

  void _showFeedbackAnimation(Emitter<QuizState> emit, bool isCorrect, bool isTimeout) {
    String message;
    if (isTimeout) {
      message = 'Time\'s up!';
    } else if (isCorrect) {
      message = 'Correct!';
    } else {
      message = 'Incorrect!';
    }

    emit(AnimationPlaying(
      session: _currentSession!,
      isCorrect: isCorrect,
      isTimeout: isTimeout,
      message: message,
    ));

    // Auto-complete animation after 3 seconds
    Timer(const Duration(seconds: 3), () {
      add(const AnimationCompletedEvent());
    });
  }

  QuizError _mapFailureToErrorState(Failure failure) {
    if (failure is InsufficientHeartsFailure) {
      return QuizError(
        message: 'Not enough hearts to start quiz. You have ${failure.availableHearts} hearts.',
        errorCode: 'insufficient_hearts',
        canRetry: false,
      );
    } else if (failure is NetworkFailure) {
      return const QuizError(
        message: 'Network error. Please check your connection and try again.',
        errorCode: 'network_error',
        canRetry: true,
      );
    } else if (failure is ServerFailure) {
      return QuizError(
        message: failure.message,
        errorCode: 'server_error',
        canRetry: true,
      );
    } else {
      return const QuizError(
        message: 'An unexpected error occurred. Please try again.',
        errorCode: 'unknown_error',
        canRetry: true,
      );
    }
  }

  void _cleanup() {
    _timerSubscription?.cancel();
    _timerSubscription = null;
    _currentSession = null;
    _questionStartTime = null;
  }

  @override
  Future<void> close() {
    _cleanup();
    return super.close();
  }
}