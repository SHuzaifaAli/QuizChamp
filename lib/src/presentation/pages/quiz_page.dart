import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_event.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_state.dart';
import 'package:quiz_champ/src/presentation/widgets/timer_widget.dart';
import 'package:quiz_champ/src/presentation/widgets/hearts_widget.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  void _showLottieAnimation(String type) {
    if (!mounted) return;
    
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
                    if (mounted) Navigator.of(context).pop();
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
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is QuestionDisplayed) {
            return _buildQuizContent(context, state);
          }
          return const Center(child: Text('Press start on the home screen.'));
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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                final isCorrect = question.shuffledAnswers.indexOf(answer) == question.correctAnswerIndex;
                if (isCorrect) {
                  _playSound('correct');
                  _showLottieAnimation('correct');
                } else {
                  _playSound('wrong');
                  _showLottieAnimation('wrong');
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
          content: Text(
            'You answered ${state.correctAnswers} out of ${state.totalQuestions} questions correctly.',
            style: const TextStyle(fontSize: 18),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Go Home'),
              onPressed: () {
                if (mounted) {
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
