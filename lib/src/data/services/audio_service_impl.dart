import 'package:audioplayers/audioplayers.dart';
import 'package:quiz_champ/src/core/error/failures.dart';
import 'package:quiz_champ/src/domain/repositories/audio_service.dart';

class AudioServiceImpl implements AudioService {
  final AudioPlayer _audioPlayer;
  bool _isMuted = false;
  bool _soundsPreloaded = false;

  // Sound file paths
  static const String correctSoundPath = 'audio/correct.mp3';
  static const String incorrectSoundPath = 'audio/wrong.mp3';
  static const String timeoutSoundPath = 'audio/wrong.mp3'; // Using wrong sound for timeout

  AudioServiceImpl({AudioPlayer? audioPlayer}) 
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  @override
  bool get isMuted => _isMuted;

  @override
  Future<void> preloadSounds() async {
    if (_soundsPreloaded) return;

    try {
      // Preload all sound effects
      await _audioPlayer.setSource(AssetSource(correctSoundPath));
      await _audioPlayer.setSource(AssetSource(incorrectSoundPath));
      await _audioPlayer.setSource(AssetSource(timeoutSoundPath));
      
      _soundsPreloaded = true;
    } catch (e) {
      // Preloading failed, but we can still try to play sounds on demand
      print('Failed to preload sounds: $e');
    }
  }

  @override
  Future<void> playCorrectSound() async {
    if (_isMuted) return;
    
    try {
      await _playSound(correctSoundPath);
    } catch (e) {
      throw AudioFailure(message: 'Failed to play correct sound: $e');
    }
  }

  @override
  Future<void> playIncorrectSound() async {
    if (_isMuted) return;
    
    try {
      await _playSound(incorrectSoundPath);
    } catch (e) {
      throw AudioFailure(message: 'Failed to play incorrect sound: $e');
    }
  }

  @override
  Future<void> playTimeoutSound() async {
    if (_isMuted) return;
    
    try {
      await _playSound(timeoutSoundPath);
    } catch (e) {
      throw AudioFailure(message: 'Failed to play timeout sound: $e');
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
      // Re-throw as AudioFailure for consistent error handling
      throw AudioFailure(message: 'Audio playback failed: $e');
    }
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}