import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_event.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_state.dart';
import 'package:quiz_champ/src/domain/entities/quiz_session_entity.dart';
import 'package:quiz_champ/src/domain/entities/question_entity.dart';
import 'package:quiz_champ/src/domain/repositories/quiz_repository.dart';
import 'package:quiz_champ/src/domain/repositories/audio_service.dart';
import 'package:quiz_champ/src/domain/usecases/quiz/start_quiz_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/quiz/answer_question_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/quiz/question_timer_usecase.dart';
import 'package:quiz_champ/src/core/error/failures.dart';

import 'quiz_bloc_test.mocks.dart';

@GenerateMocks([
  StartQuizUseCase,
  AnswerQuestionUseCase,
  QuestionTimerUseCase,
  QuizRepository,
  AudioService,
])
void main() {
  group('QuizBloc', () {
    late QuizBloc quizBloc;
    late MockStartQuizUseCase mockStartQuizUseCase;
    late MockAnswerQuestionUseCase mockAnswerQuestionUseCase;
    late MockQuestionTimerUseCase mockQuestionTimerUseCase;
    late MockQuizRepository mockQuizRepository;
    late MockAudioService mockAudioService;

    setUp(() {
      mockStartQuizUseCase = MockStartQuizUseCase();
      mockAnswerQuestionUseCase = MockAnswerQuestionUseCase();
      mockQuestionTimerUseCase = MockQuestionTimerUseCase();
      mockQuizRepository = MockQuizRepository();
      mockAudioService = MockAudioService();

      quizBloc = QuizBloc(
        startQuizUseCase: mockStartQuizUseCase,
        answerQuestionUseCase: mockAnswerQuestionUseCase,
        questionTimerUseCase: mockQuestionTimerUseCase,
        quizRepository: mockQuizRepository,
        audioService: mockAudioService,
      );
    });

    tearDown(() {
      quizBloc.close();
    });

    test('initial state is QuizInitial', () {
      expect(quizBloc.state, const QuizInitial());
    });

    group('StartQuizEvent', () {
      final mockQuestion = Question(
        id: '1',
        category: 'General Knowledge',
        difficulty: 'easy',
        questionText: 'What is 2+2?',
        correctAnswer: '4',
        incorrectAnswers: ['3', '5', '6'],
        shuffledAnswers: ['3', '4', '5', '6'],
        correctAnswerIndex: 1,
      );

      final mockSession = QuizSession(
        id: 'session-1',
        questions: [mockQuestion],
        currentQuestionIndex: 0,
        answers: [],
        startTime: DateTime.now(),
        heartsConsumed: 1,
        status: QuizSessionStatus.active,
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuestionDisplayed] when quiz starts successfully',
        build: () {
          when(mockStartQuizUseCase(any)).thenAnswer((_) async => Right(mockSession));
          when(mockQuestionTimerUseCase(any)).thenAnswer(
            (_) async => Right(Stream.fromIterable([30, 29, 28])),
          );
          return quizBloc;
        },
        act: (bloc) => bloc.add(const StartQuizEvent(questionCount: 10)),
        expect: () => [
          const QuizLoading(),
          isA<QuestionDisplayed>(),
        ],
      );

      blocTest<QuizBloc, QuizState>(
        'emits [QuizLoading, QuizError] when start quiz fails',
        build: () {
          when(mockStartQuizUseCase(any)).thenAnswer(
            (_) async => Left(InsufficientHeartsFailure(availableHearts: 0)),
          );
          return quizBloc;
        },
        act: (bloc) => bloc.add(const StartQuizEvent(questionCount: 10)),
        expect: () => [
          const QuizLoading(),
          isA<QuizError>(),
        ],
      );
    });

    group('AnswerSelectedEvent', () {
      final mockQuestion = Question(
        id: '1',
        category: 'General Knowledge',
        difficulty: 'easy',
        questionText: 'What is 2+2?',
        correctAnswer: '4',
        incorrectAnswers: ['3', '5', '6'],
        shuffledAnswers: ['3', '4', '5', '6'],
        correctAnswerIndex: 1,
      );

      final mockSession = QuizSession(
        id: 'session-1',
        questions: [mockQuestion],
        currentQuestionIndex: 0,
        answers: [],
        startTime: DateTime.now(),
        heartsConsumed: 1,
        status: QuizSessionStatus.active,
      );

      blocTest<QuizBloc, QuizState>(
        'emits QuestionAnswered and AnimationPlaying when correct answer selected',
        build: () {
          when(mockAnswerQuestionUseCase(any)).thenAnswer((_) async => Right(mockSession));
          when(mockAudioService.playCorrectSound()).thenAnswer((_) async {});
          return quizBloc;
        },
        seed: () => QuestionDisplayed(
          session: mockSession,
          currentQuestion: mockQuestion,
          questionNumber: 1,
          totalQuestions: 1,
          remainingTime: 30,
        ),
        act: (bloc) => bloc.add(const AnswerSelectedEvent(
          answerIndex: 1, // Correct answer
          timeToAnswer: Duration(seconds: 5),
        )),
        expect: () => [
          isA<QuestionAnswered>(),
          isA<AnimationPlaying>(),
        ],
        verify: (_) {
          verify(mockAudioService.playCorrectSound()).called(1);
        },
      );

      blocTest<QuizBloc, QuizState>(
        'emits QuestionAnswered and AnimationPlaying when incorrect answer selected',
        build: () {
          when(mockAnswerQuestionUseCase(any)).thenAnswer((_) async => Right(mockSession));
          when(mockAudioService.playIncorrectSound()).thenAnswer((_) async {});
          return quizBloc;
        },
        seed: () => QuestionDisplayed(
          session: mockSession,
          currentQuestion: mockQuestion,
          questionNumber: 1,
          totalQuestions: 1,
          remainingTime: 30,
        ),
        act: (bloc) => bloc.add(const AnswerSelectedEvent(
          answerIndex: 0, // Incorrect answer
          timeToAnswer: Duration(seconds: 5),
        )),
        expect: () => [
          isA<QuestionAnswered>(),
          isA<AnimationPlaying>(),
        ],
        verify: (_) {
          verify(mockAudioService.playIncorrectSound()).called(1);
        },
      );
    });

    group('TimerExpiredEvent', () {
      final mockQuestion = Question(
        id: '1',
        category: 'General Knowledge',
        difficulty: 'easy',
        questionText: 'What is 2+2?',
        correctAnswer: '4',
        incorrectAnswers: ['3', '5', '6'],
        shuffledAnswers: ['3', '4', '5', '6'],
        correctAnswerIndex: 1,
      );

      final mockSession = QuizSession(
        id: 'session-1',
        questions: [mockQuestion],
        currentQuestionIndex: 0,
        answers: [],
        startTime: DateTime.now(),
        heartsConsumed: 1,
        status: QuizSessionStatus.active,
      );

      blocTest<QuizBloc, QuizState>(
        'emits QuestionTimeout and AnimationPlaying when timer expires',
        build: () {
          when(mockAudioService.playTimeoutSound()).thenAnswer((_) async {});
          return quizBloc;
        },
        seed: () => QuestionDisplayed(
          session: mockSession,
          currentQuestion: mockQuestion,
          questionNumber: 1,
          totalQuestions: 1,
          remainingTime: 0,
        ),
        act: (bloc) => bloc.add(const TimerExpiredEvent()),
        expect: () => [
          isA<QuestionTimeout>(),
          isA<AnimationPlaying>(),
        ],
        verify: (_) {
          verify(mockAudioService.playTimeoutSound()).called(1);
        },
      );
    });

    group('RetryQuizEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits QuizInitial when retry quiz event is added',
        build: () => quizBloc,
        act: (bloc) => bloc.add(const RetryQuizEvent()),
        expect: () => [const QuizInitial()],
      );
    });

    group('AbandonQuizEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits QuizAbandoned when abandon quiz event is added',
        build: () => quizBloc,
        act: (bloc) => bloc.add(const AbandonQuizEvent()),
        expect: () => [isA<QuizAbandoned>()],
      );
    });

    group('ResetQuizEvent', () {
      blocTest<QuizBloc, QuizState>(
        'emits QuizInitial when reset quiz event is added',
        build: () => quizBloc,
        act: (bloc) => bloc.add(const ResetQuizEvent()),
        expect: () => [const QuizInitial()],
      );
    });

    group('Error handling', () {
      blocTest<QuizBloc, QuizState>(
        'emits QuizError with network error message when network fails',
        build: () {
          when(mockStartQuizUseCase(any)).thenAnswer((_) async => Left(NetworkFailure()));
          return quizBloc;
        },
        act: (bloc) => bloc.add(const StartQuizEvent(questionCount: 10)),
        expect: () => [
          const QuizLoading(),
          const QuizError(
            message: 'Network error. Please check your connection and try again.',
            errorCode: 'network_error',
            canRetry: true,
          ),
        ],
      );

      blocTest<QuizBloc, QuizState>(
        'emits QuizError with server error message when server fails',
        build: () {
          when(mockStartQuizUseCase(any)).thenAnswer(
            (_) async => Left(ServerFailure(message: 'Server is down')),
          );
          return quizBloc;
        },
        act: (bloc) => bloc.add(const StartQuizEvent(questionCount: 10)),
        expect: () => [
          const QuizLoading(),
          const QuizError(
            message: 'Server is down',
            errorCode: 'server_error',
            canRetry: true,
          ),
        ],
      );
    });

    group('State transitions', () {
      test('should handle state transitions correctly', () {
        expect(quizBloc.state, isA<QuizInitial>());
      });

      test('should clean up resources when closed', () async {
        await quizBloc.close();
        // Verify cleanup was called (no direct way to test this without exposing internals)
        expect(quizBloc.isClosed, true);
      });
    });
  });
}