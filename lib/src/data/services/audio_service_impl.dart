import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_champ/src/domain/repositories/audio_service.dart';

class AudioServiceImpl implements AudioService {
  final AudioPlayer _audioPlayer;
  bool _isMuted = false;

  // Sound file paths
  static const String correctSoundPath = 'audio/correct.mp3';
  static const String incorrectSoundPath = 'audio/wrong.mp3';
  static const String timeoutSoundPath = 'audio/wrong.mp3'; // Using wrong sound for timeout

  AudioServiceImpl({AudioPlayer? audioPlayer}) 
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  @override
  bool get isMuted => _isMuted;

  @override
  Future<void> playCorrectSound() async {
    if (_isMuted) return;
    
    try {
      await _playSound(correctSoundPath);
    } catch (e) {
      print('⚠️ [AudioService] Failed to play correct sound: $e');
      // Don't throw - continue silently
    }
  }

  @override
  Future<void> playIncorrectSound() async {
    if (_isMuted) return;
    
    try {
      await _playSound(incorrectSoundPath);
    } catch (e) {
      print('⚠️ [AudioService] Failed to play incorrect sound: $e');
      // Don't throw - continue silently
    }
  }

  @override
  Future<void> playTimeoutSound() async {
    if (_isMuted) return;
    
    try {
      await _playSound(timeoutSoundPath);
    } catch (e) {
      print('⚠️ [AudioService] Failed to play timeout sound: $e');
      // Don't throw - continue silently
    }
  }

  @override
  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    
    if (muted) {
      // Stop any currently playing sound
      await _audioPlayer.stop();
    }
  }

  Future<void> _playSound(String soundPath) async {
    try {
      // Stop any currently playing sound
      await _audioPlayer.stop();
      
      // Set the source and play
      await _audioPlayer.setSource(AssetSource(soundPath));
      await _audioPlayer.resume();
      
      // Ensure sound completes within 2 seconds as per requirements
      await Future.delayed(const Duration(seconds: 2));
      await _audioPlayer.stop();
    } catch (e) {
      // Log the error but don't throw - let the quiz continue
      print('⚠️ [AudioService] Audio playback failed: $e');
      // Don't re-throw exception to avoid breaking quiz flow
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}