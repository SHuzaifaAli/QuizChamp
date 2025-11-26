import 'package:equatable/equatable.dart';

abstract class SharingEvent extends Equatable {
  const SharingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSharingData extends SharingEvent {
  const LoadSharingData();
}

class ShareAppLink extends SharingEvent {
  const ShareAppLink();
}

class ShareInviteCode extends SharingEvent {
  const ShareInviteCode();
}

class GenerateNewCode extends SharingEvent {
  const GenerateNewCode();
}
