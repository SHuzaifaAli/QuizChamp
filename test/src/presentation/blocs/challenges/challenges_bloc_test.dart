import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import '../../../../../../lib/src/presentation/blocs/challenges/challenges_bloc.dart';
import '../../../../../../lib/src/presentation/blocs/challenges/challenges_event.dart';
import '../../../../../../lib/src/presentation/blocs/challenges/challenges_state.dart';
import '../../../../../../lib/src/domain/usecases/challenges/create_challenge_usecase.dart';
import '../../../../../../lib/src/domain/usecases/challenges/get_challenge_usecase.dart';
import '../../../../../../lib/src/domain/usecases/challenges/get_user_challenges_usecase.dart';
import '../../../../../../lib/src/domain/usecases/challenges/accept_challenge_usecase.dart';
import '../../../../../../lib/src/domain/usecases/challenges/decline_challenge_usecase.dart';
import '../../../../../../lib/src/domain/usecases/challenges/complete_challenge_usecase.dart';
import '../../../../../../lib/src/domain/usecases/challenges/get_pending_challenges_usecase.dart';
import '../../../../../../lib/src/domain/entities/challenge_entity.dart';
import '../../../../../../lib/src/errors/failures.dart';

@GenerateMocks([
  CreateChallengeUseCase,
  GetChallengeUseCase,
  GetUserChallengesUseCase,
  AcceptChallengeUseCase,
  DeclineChallengeUseCase,
  CompleteChallengeUseCase,
  GetPendingChallengesUseCase,
])
void main() {
  late ChallengesBloc bloc;
  late MockCreateChallengeUseCase mockCreateChallengeUseCase;
  late MockGetChallengeUseCase mockGetChallengeUseCase;
  late MockGetUserChallengesUseCase mockGetUserChallengesUseCase;
  late MockAcceptChallengeUseCase mockAcceptChallengeUseCase;
  late MockDeclineChallengeUseCase mockDeclineChallengeUseCase;
  late MockCompleteChallengeUseCase mockCompleteChallengeUseCase;
  late MockGetPendingChallengesUseCase mockGetPendingChallengesUseCase;

  setUp(() {
    mockCreateChallengeUseCase = MockCreateChallengeUseCase();
    mockGetChallengeUseCase = MockGetChallengeUseCase();
    mockGetUserChallengesUseCase = MockGetUserChallengesUseCase();
    mockAcceptChallengeUseCase = MockAcceptChallengeUseCase();
    mockDeclineChallengeUseCase = MockDeclineChallengeUseCase();
    mockCompleteChallengeUseCase = MockCompleteChallengeUseCase();
    mockGetPendingChallengesUseCase = MockGetPendingChallengesUseCase();

    bloc = ChallengesBloc(
      createChallengeUseCase: mockCreateChallengeUseCase,
      getChallengeUseCase: mockGetChallengeUseCase,
      getUserChallengesUseCase: mockGetUserChallengesUseCase,
      acceptChallengeUseCase: mockAcceptChallengeUseCase,
      declineChallengeUseCase: mockDeclineChallengeUseCase,
      completeChallengeUseCase: mockCompleteChallengeUseCase,
      getPendingChallengesUseCase: mockGetPendingChallengesUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('ChallengesBloc', () {
    const testUserId = 'user123';
    const testChallengeId = 'challenge123';
    const testChallengerId = 'user1';
    const testChallengedId = 'user2';
    const testChallengerName = 'Alice';
    const testChallengedName = 'Bob';
    const testCategory = 'Science';
    const testDifficulty = 'Medium';

    final testChallenge = Challenge(
      id: testChallengeId,
      challengerId: testChallengerId,
      challengedId: testChallengedId,
      challengerName: testChallengerName,
      challengedName: testChallengedName,
      category: testCategory,
      difficulty: testDifficulty,
      questions: [],
      status: ChallengeStatus.pending,
      createdAt: DateTime.now(),
    );

    test('initial state is ChallengesInitial', () {
      expect(bloc.state, const ChallengesInitial());
    });

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesLoading and ChallengesLoaded when LoadUserChallenges is added',
      build: () {
        when(mockGetUserChallengesUseCase(testUserId))
            .thenAnswer((_) => Stream.value([testChallenge]));
        when(mockGetPendingChallengesUseCase(testUserId))
            .thenAnswer((_) async => const Right([testChallenge]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadUserChallenges(testUserId)),
      expect: () => [
        const ChallengesLoading(),
        ChallengesLoaded(
          userChallenges: [testChallenge],
          pendingChallenges: [testChallenge],
          activeChallenges: [],
          completedChallenges: [],
        ),
      ],
    );

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesOperationInProgress and ChallengeOperationSuccess when CreateChallenge is added',
      build: () {
        when(mockCreateChallengeUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateChallenge(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        category: testCategory,
        difficulty: testDifficulty,
        questions: [],
      )),
      expect: () => [
        const ChallengesOperationInProgress('Creating challenge...'),
        const ChallengeOperationSuccess('Challenge created successfully!'),
      ],
    );

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesOperationInProgress and ChallengesError when CreateChallenge fails',
      build: () {
        when(mockCreateChallengeUseCase(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Failed to create challenge')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateChallenge(
        challengerId: testChallengerId,
        challengedId: testChallengedId,
        challengerName: testChallengerName,
        challengedName: testChallengedName,
        category: testCategory,
        difficulty: testDifficulty,
        questions: [],
      )),
      expect: () => [
        const ChallengesOperationInProgress('Creating challenge...'),
        const ChallengesError('Failed to create challenge: Failed to create challenge'),
      ],
    );

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesOperationInProgress and ChallengeOperationSuccess when AcceptChallenge is added',
      build: () {
        when(mockAcceptChallengeUseCase(testChallengeId))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(AcceptChallenge(testChallengeId)),
      expect: () => [
        const ChallengesOperationInProgress('Accepting challenge...'),
        const ChallengeOperationSuccess('Challenge accepted!'),
      ],
    );

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesOperationInProgress and ChallengeOperationSuccess when DeclineChallenge is added',
      build: () {
        when(mockDeclineChallengeUseCase(testChallengeId))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(DeclineChallenge(testChallengeId)),
      expect: () => [
        const ChallengesOperationInProgress('Declining challenge...'),
        const ChallengeOperationSuccess('Challenge declined'),
      ],
    );

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesOperationInProgress and ChallengeOperationSuccess when CompleteChallenge is added',
      build: () {
        when(mockCompleteChallengeUseCase(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(CompleteChallenge(
        challengeId: testChallengeId,
        challengerScore: 80,
        challengedScore: 75,
      )),
      expect: () => [
        const ChallengesOperationInProgress('Completing challenge...'),
        const ChallengeOperationSuccess('Challenge completed!'),
      ],
    );

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesOperationInProgress and ChallengeOperationSuccess when CancelChallenge is added for pending challenge',
      build: () {
        when(mockGetChallengeUseCase(testChallengeId))
            .thenAnswer((_) async => Right(testChallenge));
        when(mockDeclineChallengeUseCase(testChallengeId))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(CancelChallenge(testChallengeId)),
      expect: () => [
        const ChallengesOperationInProgress('Cancelling challenge...'),
        const ChallengeOperationSuccess('Challenge cancelled'),
      ],
    );

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesError when CancelChallenge is added for non-pending challenge',
      build: () {
        final activeChallenge = testChallenge.copyWith(status: ChallengeStatus.inProgress);
        when(mockGetChallengeUseCase(testChallengeId))
            .thenAnswer((_) async => Right(activeChallenge));
        return bloc;
      },
      act: (bloc) => bloc.add(CancelChallenge(testChallengeId)),
      expect: () => [
        const ChallengesOperationInProgress('Cancelling challenge...'),
        const ChallengesError('Cannot cancel challenge in current state'),
      ],
    );

    blocTest<ChallengesBloc, ChallengesState>(
      'emits ChallengesError when LoadUserChallenges fails',
      build: () {
        when(mockGetUserChallengesUseCase(testUserId))
            .thenThrow(Exception('Failed to load challenges'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadUserChallenges(testUserId)),
      expect: () => [
        const ChallengesLoading(),
        isA<ChallengesError>(),
      ],
    );
  });
}
