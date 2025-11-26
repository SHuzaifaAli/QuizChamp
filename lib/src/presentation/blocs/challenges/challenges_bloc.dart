import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/challenge_entity.dart';
import '../../../domain/repositories/challenges_repository.dart';
import '../../../domain/usecases/challenges/create_challenge_usecase.dart';
import '../../../domain/usecases/challenges/get_challenge_usecase.dart';
import '../../../domain/usecases/challenges/get_user_challenges_usecase.dart';
import '../../../domain/usecases/challenges/accept_challenge_usecase.dart';
import '../../../domain/usecases/challenges/decline_challenge_usecase.dart';
import '../../../domain/usecases/challenges/complete_challenge_usecase.dart';
import '../../../domain/usecases/challenges/get_pending_challenges_usecase.dart';
import 'challenges_event.dart';
import 'challenges_state.dart';

class ChallengesBloc extends Bloc<ChallengesEvent, ChallengesState> {
  final CreateChallengeUseCase _createChallengeUseCase;
  final GetChallengeUseCase _getChallengeUseCase;
  final GetUserChallengesUseCase _getUserChallengesUseCase;
  final AcceptChallengeUseCase _acceptChallengeUseCase;
  final DeclineChallengeUseCase _declineChallengeUseCase;
  final CompleteChallengeUseCase _completeChallengeUseCase;
  final GetPendingChallengesUseCase _getPendingChallengesUseCase;

  ChallengesBloc({
    required CreateChallengeUseCase createChallengeUseCase,
    required GetChallengeUseCase getChallengeUseCase,
    required GetUserChallengesUseCase getUserChallengesUseCase,
    required AcceptChallengeUseCase acceptChallengeUseCase,
    required DeclineChallengeUseCase declineChallengeUseCase,
    required CompleteChallengeUseCase completeChallengeUseCase,
    required GetPendingChallengesUseCase getPendingChallengesUseCase,
  })  : _createChallengeUseCase = createChallengeUseCase,
        _getChallengeUseCase = getChallengeUseCase,
        _getUserChallengesUseCase = getUserChallengesUseCase,
        _acceptChallengeUseCase = acceptChallengeUseCase,
        _declineChallengeUseCase = declineChallengeUseCase,
        _completeChallengeUseCase = completeChallengeUseCase,
        _getPendingChallengesUseCase = getPendingChallengesUseCase,
        super(const ChallengesInitial()) {
    on<LoadUserChallenges>(_onLoadUserChallenges);
    on<CreateChallenge>(_onCreateChallenge);
    on<AcceptChallenge>(_onAcceptChallenge);
    on<DeclineChallenge>(_onDeclineChallenge);
    on<CompleteChallenge>(_onCompleteChallenge);
    on<CancelChallenge>(_onCancelChallenge);
    on<LoadPendingChallenges>(_onLoadPendingChallenges);
    on<RefreshChallenges>(_onRefreshChallenges);
  }

  Future<void> _onLoadUserChallenges(
    LoadUserChallenges event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());
    
    try {
      final challengesStream = _getUserChallengesUseCase(event.userId);
      final pendingResult = await _getPendingChallengesUseCase(event.userId);
      
      await for (final challenges in challengesStream) {
        final pendingChallenges = pendingResult.fold(
          (failure) => <Challenge>[],
          (pending) => pending,
        );
        
        final activeChallenges = challenges.where((c) =>
          c?.status == ChallengeStatus.accepted || c?.status == ChallengeStatus.active
        ).toList();
        
        final completedChallenges = challenges.where((c) =>
          c?.status == ChallengeStatus.completed
        ).toList();

        emit(ChallengesLoaded(
          userChallenges: challenges,
          pendingChallenges: pendingChallenges,
          activeChallenges: activeChallenges,
          completedChallenges: completedChallenges,
        ));
      }
    } catch (e) {
      emit(ChallengesError('Failed to load challenges: ${e.toString()}'));
    }
  }

  Future<void> _onCreateChallenge(
    CreateChallenge event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());
    
    try {
      final params = CreateChallengeParams(
        challengerId: event.challengerId,
        challengedId: event.challengedId,
        category: event.category,
        difficulty: event.difficulty,
        questions: event.questions,
        message: event.message,
      );

      final result = await _createChallengeUseCase(params);
      
      result.fold(
        (failure) => emit(ChallengesError('Failed to create challenge: ${(failure as ServerFailure).message}')),
        (success) => emit(const ChallengeOperationSuccess('Challenge created successfully!')),
      );
    } catch (e) {
      emit(ChallengesError('Failed to create challenge: ${e.toString()}'));
    }
  }

  Future<void> _onAcceptChallenge(
    AcceptChallenge event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());
    
    try {
      final result = await _acceptChallengeUseCase(event.challengeId, event.userId);
      
      result.fold(
        (failure) => emit(ChallengesError('Failed to accept challenge: ${(failure as ServerFailure).message}')),
        (success) => emit(const ChallengeOperationSuccess('Challenge accepted!')),
      );
    } catch (e) {
      emit(ChallengesError('Failed to accept challenge: ${e.toString()}'));
    }
  }

  Future<void> _onDeclineChallenge(
    DeclineChallenge event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());
    
    try {
      final result = await _declineChallengeUseCase(event.challengeId, event.userId);
      
      result.fold(
        (failure) => emit(ChallengesError('Failed to decline challenge: ${(failure as ServerFailure).message}')),
        (success) => emit(const ChallengeOperationSuccess('Challenge declined')),
      );
    } catch (e) {
      emit(ChallengesError('Failed to decline challenge: ${e.toString()}'));
    }
  }

  Future<void> _onCompleteChallenge(
    CompleteChallenge event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());
    
    try {
      final challengeResult = ChallengeResult(
        userId: event.challengeId, // This should be the actual user ID
        score: event.challengerScore,
        correctAnswers: event.challengerScore, // Assuming 1 point per correct answer
        totalQuestions: 10, // This should come from the challenge
        accuracyPercentage: (event.challengerScore / 10) * 100,
        timeToComplete: Duration.zero, // This should be tracked
        completedAt: DateTime.now(),
        answers: [], // This should contain actual answers
      );

      final result = await _completeChallengeUseCase(event.challengeId, challengeResult);
      
      result.fold(
        (failure) => emit(ChallengesError('Failed to complete challenge: ${(failure as ServerFailure).message}')),
        (success) => emit(const ChallengeOperationSuccess('Challenge completed!')),
      );
    } catch (e) {
      emit(ChallengesError('Failed to complete challenge: ${e.toString()}'));
    }
  }

  Future<void> _onCancelChallenge(
    CancelChallenge event,
    Emitter<ChallengesState> emit,
  ) async {
    emit(const ChallengesLoading());
    
    try {
      final challengeResult = await _getChallengeUseCase(event.challengeId);
      
      challengeResult.fold(
        (failure) => emit(ChallengesError('Failed to find challenge: ${(failure as ServerFailure).message}')),
        (challenge) async {
          if (challenge == null) {
            emit(const ChallengesError('Challenge not found'));
            return;
          }
          
          if (challenge.status == ChallengeStatus.pending) {
            final declineResult = await _declineChallengeUseCase(event.challengeId, challenge.challengerId);
            declineResult.fold(
              (failure) => emit(ChallengesError('Failed to cancel challenge: ${(failure as ServerFailure).message}')),
              (success) => emit(const ChallengeOperationSuccess('Challenge cancelled')),
            );
          } else {
            emit(const ChallengesError('Cannot cancel challenge in current state'));
          }
        },
      );
    } catch (e) {
      emit(ChallengesError('Failed to cancel challenge: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPendingChallenges(
    LoadPendingChallenges event,
    Emitter<ChallengesState> emit,
  ) async {
    try {
      final result = await _getPendingChallengesUseCase(event.userId);
      
      result.fold(
        (failure) => emit(ChallengesError('Failed to load pending challenges: ${(failure as ServerFailure).message}')),
        (pendingChallenges) {
          if (state is ChallengesLoaded) {
            final currentState = state as ChallengesLoaded;
            emit(currentState.copyWith(pendingChallenges: pendingChallenges));
          }
        },
      );
    } catch (e) {
      emit(ChallengesError('Failed to load pending challenges: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshChallenges(
    RefreshChallenges event,
    Emitter<ChallengesState> emit,
  ) async {
    add(LoadUserChallenges(event.userId));
  }
}
