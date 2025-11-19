abstract class AudioService {
  Future<void> playCorrectSound();
  Future<void> playIncorrectSound();
  Future<void> playTimeoutSound();
  Future<void> setMuted(bool muted);
  bool get isMuted;
}