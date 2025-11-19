import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_champ/src/core/di/injection_container.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';
import 'package:quiz_champ/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_bloc.dart';
import 'package:quiz_champ/src/presentation/pages/quiz_page.dart';
import 'package:quiz_champ/src/presentation/pages/sign_in_page.dart';

class HomePage extends StatelessWidget {
  final UserEntity user;
  const HomePage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuizChamp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user.displayName),
              accountEmail: Text(user.email),
              currentAccountPicture: CircleAvatar(
                backgroundImage: user.photoUrl != null
                    ? NetworkImage(user.photoUrl!)
                    : null,
                child: user.photoUrl == null ? const Icon(Icons.person) : null,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Start New Quiz'),
              onTap: () {
                Navigator.pop(context);
                _startQuiz(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Leaderboards'),
              onTap: () {
                // Navigate to Leaderboards Page
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Navigate to Settings Page
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const SignInPage()),
              (Route<dynamic> route) => false,
            );
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome back, ${user.displayName}!', style: const TextStyle(fontSize: 24)),
              Text('Hearts: ${user.hearts} | Points: ${user.points}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _startQuiz(context),
                child: const Text('Start Quiz'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startQuiz(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => sl<QuizBloc>()..add(const FetchNewQuiz(amount: 10, difficulty: 'easy')),
          child: const QuizPage(),
        ),
      ),
    );
  }
}
