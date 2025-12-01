import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';

// Auth imports
import 'package:quiz_champ/src/data/datasources/auth_remote_datasource.dart';
import 'package:quiz_champ/src/data/repositories/auth_repository_impl.dart';
import 'package:quiz_champ/src/domain/repositories/auth_repository.dart';
import 'package:quiz_champ/src/domain/usecases/auth/get_user_status.dart';
import 'package:quiz_champ/src/domain/usecases/auth/sign_in_with_google.dart';
import 'package:quiz_champ/src/domain/usecases/auth/sign_out.dart';
import 'package:quiz_champ/src/data/services/user_service.dart';
import 'package:quiz_champ/src/presentation/blocs/auth/auth_bloc.dart';

// Enhanced Quiz Engine imports
import 'package:quiz_champ/src/data/datasources/question_remote_datasource.dart';
import 'package:quiz_champ/src/data/datasources/question_local_datasource.dart';
import 'package:quiz_champ/src/data/repositories/question_repository_impl.dart';
import 'package:quiz_champ/src/data/repositories/quiz_repository_impl.dart';
import 'package:quiz_champ/src/data/repositories/audio_service_impl.dart';
import 'package:quiz_champ/src/data/repositories/animation_service_impl.dart';

// Social Features imports
import 'package:quiz_champ/src/data/datasources/challenges_remote_datasource.dart';
import 'package:quiz_champ/src/data/datasources/social_activity_remote_datasource.dart';
import 'package:quiz_champ/src/data/datasources/leaderboard_remote_datasource.dart';
import 'package:quiz_champ/src/data/datasources/friends_remote_datasource.dart';
import 'package:quiz_champ/src/data/repositories/challenges_repository_impl.dart';
import 'package:quiz_champ/src/data/repositories/social_activity_repository_impl.dart';
import 'package:quiz_champ/src/data/repositories/leaderboard_repository_impl.dart';
import 'package:quiz_champ/src/data/repositories/friends_repository_impl.dart';
import 'package:quiz_champ/src/data/repositories/sharing_service_impl.dart';
import 'package:quiz_champ/src/domain/repositories/challenges_repository.dart';
import 'package:quiz_champ/src/domain/repositories/social_activity_repository.dart';
import 'package:quiz_champ/src/domain/repositories/leaderboard_repository.dart';
import 'package:quiz_champ/src/domain/repositories/friends_repository.dart';
import 'package:quiz_champ/src/domain/repositories/sharing_service.dart';
import 'package:quiz_champ/src/domain/usecases/challenges/create_challenge_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/challenges/get_challenge_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/challenges/get_user_challenges_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/challenges/accept_challenge_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/challenges/decline_challenge_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/challenges/complete_challenge_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/challenges/get_pending_challenges_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/social/get_friends_activity_feed_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/social/create_quiz_completed_activity_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/social/add_reaction_to_activity_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/social/send_friend_request_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/social/accept_friend_request_usecase.dart';
import 'package:quiz_champ/src/presentation/blocs/challenges/challenges_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/social_activity/social_activity_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/friends/friends_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/sharing/sharing_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/hearts/hearts_bloc.dart';
import 'package:quiz_champ/src/presentation/blocs/user/user_bloc.dart';
import 'package:quiz_champ/src/data/repositories/hearts_service_impl.dart';
import 'package:quiz_champ/src/domain/repositories/question_repository.dart';
import 'package:quiz_champ/src/domain/repositories/quiz_repository.dart';
import 'package:quiz_champ/src/domain/repositories/audio_service.dart';
import 'package:quiz_champ/src/domain/repositories/animation_service.dart';
import 'package:quiz_champ/src/domain/repositories/hearts_service.dart';
import 'package:quiz_champ/src/domain/usecases/quiz/start_quiz_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/quiz/answer_question_usecase.dart';
import 'package:quiz_champ/src/domain/usecases/quiz/question_timer_usecase.dart';
import 'package:quiz_champ/src/presentation/blocs/quiz/quiz_bloc.dart';

// Legacy quiz imports (to be removed/updated)
import 'package:quiz_champ/src/data/datasources/quiz_remote_datasource.dart';
import 'package:quiz_champ/src/domain/usecases/quiz/fetch_questions.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signInWithGoogle: sl(),
      signOut: sl(),
      getUserStatus: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetUserStatus(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      userService: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
    ),
  );

  sl.registerLazySingleton<UserService>(
    () => UserService(
      firestore: sl(),
      auth: sl(),
    ),
  );

  //! Features - Enhanced Quiz Engine
  // Bloc
  sl.registerFactory(
    () => QuizBloc(
      startQuizUseCase: sl(),
      answerQuestionUseCase: sl(),
      questionTimerUseCase: sl(),
      quizRepository: sl(),
      audioService: sl(),
      heartsService: sl(),
      userService: sl(),
      userBloc: null, // Will be provided manually
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => StartQuizUseCase(
        quizRepository: sl(),
        heartsService: sl(),
      ));
  sl.registerLazySingleton(() => AnswerQuestionUseCase(quizRepository: sl()));
  sl.registerLazySingleton(() => QuestionTimerUseCase());

  // Repositories
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(questionRepository: sl()),
  );
  sl.registerLazySingleton<QuestionRepository>(
    () => QuestionRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton<AudioService>(
    () => AudioServiceImpl(audioPlayer: sl()),
  );
  sl.registerLazySingleton<AnimationService>(
    () => AnimationServiceImpl(),
  );
  sl.registerLazySingleton<HeartsService>(
    () => HeartsServiceImpl(),
  );

  // Data sources
  sl.registerLazySingleton<QuestionRemoteDataSource>(
    () => QuestionRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<QuestionLocalDataSource>(
    () => QuestionLocalDataSourceImpl(),
  );

  //! Features - Social Features
  // Bloc
  sl.registerFactory(
    () => ChallengesBloc(
      createChallengeUseCase: sl(),
      getChallengeUseCase: sl(),
      getUserChallengesUseCase: sl(),
      acceptChallengeUseCase: sl(),
      declineChallengeUseCase: sl(),
      completeChallengeUseCase: sl(),
      getPendingChallengesUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => SocialActivityBloc(
      getFriendsActivityFeedUseCase: sl(),
      createQuizCompletedActivityUseCase: sl(),
      addReactionToActivityUseCase: sl(),
      socialActivityRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => LeaderboardBloc(
      repository: sl(),
    ),
  );

  // Challenges Use cases
  sl.registerLazySingleton(() => CreateChallengeUseCase(sl()));
  sl.registerLazySingleton(() => GetChallengeUseCase(sl()));
  sl.registerLazySingleton(() => GetUserChallengesUseCase(sl()));
  sl.registerLazySingleton(() => AcceptChallengeUseCase(sl()));
  sl.registerLazySingleton(() => DeclineChallengeUseCase(sl()));
  sl.registerLazySingleton(() => CompleteChallengeUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingChallengesUseCase(sl()));

  // Social Activity Use cases
  sl.registerLazySingleton(() => GetFriendsActivityFeedUseCase(sl()));
  sl.registerLazySingleton(() => CreateQuizCompletedActivityUseCase(sl()));
  sl.registerLazySingleton(() => AddReactionToActivityUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<ChallengesRepository>(
    () => ChallengesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<SocialActivityRepository>(
    () => SocialActivityRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<LeaderboardRepository>(
    () => LeaderboardRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ChallengesRemoteDataSource>(
    () => ChallengesRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<SocialActivityRemoteDataSource>(
    () => SocialActivityRemoteDataSource(sl()),
  );
  sl.registerLazySingleton<LeaderboardRemoteDataSource>(
    () => LeaderboardRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<FriendsRemoteDataSource>(
    () => FriendsRemoteDataSourceImpl(firestore: sl()),
  );

  // Repositories
  sl.registerLazySingleton<FriendsRepository>(
    () => FriendsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SharingService>(
    () => SharingServiceImpl(),
  );

  // Use cases
  sl.registerLazySingleton(
      () => SendFriendRequestUseCase(friendsRepository: sl()));
  sl.registerLazySingleton(
      () => AcceptFriendRequestUseCase(friendsRepository: sl()));

  // Blocs
  sl.registerFactory(
    () => FriendsBloc(
      friendsRepository: sl(),
      sendFriendRequestUseCase: sl(),
      acceptFriendRequestUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SharingBloc(sharingService: sl()),
  );
  sl.registerFactory(
    () => UserBloc(userService: sl()),
  );
  sl.registerFactory(
    () => HeartsBloc(
      heartsService: sl(),
      userService: sl(),
      userBloc: null, // Will be provided manually
    ),
  );

  //! Legacy Quiz (to be removed)
  // Use cases
  sl.registerLazySingleton(() => FetchQuestions(sl()));

  // Data sources
  sl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(client: sl()),
  );

  //! Core
  // Networking
  sl.registerLazySingleton(() => Dio());

  // External - Using Firebase Auth directly (no GoogleSignIn dependency)
  // GoogleSignIn is removed - using Firebase Auth's built-in Google Sign-In
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => AudioPlayer());
}
