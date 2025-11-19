import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:quiz_champ/src/core/di/injection_container.dart' as di;
import 'package:quiz_champ/src/presentation/blocs/auth/auth_bloc.dart';
import 'package:quiz_champ/src/presentation/pages/splash_page.dart';
import 'package:quiz_champ/src/domain/repositories/audio_service.dart';
import 'package:quiz_champ/src/domain/repositories/hearts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Initialize Firebase and Dependency Injection
  // await Firebase.initializeApp(); // Placeholder: Requires native setup
  await di.init();
  
  // Preload audio files for better performance
  try {
    final audioService = di.sl<AudioService>();
    await (audioService as dynamic).preloadAudioFiles();
  } catch (e) {
    // Handle audio preload errors gracefully
    debugPrint('Audio preload failed: $e');
  }
  
  // Start hearts regeneration timer
  try {
    final heartsService = di.sl<HeartsService>();
    (heartsService as dynamic).startRegenerationTimer();
  } catch (e) {
    // Handle hearts service errors gracefully
    debugPrint('Hearts service initialization failed: $e');
  }
  
  runApp(const QuizChampApp());
}

class QuizChampApp extends StatelessWidget {
  const QuizChampApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<AuthBloc>()..add(AuthCheckRequested()),
        ),
        // Other BLoC providers will go here
      ],
      child: MaterialApp(
        title: 'QuizChamp',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashPage(),
      ),
    );
  }
}
