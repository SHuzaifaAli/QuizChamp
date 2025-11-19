import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/quiz/quiz_bloc.dart';
import '../blocs/quiz/quiz_event.dart';
import '../blocs/quiz/quiz_state.dart';
import '../widgets/question_card.dart';
import '../widgets/timer_widget.dart';
import '../widgets/feedback_overlay.dart';
import '../widgets/quiz_progress_bar.dart';
import '../widgets/quiz_results_card.dart';

class QuizScreen extends StatelessWidget {
  final int questionCount;
  final String? category;
  final String? difficulty;

  const QuizScreen({
    Key? key,
    required this.questionCount,
    this.category,
    this.difficulty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showAbandonDialog(context),
        ),
      ),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizError) {
            _showErrorDialog(context, state);
          } else if (state is QuizAbandoned) {
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, QuizState state) {
    if (state is QuizInitial) {
      return _buildInitialState(context);
    } else if (state is QuizLoading) {
      return _buildLoadingState();
    } else if (state is QuestionDisplayed) {
      return _buildQuestionState(context, state);
    } else if (state is QuestionAnswered) {
      return _buildAnsweredState(context, state);
    } else if (state is QuestionTimeout) {
      return _buildTimeoutState(context, state);
    } else if (state is AnimationPlaying) {
      return _buildAnimationState(context, state);
    } else if (state is QuizCompleted) {
      return _buildCompletedState(context, state);
    } else if (state is QuizError) {
      return _buildErrorState(context, state);
    } else {
      return _buildInitialState(context);
    }
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.quiz,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'Ready to start?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '$questionCount questions',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (category != null) ...[
            const SizedBox(height: 8),
            Text(
              'Category: $category',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (difficulty != null) ...[
            const SizedBox(height: 8),
            Text(
              'Difficulty: ${difficulty!.toUpperCase()}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _startQuiz(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Start Quiz'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading questions...'),
        ],
      ),
    );
  }

  Widget _buildQuestionState(BuildContext context, QuestionDisplayed state) {
    return Column(
      children: [
        // Progress bar
        QuizProgressBar(
          currentQuestion: state.questionNumber,
          totalQuestions: state.totalQuestions,
        ),
        const SizedBox(height: 16),
        
        // Timer
        TimerWidget(
          remainingTime: state.remainingTime,
          totalTime: 30,
        ),
        const SizedBox(height: 24),
        
        // Question card
        Expanded(
          child: QuestionCard(
            question: state.currentQuestion,
            onAnswerSelected: (answerIndex) => _onAnswerSelected(context, answerIndex),
            isInteractionEnabled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAnsweredState(BuildContext context, QuestionAnswered state) {
    return Column(
      children: [
        QuizProgressBar(
          currentQuestion: state.session.currentQuestionIndex,
          totalQuestions: state.session.questions.length,
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: QuestionCard(
            question: state.question,
            selectedAnswerIndex: state.selectedAnswerIndex,
            showCorrectAnswer: true,
            isInteractionEnabled: false,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeoutState(BuildContext context, QuestionTimeout state) {
    return Column(
      children: [
        QuizProgressBar(
          currentQuestion: state.session.currentQuestionIndex,
          totalQuestions: state.session.questions.length,
        ),
        const SizedBox(height: 16),
        
        Expanded(
          child: QuestionCard(
            question: state.question,
            showCorrectAnswer: true,
            isInteractionEnabled: false,
            isTimeout: true,
          ),
        ),
      ],
    );
  }

  Widget _buildAnimationState(BuildContext context, AnimationPlaying state) {
    return Stack(
      children: [
        // Background content (previous state)
        if (state.isTimeout)
          _buildTimeoutState(context, QuestionTimeout(
            session: state.session,
            question: state.session.currentQuestion!,
            correctAnswer: state.session.currentQuestion!.correctAnswer,
          ))
        else
          Column(
            children: [
              QuizProgressBar(
                currentQuestion: state.session.currentQuestionIndex,
                totalQuestions: state.session.questions.length,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: QuestionCard(
                  question: state.session.currentQuestion!,
                  showCorrectAnswer: true,
                  isInteractionEnabled: false,
                ),
              ),
            ],
          ),
        
        // Feedback overlay
        FeedbackOverlay(
          isCorrect: state.isCorrect,
          isTimeout: state.isTimeout,
          message: state.message,
        ),
      ],
    );
  }

  Widget _buildCompletedState(BuildContext context, QuizCompleted state) {
    return QuizResultsCard(
      session: state.session,
      correctAnswers: state.correctAnswers,
      totalQuestions: state.totalQuestions,
      accuracyPercentage: state.accuracyPercentage,
      totalTime: state.totalTime,
      onPlayAgain: () => _playAgain(context),
      onGoHome: () => Navigator.of(context).pop(),
    );
  }

  Widget _buildErrorState(BuildContext context, QuizError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Oops!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (state.canRetry) ...[
              ElevatedButton(
                onPressed: () => _retryQuiz(context),
                child: const Text('Try Again'),
              ),
              const SizedBox(height: 16),
            ],
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context) {
    context.read<QuizBloc>().add(StartQuizEvent(
      questionCount: questionCount,
      category: category,
      difficulty: difficulty,
    ));
  }

  void _onAnswerSelected(BuildContext context, int answerIndex) {
    context.read<QuizBloc>().add(AnswerSelectedEvent(
      answerIndex: answerIndex,
      timeToAnswer: const Duration(seconds: 5), // This should be calculated properly
    ));
  }

  void _retryQuiz(BuildContext context) {
    context.read<QuizBloc>().add(const RetryQuizEvent());
  }

  void _playAgain(BuildContext context) {
    context.read<QuizBloc>().add(const ResetQuizEvent());
  }

  void _showAbandonDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Abandon Quiz?'),
          content: const Text('Are you sure you want to abandon this quiz? Your progress will be lost.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<QuizBloc>().add(const AbandonQuizEvent());
              },
              child: const Text('Abandon'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, QuizError state) {
    if (state.errorCode == 'insufficient_hearts') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Not Enough Hearts'),
            content: Text(state.message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}