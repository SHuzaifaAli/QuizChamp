import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_event.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_state.dart';

class QuizPage extends StatelessWidget {
  const QuizPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Active Quiz')),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizCompleted) {
            _showQuizResult(context, state);
          } else if (state is QuizError) {
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
          Text(
            'Question ${state.questionNumber} of ${state.totalQuestions}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          ...question.answers.map((answer) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(15),
                  alignment: Alignment.centerLeft,
                ),
                onPressed: () => bloc.add(AnswerSelectedEvent(
                  answerIndex: question.answers.indexOf(answer),
                  timeToAnswer: Duration(seconds: 1),
                )),
                child: Text(answer, style: const TextStyle(fontSize: 16)),
              ),
            );
          }).toList(),
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
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close quiz page
              },
            ),
          ],
        );
      },
    );
  }
}
