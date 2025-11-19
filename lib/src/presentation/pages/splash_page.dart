import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiz_champ/src/domain/entities/user_entity.dart';
import 'package:quiz_champ/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:quiz_champ/src/presentation/pages/home_page.dart';
import 'package:quiz_champ/src/presentation/pages/sign_in_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            _navigateToHome(context, state.user);
          } else if (state is AuthUnauthenticated) {
            _navigateToSignIn(context);
          }
        },
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading QuizChamp...'),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context, UserEntity user) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage(user: user)),
    );
  }

  void _navigateToSignIn(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SignInPage()),
    );
  }
}
