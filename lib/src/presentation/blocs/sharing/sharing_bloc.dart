import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/sharing_service.dart';
import 'sharing_event.dart';
import 'sharing_state.dart';

class SharingBloc extends Bloc<SharingEvent, SharingState> {
  final SharingService sharingService;

  SharingBloc({required this.sharingService}) : super(const SharingInitial()) {
    on<LoadSharingData>(_onLoadSharingData);
    on<ShareAppLink>(_onShareAppLink);
    on<ShareInviteCode>(_onShareInviteCode);
    on<GenerateNewCode>(_onGenerateNewCode);
  }

  Future<void> _onLoadSharingData(LoadSharingData event, Emitter<SharingState> emit) async {
    emit(const SharingLoading());
    
    try {
      final linkResult = await sharingService.generateShareableLink();
      final codeResult = await sharingService.generateInviteCode();
      
      final linkEither = linkResult.fold((failure) => '', (link) => link);
      final codeEither = codeResult.fold((failure) => '', (code) => code);
      
      if (linkEither.isNotEmpty && codeEither.isNotEmpty) {
        emit(SharingLoaded(
          shareableLink: linkEither,
          inviteCode: codeEither,
          invitesSent: 0, // TODO: Get from user data
          friendsJoined: 0, // TODO: Get from user data
        ));
      } else {
        emit(const SharingError(message: 'Failed to load sharing data'));
      }
    } catch (e) {
      emit(SharingError(message: 'Failed to load sharing data: $e'));
    }
  }

  Future<void> _onShareAppLink(ShareAppLink event, Emitter<SharingState> emit) async {
    final currentState = state;
    if (currentState is SharingLoaded) {
      emit(currentState.copyWith(isSharing: true));
      
      final result = await sharingService.shareAppLink(currentState.shareableLink);
      
      result.fold(
        (failure) => emit(SharingError(message: failure.toString())),
        (_) => emit(currentState.copyWith(isSharing: false)),
      );
    }
  }

  Future<void> _onShareInviteCode(ShareInviteCode event, Emitter<SharingState> emit) async {
    final currentState = state;
    if (currentState is SharingLoaded) {
      emit(currentState.copyWith(isSharing: true));
      
      final result = await sharingService.shareInviteCode(currentState.inviteCode);
      
      result.fold(
        (failure) => emit(SharingError(message: failure.toString())),
        (_) => emit(currentState.copyWith(isSharing: false)),
      );
    }
  }

  Future<void> _onGenerateNewCode(GenerateNewCode event, Emitter<SharingState> emit) async {
    emit(const SharingLoading());
    
    try {
      final linkResult = await sharingService.generateShareableLink();
      final codeResult = await sharingService.generateInviteCode();
      
      final linkEither = linkResult.fold((failure) => '', (link) => link);
      final codeEither = codeResult.fold((failure) => '', (code) => code);
      
      if (linkEither.isNotEmpty && codeEither.isNotEmpty) {
        emit(SharingLoaded(
          shareableLink: linkEither,
          inviteCode: codeEither,
          invitesSent: 0, // TODO: Get from user data
          friendsJoined: 0, // TODO: Get from user data
        ));
      } else {
        emit(const SharingError(message: 'Failed to generate new code'));
      }
    } catch (e) {
      emit(SharingError(message: 'Failed to generate new code: $e'));
    }
  }
}
