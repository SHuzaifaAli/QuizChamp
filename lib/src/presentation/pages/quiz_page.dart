import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_champ/src/core/services/hearts_bloc_service.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_event.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_state.dart';
import 'package:quiz_champ/src/presentation/widgets/common/loading_widget.dart';
import 'package:quiz_champ/src/presentation/widgets/timer_widget.dart';
import 'package:quiz_champ/src/presentation/widgets/hearts_widget.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _isNavigating = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Ensure global HeartsBloc is loaded with latest data from Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HeartsBlocService.initialize();
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String type) async {
    try {
      if (type == 'correct') {
        await _audioPlayer.play(AssetSource('audio/correct.mp3'));
      } else if (type == 'wrong') {
        await _audioPlayer.play(AssetSource('audio/wrong.mp3'));
      }
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  void _showFeedbackAnimation(BuildContext context, String type) {
    if (_isNavigating) return; // Prevent multiple navigations

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                type == 'correct'
                    ? 'assets/lottie/correct_answer.json'
                    : 'assets/lottie/wrong_answer.json',
                width: 200,
                height: 200,
                repeat: false,
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    if (mounted && !_isNavigating) {
                      Navigator.of(context).pop();
                    }
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Quiz'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: HeartsWidget(showRegenerationTimer: false),
          ),
        ],
      ),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizCompleted) {
            _playSound('correct');
            _showQuizResult(context, state);
          } else if (state is QuizError) {
            _playSound('wrong');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
            if (mounted && !_isNavigating) {
              _isNavigating = true;
              Navigator.of(context).pop();
            }
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuestionDisplayed) {
            return _buildQuizContent(context, state);
          }
          return const Center(
              child: LoadingWidget(
            message: "Loading Please wait",
          ));
        },
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, QuestionDisplayed state) {
    final question = state.currentQuestion;
    final bloc = context.read<QuizBloc>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${state.questionNumber} of ${state.totalQuestions}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TimerWidget(
                remainingTime: state.remainingTime,
                totalTime: 30,
                onTimeUp: () {
                  bloc.add(const AnswerSelectedEvent(
                    answerIndex: -1, // Timeout
                    timeToAnswer: const Duration(seconds: 30),
                  ));
                },
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: state.questionNumber / state.totalQuestions,
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                question.questionText,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ...question.shuffledAnswers.map((answer) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () async {
                  final isCorrect = question.shuffledAnswers.indexOf(answer) ==
                      question.correctAnswerIndex;
                  if (isCorrect) {
                    _playSound('correct');
                    _showFeedbackAnimation(context, 'correct');
                  } else {
                    _playSound('wrong');
                    _showFeedbackAnimation(context, 'wrong');
                  }

                  if (mounted) {
                    bloc.add(AnswerSelectedEvent(
                      answerIndex: question.shuffledAnswers.indexOf(answer),
                      timeToAnswer: const Duration(seconds: 1),
                    ));
                  }
                },
                child: Text(answer, style: const TextStyle(fontSize: 16)),
              ),
            );
          }),
          const Spacer(),
        ],
      ),
    );
  }

  void _showQuizResult(BuildContext context, QuizCompleted state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Finished!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You answered ${state.correctAnswers} out of ${state.totalQuestions} questions correctly.',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Accuracy: ${state.accuracyPercentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '🏆 Points Earned: +${state.pointsEarned}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go Home'),
              onPressed: () {
                if (mounted && !_isNavigating) {
                  _isNavigating = true;
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close quiz page
                }
              },
            ),
          ],
        );
      },
    );
  }
}
